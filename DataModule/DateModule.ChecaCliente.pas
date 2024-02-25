unit DateModule.ChecaCliente;

interface

uses
  uFuncoes,
  uMD5,

  Data.DB,

  DataSet.Serialize,
  DataSet.Serialize.Config,
  DateModule.Global,

  FMX.Graphics,

  FireDAC.Comp.Client,
  FireDAC.DApt,
  FireDAC.FMXUI.Wait,
  FireDAC.Phys,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,
  FireDAC.Phys.IBBase,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Async,
  FireDAC.Stan.Def,
  FireDAC.Stan.Error,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Pool,
  FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait,

  System.Classes,
  System.JSON,
  System.SysUtils,
  System.Variants,

  system.IniFiles, FMX.Dialogs;

type
  TDmChecaCliente = class(TDataModule)
  private
    Fcod_cliente: Integer;
    procedure Alterar_Ultima_Compra(dtData: TDateTime; rlValor: real);
    function MotivoBloqueio: string;
//    function GetBloqueioPedido(objCliente: TCliente;
//      objMonitorPedido: TMonitorPedido; strCodFormaPag: string; blnCfopVenda,
//      blnContaAberta: Boolean; intIsnBloqAtual: Integer;
//      fltLimite: double): Integer;
    { Private declarations }
  public
    { Public declarations }
    property cod_cliente: Integer read Fcod_cliente write Fcod_cliente;


    function Calc_Limite: Double;
  end;

var
  DmChecaCliente: TDmChecaCliente;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

// Verifica os Débitos do Cliente para gerar o limite
function TDmChecaCliente.Calc_Limite() : Double;
var qryLimCliente : TFDQuery;
    DMGLobal : TDmGlobal;
    LrlLImite : Real;
    strISNContaReceber : string;
    strSQL : string;

