unit DateModule.BloqueioPedido;

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
  TDmBloqueioPedido = class(TDataModule)
  private
    { Private declarations }
  public
    { Public declarations }
    function Calc_Limite(cod_cliente: Integer): Double;
    function PedidoBloqueado(cod_cliente: Integer; TipoPedido: string; valor_pedido : Double): Integer;

  end;

var
  DmBloqueioPedido: TDmBloqueioPedido;

implementation

const
  KEY = 0;
  VALUE = 1;

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}


function TDmBloqueioPedido.Calc_Limite(cod_cliente: Integer): Double;
var
  qryLimCliente: TFDQuery;
  DmGlobal : TDmGlobal;
  LrlLImite: Real;
  strISNContaReceber: string;
  strSQL: string;
begin
  DmGlobal :=  TDmGlobal.Create(nil);
  qryLimCliente:= TFDQuery.Create(nil);
  qryLimCliente.Connection := DmGlobal.Conn;

  LrlLimite := 0;
  strSQL := '';

  // Verifica na Tabela de Previsão de Contas a Receber Venda
  strSQL := 'SELECT SUM(PR.PVRVL_VALOR) AS DEBITO '+
              'FROM T_PREVISAO_RECEBER PR '+
              'INNER JOIN T_PEDIDO PED ON (PR.ISN_PEDIDO = PED.ISN_PEDIDO) '+
              'INNER JOIN T_FORMA_PAGAMENTO FP ON (FP.ISN_FORMA_PAGAMENTO = PED.ISN_FORMA_PAGAMENTO) ' +
              'INNER JOIN T_CFOP CFO ON (CFO.ISN_CFOP = PED.ISN_CFOP) '+
              'WHERE PVRDT_PRESTACAO_CONTAS IS NULL '+
              'AND FP.FPACN_FORMA <> ''DN'' ' + // Forma de Pagamento Dinheiro
              'AND FP.FPACN_FORMA <> ''DA'' '; // Forma de Pagamento Depósito Antecipado

   { if (strSeckey = 'TETEFOR') or (strSeckey = 'TETEPI') or (strSeckey = 'TETE') then
      strSQL := strSQL + 'AND FP.FPACN_FORMA <> ''BN'' ';}

    strSQL := strSQL +
              'AND CFO.CFOFG_VENDA = ''S'' '+
              ' AND PED.ISN_EMPRESA = ' + intTostr(1) +  //ISN EMPRESA
              ' AND (SELECT COUNT(IPED.ISN_PEDIDO) QTDE FROM T_ITEM_PEDIDO IPED WHERE IPED.ISN_PEDIDO = PED.ISN_PEDIDO) > 0 ' +
              //'AND PED.ISN_PEDIDO_ORIGEM IS NULL '+ //comentado por causa do indice na t_pedido pelo isn_pedido_origem
              'AND PR.ISN_CLIENTE = '+inttostr(cod_cliente);

    qryLimCliente:= TFDQuery.Create(nil);
    qryLimCliente.Connection := DmGlobal.Conn;
    qryLimCliente.sql.Add(strSQL);
    qryLimCliente.open;

  if not qryLimCliente.Eof then
    LrlLimite := LrlLimite + qryLimCliente.FieldByName('DEBITO').AsFloat;
    qryLimCliente.free;

  // Verifica na Tabela de Previsão de Contas a Receber Devolução
   strSQL := '';
   strSQL := 'SELECT SUM(PR.PVRVL_VALOR) AS CREDITO '+
              'FROM T_PREVISAO_RECEBER PR '+
              'JOIN T_PEDIDO PED ON (PR.ISN_PEDIDO = PED.ISN_PEDIDO) '+
              'JOIN T_PEDIDO PED1 ON (PED1.ISN_PEDIDO = PED.ISN_PEDIDO_ORIGEM) '+
              'JOIN T_PREVISAO_RECEBER PR1 ON (PR1.ISN_PEDIDO = PED1.ISN_PEDIDO) '+
              'WHERE PR.PVRDT_PRESTACAO_CONTAS IS NULL '+
              'AND PED.ISN_PEDIDO_ORIGEM IS NOT NULL '+
              'AND PR1.PVRDT_PRESTACAO_CONTAS IS NULL '+
              ' AND PED.ISN_EMPRESA = ' + intTostr(1) +   //isn empresa
              ' AND PR.ISN_CLIENTE = '+inttostr(cod_cliente) +
              ' AND (SELECT COUNT(IPED.ISN_PEDIDO) QTDE FROM T_ITEM_PEDIDO IPED WHERE IPED.ISN_PEDIDO = PED.ISN_PEDIDO) > 0 ';
    qryLimCliente:= TFDQuery.Create(nil);
    qryLimCliente.Connection := DmGlobal.Conn;
    qryLimCliente.sql.Add(strSQL);
    qryLimCliente.open;

  if not qryLimCliente.Eof then
    LrlLimite := LrlLimite - qryLimCliente.FieldByName('CREDITO').AsFloat;
    qryLimCliente.close;

  // Verifica na tabela de Contas a Receber, Status A- Conta Aberta (Devedora)
  strSQL := '';
  strSQL := 'SELECT SUM(CREVL_VALOR) AS DEBITO '+
              'FROM T_PREVISAO_RECEBER T_PCR '+
              'INNER JOIN T_CONTAS_RECEBER T_CRE ON (T_PCR.ISN_PREVISAO_RECEBER = T_CRE.ISN_PREVISAO_RECEBER) '+
              'WHERE CREFG_STATUS = ''A'' '+
              'AND T_PCR.ISN_CLIENTE = '+  inttostr(cod_cliente);

    qryLimCliente:= TFDQuery.Create(nil);
    qryLimCliente.Connection := DmGlobal.Conn;
    qryLimCliente.sql.Add(strSQL);
    qryLimCliente.open;

  if not qryLimCliente.Eof then
    LrlLimite := LrlLimite + qryLimCliente.FieldByName('DEBITO').AsFloat;
  qryLimCliente.close;

  // Verifica se há pagamento parcial do contas a receber
  strSQL := '';
  strSQL := 'SELECT SUM(PP.PPAVL_VALOR) AS CREDITO '+
              'FROM T_PAGAMENTO_PARCIAL PP '+
              'INNER JOIN T_CONTAS_RECEBER CR ON (CR.ISN_CONTAS_RECEBER = PP.ISN_CONTAS_RECEBER) '+
              'INNER JOIN T_PREVISAO_RECEBER PR ON (PR.ISN_PREVISAO_RECEBER = CR.ISN_PREVISAO_RECEBER) '+
              'WHERE CR.CREFG_STATUS = ''A'' '+
              'AND PR.ISN_CLIENTE = '+  inttostr(cod_cliente);

    qryLimCliente:= TFDQuery.Create(nil);
    qryLimCliente.Connection := DmGlobal.Conn;
    qryLimCliente.sql.Add(strSQL);
    qryLimCliente.open;

  if not qryLimCliente.Eof then
    LrlLimite := LrlLimite - qryLimCliente.FieldByName('CREDITO').AsFloat;
    qryLimCliente.close;

  // Verifica se há pedidos sem faturar e tira do limite
  strSQL := '';
  strSQL := 'SELECT SUM(PED.PEDVL_TOTAL) AS DEBITO '+
              'FROM T_PEDIDO PED '+
              'INNER JOIN T_CFOP CFOP ON (PED.ISN_CFOP = CFOP.ISN_CFOP) '+
              'INNER JOIN T_TIPO_PEDIDO TPED ON (TPED.ISN_TIPO_PEDIDO = PED.ISN_TIPO_PEDIDO) ' +
              'INNER JOIN T_FORMA_PAGAMENTO FP ON (FP.ISN_FORMA_PAGAMENTO = PED.ISN_FORMA_PAGAMENTO) ' +
              'WHERE CFOP.CFOFG_VENDA = ''S'' AND TPED.TIPFG_ESTOQUE_LOJA = ''N'' '+
              'AND PEDFG_CANCELADO = ''N'' AND PEDFG_TRANSFERIDO = ''N'' '+
              'AND FP.FPACN_FORMA <> ''DN'' ' + // Forma de Pagamento Dinheiro
              'AND FP.FPACN_FORMA <> ''DA'' ' ; // Forma de Pagamento Depósito Antecipado

   { if (strSeckey = 'TETEFOR') or (strSeckey = 'TETEPI') or (strSeckey = 'TETE') then
      strSQL := strSQL + 'AND FP.FPACN_FORMA <> ''BN'' ';  }

    strSQL := strSQL +
              'AND PED.ISN_CLIENTE = '+ inttostr(cod_cliente) +
              ' AND PED.ISN_EMPRESA = ' + intTostr(1) +  //cod empresa
              ' AND (SELECT COUNT(IPED.ISN_PEDIDO) QTDE FROM T_ITEM_PEDIDO IPED WHERE IPED.ISN_PEDIDO = PED.ISN_PEDIDO) > 0 ';
    qryLimCliente:= TFDQuery.Create(nil);
    qryLimCliente.Connection := DmGlobal.Conn;
    qryLimCliente.sql.Add(strSQL);
    qryLimCliente.open;

  if not qryLimCliente.Eof then
    LrlLimite := LrlLimite + qryLimCliente.FieldByName('DEBITO').AsFloat;
  qryLimCliente.Close;
  qryLimCliente.Free;

  Result := LrlLimite;