begin
    DMGLobal := TDmGlobal.Create(nil);
    qryLimCliente := TFDQuery.Create(nil);
    qryLimCliente.Connection := DMGLobal.Conn;


    LrlLimite := 0;

    // Verifica na Tabela de Previsão de Contas a Receber Venda
    strSQL := 'SELECT SUM(PR.PVRVL_VALOR) AS DEBITO '+
              'FROM T_PREVISAO_RECEBER PR '+
              'INNER JOIN T_PEDIDO PED ON (PR.ISN_PEDIDO = PED.ISN_PEDIDO) '+
              'INNER JOIN T_FORMA_PAGAMENTO FP ON (FP.ISN_FORMA_PAGAMENTO = PED.ISN_FORMA_PAGAMENTO) ' +
              'INNER JOIN T_CFOP CFO ON (CFO.ISN_CFOP = PED.ISN_CFOP) '+
              'WHERE PVRDT_PRESTACAO_CONTAS IS NULL '+
              'AND FP.FPACN_FORMA <> ''DN'' ' + // Forma de Pagamento Dinheiro
              'AND FP.FPACN_FORMA <> ''DA'' '; // Forma de Pagamento Depósito Antecipado



    strSQL := strSQL +
              'AND CFO.CFOFG_VENDA = ''S'' '+
              ' AND PED.ISN_EMPRESA = ''1'' '+   //isn empresa
              ' AND (SELECT COUNT(IPED.ISN_PEDIDO) QTDE FROM T_ITEM_PEDIDO IPED WHERE IPED.ISN_PEDIDO = PED.ISN_PEDIDO) > 0 ' +
              //'AND PED.ISN_PEDIDO_ORIGEM IS NULL '+ //comentado por causa do indice na t_pedido pelo isn_pedido_origem
              'AND PR.ISN_CLIENTE = '+inttostr(cod_cliente);

    qryLimCliente.SQL.Add(strSQL);
    qryLimCliente.open;

    if not qryLimCliente.Eof Then
        LrlLimite := LrlLimite + qryLimCliente.FieldByName('DEBITO').AsFloat;

    qryLimCliente.Free;

    // Verifica na Tabela de Previsão de Contas a Receber Devolução
    strSQL := 'SELECT SUM(PR.PVRVL_VALOR) AS CREDITO '+
              'FROM T_PREVISAO_RECEBER PR '+
              'JOIN T_PEDIDO PED ON (PR.ISN_PEDIDO = PED.ISN_PEDIDO) '+
              'JOIN T_PEDIDO PED1 ON (PED1.ISN_PEDIDO = PED.ISN_PEDIDO_ORIGEM) '+
              'JOIN T_PREVISAO_RECEBER PR1 ON (PR1.ISN_PEDIDO = PED1.ISN_PEDIDO) '+
              'WHERE PR.PVRDT_PRESTACAO_CONTAS IS NULL '+
              'AND PED.ISN_PEDIDO_ORIGEM IS NOT NULL '+
              'AND PR1.PVRDT_PRESTACAO_CONTAS IS NULL '+
              ' AND PED.ISN_EMPRESA = ''1'' ' + //isn empresa
              ' AND PR.ISN_CLIENTE = '+inttostr(cod_cliente) +
              ' AND (SELECT COUNT(IPED.ISN_PEDIDO) QTDE FROM T_ITEM_PEDIDO IPED WHERE IPED.ISN_PEDIDO = PED.ISN_PEDIDO) > 0 ';

    qryLimCliente.Close;
    qryLimCliente.SQL.Clear;
    qryLimCliente.SQL.Add(strSQL);
    qryLimCliente.open;
    if not qryLimCliente.Eof Then
        LrlLimite := LrlLimite - qryLimCliente.FieldByName('CREDITO').AsFloat;

    qryLimCliente.Free;

    // Verifica na tabela de Contas a Receber, Status A- Conta Aberta (Devedora)
    strSQL := 'SELECT SUM(CREVL_VALOR) AS DEBITO '+
              'FROM T_PREVISAO_RECEBER T_PCR '+
              'INNER JOIN T_CONTAS_RECEBER T_CRE ON (T_PCR.ISN_PREVISAO_RECEBER = T_CRE.ISN_PREVISAO_RECEBER) '+
              'WHERE CREFG_STATUS = ''A'' '+
              'AND T_PCR.ISN_CLIENTE = '+  inttostr(cod_cliente);

    qryLimCliente.Close;
    qryLimCliente.SQL.Clear;
    qryLimCliente.SQL.Add(strSQL);
    qryLimCliente.open;

    if not qryLimCliente.Eof Then
        LrlLimite := LrlLimite + qryLimCliente.FieldByName('DEBITO').AsFloat;
    qryLimCliente.Free;


    // Verifica se há pagamento parcial do contas a receber
    strSQL := 'SELECT SUM(PP.PPAVL_VALOR) AS CREDITO '+
              'FROM T_PAGAMENTO_PARCIAL PP '+
              'INNER JOIN T_CONTAS_RECEBER CR ON (CR.ISN_CONTAS_RECEBER = PP.ISN_CONTAS_RECEBER) '+
              'INNER JOIN T_PREVISAO_RECEBER PR ON (PR.ISN_PREVISAO_RECEBER = CR.ISN_PREVISAO_RECEBER) '+
              'WHERE CR.CREFG_STATUS = ''A'' '+
              'AND PR.ISN_CLIENTE = '+  inttostr(cod_cliente);

    qryLimCliente.Close;
    qryLimCliente.SQL.Clear;
    qryLimCliente.SQL.Add(strSQL);
    qryLimCliente.open;

    if not qryLimCliente.Eof Then
        LrlLimite := LrlLimite - qryLimCliente.FieldByName('CREDITO').AsFloat;
    qryLimCliente.Free;

    // Verifica se há pedidos sem faturar e tira do limite
    strSQL := 'SELECT SUM(PED.PEDVL_TOTAL) AS DEBITO '+
              'FROM T_PEDIDO PED '+
              'INNER JOIN T_CFOP CFOP ON (PED.ISN_CFOP = CFOP.ISN_CFOP) '+
              'INNER JOIN T_TIPO_PEDIDO TPED ON (TPED.ISN_TIPO_PEDIDO = PED.ISN_TIPO_PEDIDO) ' +
              'INNER JOIN T_FORMA_PAGAMENTO FP ON (FP.ISN_FORMA_PAGAMENTO = PED.ISN_FORMA_PAGAMENTO) ' +
              'WHERE CFOP.CFOFG_VENDA = ''S'' AND TPED.TIPFG_ESTOQUE_LOJA = ''N'' '+
              'AND PEDFG_CANCELADO = ''N'' AND PEDFG_TRANSFERIDO = ''N'' '+
              'AND FP.FPACN_FORMA <> ''DN'' ' + // Forma de Pagamento Dinheiro
              'AND FP.FPACN_FORMA <> ''DA'' ' ; // Forma de Pagamento Depósito Antecipado

    strSQL := strSQL +
              'AND PED.ISN_CLIENTE = '+ inttostr(cod_cliente) +
              ' AND PED.ISN_EMPRESA = ''1'' ' +  //isn_empresa
              ' AND (SELECT COUNT(IPED.ISN_PEDIDO) QTDE FROM T_ITEM_PEDIDO IPED WHERE IPED.ISN_PEDIDO = PED.ISN_PEDIDO) > 0 ';

    qryLimCliente.Close;
    qryLimCliente.SQL.Clear;
    qryLimCliente.SQL.Add(strSQL);
    qryLimCliente.open;
    if not qryLimCliente.Eof Then
        LrlLimite := LrlLimite + qryLimCliente.FieldByName('DEBITO').AsFloat;
    qryLimCliente.Free;

    Calc_Limite := LrlLimite;


    FreeAndNil(DMGLobal);
    FreeAndNil(qryLimCliente);

end;

// Método para Atualizar Última Compra
procedure TDmChecaCliente.Alterar_Ultima_Compra(dtData:TDateTime;rlValor:real);
var
 DmGlobal : TDmGlobal;
 strSQL : string;
begin
   DmGlobal := TDmGlobal.Create(nil);

  strSQL := ' UPDATE T_CLIENTE SET CLIVL_MAIOR_COMPRA = ' + (FloatToStr(rlValor)) +
            ' ,CLIDT_MAIOR_COMPRA = ' + DateToStr(dtData) +
            ' WHERE ISN_CLIENTE = ' + inttostr(cod_cliente);

 { If Not DmGlobal.conn.ExecSQL(strSQL) then
     MessageDlg('Erro na atualização da última compra. Entre em contato com o Administrador do sistema. '+#10+#10, mtInformation,[mbOk], 0, mbOk)
 }

 FreeAndNil(DmGlobal);
end;


// Motivo Bloqueio
function TDmChecaCliente.MotivoBloqueio() : string;
var strIsnRep : longint;
DmGlobal : TDmGlobal;
qryRegistro : TFDQuery;
strSQL : string;

begin
  result := '';
  DmGlobal := TDmGlobal.Create(nil);

  qryRegistro := TFDQuery.Create(nil);
  qryRegistro.Connection := DmGlobal.Conn;

  strSQL := 'SELECT max(isn_bloqueio) ISNBLQ FROM t_cliente CLI,t_bloqueio blq WHERE cli.isn_cliente=blq.isn_cliente ' +
            'AND cli.ISN_CLIENTE = ' + inttostr(cod_cliente);
  qryRegistro.SQL.Add(strSQL);
  qryRegistro.Open;

//  if not qryRegistro.eof then
//    result := uFuncoes.Pesquisa('ISN_BLOQUEIO','BLODS_MOTIVO','T_BLOQUEIO',qryRegistro.fieldbyname('ISNBLQ').asstring);

  FreeAndNil(DmGlobal);
  FreeAndNil(qryRegistro);
end;


//function TDmChecaCliente.GetBloqueioPedido(objCliente: TCliente; objMonitorPedido: TMonitorPedido;
//strCodFormaPag: string; blnCfopVenda, blnContaAberta: Boolean; intIsnBloqAtual: Integer;
//fltLimite: double): Integer;
//
//var intIsnBloq: Integer;
//    strSeckey:string;
//begin
//  intIsnBloq := 0;
//  strSeckey := dmPrinc.ObjParametro.SECKEY;
//
//  if (not objCliente.Liberado or blnContaAberta) and (blnCfopVenda) then
//  begin
//    if (Pos(Trim(strSeckey),'SRV') > 0) then
//    begin
//      if (Trim(strCodFormaPag) <> 'TC') Then // Transferência entre Contas
//        intIsnBloq := 1; // Cliente Bloqueado  - 1
//    end
//    else
//      intIsnBloq := 1; // Cliente Bloqueado  - 1
//  end;
//
//  if objCliente.BloquearPedido = 'S' then
//    intIsnBloq := 31;
//
//  fltLimite := RoundFloat(fltLimite,2);
//  {**********************LIMITE DE CRÉDITO**********************}
//  if (blnCfopVenda) then
//    begin
//      if Trim(strSeckey)='JEANDIST' Then
//        begin
//          if (fltLimite < 0) and (Trim(strCodFormaPag) <> 'DN') and (Trim(strCodFormaPag) <> 'DA') and
//          (objMonitorPedido.GeraFinanceiro = 'S') Then
//            intIsnBloq := 2; // Cliente Ultrapassou Limite de Crédito
//        end
//      else if Pos(Trim(strSeckey),'SRV') > 0 Then // Cliente Ultrapassou Limite de Crédito
//        begin
//          if (fltLimite < 0) and (Trim(strCodFormaPag) <> 'BN') and (Trim(strCodFormaPag) <> 'DG') then
//            intIsnBloq := 2;
//        end
//      else if (fltLimite < 0) and (Trim(strCodFormaPag) <> 'DN') and (Trim(strCodFormaPag) <> 'DA') then
//        intIsnBloq := 2; // Cliente Ultrapassou Limite de Crédito
//    end;
//  {**********************LIMITE DE CRÉDITO**********************}
//
//  if intIsnBloq > 0 then
//    GetBloqueioPedido := intIsnBloq
//  else
//    GetBloqueioPedido := intIsnBloqAtual;
//
//end;
//

end.