end;

function TDmBloqueioPedido.PedidoBloqueado(cod_cliente: Integer; TipoPedido: string; valor_pedido : Double): Integer;
var
  DmGlobal : TDmGlobal;
  strCfop: string;
  qryCfop: TFDQuery;
  strCodCliente: string;
  strSQL: string;
  qryImpAux : TFDQuery;
  Funcoes : TFuncoes;

begin
  Funcoes := Tfuncoes.Create;
  DmGlobal := TDmGlobal.Create(nil);
  qryCfop := TFDQuery.Create(nil);
  qryCfop.Connection := DmGlobal.Conn;
  qryImpAux := TFDQuery.Create(nil);
  qryImpAux.Connection := DmGlobal.Conn;


  Result := Unassigned;

  strCodCliente := cod_cliente.ToString;

  //   2   - Ultrapassou limite de Credito do Cliente
  //   5   - Pedido proposta
  //   7   - Bloqueio Bonificação / Troca
  //  15   - Bloqueio Faturamento PALM
  //  22   - Cliente bloqueado para faturamento
  //  23   - Pedido a negociar

  strCfop := Funcoes.Pesquisa('ISN_TIPO_PEDIDO', 'ISN_CFOP', 'T_TIPO_PEDIDO',
    Trim(TipoPedido));

 { if((ConfiguracaoGlobal.strSeckey = 'TRIGALLE') and
  (GetQtdPedidosAbertoCliente(StrToInt(strCodCliente)) >= 2)) then
  begin
    Result := '40';
  end; }

 { if ( (ConfiguracaoGlobal.strSeckey = 'AZUL') or (ConfiguracaoGlobal.strSeckey = 'GD7') ) then
    if (Pesquisa('ISN_TIPO_PEDIDO', 'TIPFG_VENDA_AVULSA', 'T_TIPO_PEDIDO',
      Trim(TipoPedido)) = 'S') then
    begin
      Result := '32';
    end;   }

  if (funcoes.Pesquisa('ISN_TIPO_PEDIDO', 'TIPFG_PROPOSTA', 'T_TIPO_PEDIDO',
    Trim(TipoPedido)) = 'S') then
  begin
    Result := 5;
  end
  else if (funcoes.Pesquisa('ISN_CFOP', 'CFOFG_BONIFICACAO', 'T_CFOP',
    QuotedStr(strCfop)) = 'S'){ and (ConfiguracaoGlobal.strSeckey <> 'JLDISTXI')} then
  begin
    Result := 7;
  end
  else if (Funcoes.Pesquisa('ISN_CFOP', 'CFOFG_NEGOCIAR', 'T_CFOP', QuotedStr(strCfop)) =
    'S') then
  begin
    Result := 23;
  end
  else
  begin

    strSQL := 'SELECT CLIVL_LIMITE, CLIFG_STATUS FROM T_CLIENTE WHERE ISN_CLIENTE = ' + strCodCliente;
    qryImpAux.Close;
    qryImpAux.SQL.Add(strSQL);
    //qryImp.CommandText :=
    qryImpAux.Open;

    if not qryImpAux.Eof then
    begin

      if qryImpAux.Fields[1].AsString = 'F' then
        Result := 22;

      if (Result = Unassigned) then
        if (not (qryImpAux.Fields[0].IsNull)) then
        begin

          if ((qryImpAux.Fields[0].AsFloat -
            Calc_Limite(strCodCliente.ToInteger))) < valor_pedido  //<(StrToInt(arrPedido[6]) / 100)) and (ConfiguracaoGlobal.strSeckey <> 'JLDISTXI')
          then
            Result := 2
          else
            Result := Unassigned;


        end
        else
        begin
                                                      //valor pedido?
          if ((Calc_Limite(strCodCliente.ToInteger)))< valor_pedido then               //(StrToInt(arrPedido[6]) / 100)) then
            Result := 2
          else
            Result := Unassigned;
        end;

    end;

  end;
  qryImpAux.Close;
  qryImpAux.Free;
  qryImpAux := nil;


  FreeAndNil(Funcoes);

end;

end.
