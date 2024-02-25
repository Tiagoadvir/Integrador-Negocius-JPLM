unit UFuncoes;

interface

Uses System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, System.Variants, UProdutoNegocius,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, Biblioteca ,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.FMXUI.Wait, System.JSON,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.DApt,
  FMX.Dialogs,System.Generics.Collections;

 type
  TExecuteOnCheck = procedure Of Object;

  TStringArray = array of string;
  TDoubleArray = array of Double;
  TPairKeyValue = Array[0..2] of string;

  Worker = class(TThread)

end;

   {---DESCONTO //Método Aplica Desconto (Semelhante a digitação interna)---}
   TDescontoAcrescimo = Record

   //calcula desconto acrescimo
   Desconto : Double;
   Acrescimo : Double;
   {--------------------------}
   End;


  TClientePreCadastrado = class
  public
    Isn: string;
    Codigo: string;
    Tipo: string;
  end;


   TTipoPedido = record
    IsnTipoPedido: Integer;
    IsnCfop: Integer;
  end;

    TConfiguracaoGlobal = record
    ExtraDentroEstado: TTipoPedido;
    ExtraForaEstado: TTipoPedido;
    ControlaEstoqueFiscal : Boolean;
    PermiteEstoqueNegativo : Boolean;
    FatIndepEstoque : Boolean;
    strSeckey : String;
    Cidade : string;
    strIntegraSysPDV, strPreVendPdvJPLM : string;
  end;

  TListCampoValorBD = class
    { Public declarations }
    objlstCampoValorBD: TObjectList<TListCampoValorBD>;
  end;

 TFuncoes = class
  private
    {--------- VARIÁVEIS DE EXECUÇÃO ------------}
    intRepresentante: integer;
    strIsnCfop: string;
    arrPedido: TStringArray;
    blnEstoqueVirtual : Boolean;
    strIsnCliente : string;

    {--------------------------------------------}
    intDivCasaDecimal : integer;
    intNumCasaDecimal : integer;


     FCod_Cliente: Integer;
    Ftipo_pedido: String;
    FCod_pedido_local: Int64;
    Fisn_cfop: Integer;
    FUsa_Palta: string;
    FCod_cond_pag: Integer;
    Fdata_pedido: TDateTime;
    Fvalor_total: Double;
    Fisn_usuario_negocius: Integer;
    Fisn_empresa: integer;
    Fcod_usuario: integer;
    Fpedfg_palm: string;
    Fisn_bloqueio: Integer;
    Fcod_pedido_oficial: integer;
    Fisn_pedido: integer;
    Fpedfg_virtual: string;
    Fpeddt_implantado: TDateTime;
    Fpedfg_pauta: string;
    Fpedfg_implantado: string;
    Fpednr_carga_manifesto: integer;
    Fobs: string;
    Feddt_inclusao: TDateTime;

    function GetQtdPedidosAbertoCliente(IntIsnCliente: Integer): Integer;
    function Calc_Limite(lngIsnCliente: Integer): Double;
    function CalculaValores(Digitado, Atual: Double): TDoubleArray;
    function RoundFloat(Value: Extended; Digits: Integer): Extended;
    function Observacao(obs2: string): string;
    function getValorTaxaCliente(strIsnClienteP, strIsnFormaPagamentoP: string): Double;
    function PegaPreco(strProduto: string; dtValidade: TDateTime;
                       intTabela: integer; intRegiao, intPrazo: longint;
                       dblQuantidade: double): double;
    function PegaPrecoIsn(strProduto: string; dtValidade: TDateTime;
      intTabela: integer; intRegiao, intPrazo: longint): double;
    function VirgPont(Valor: double): string;
    function FloatType(num: string): string;

    function PesquisaNum(parCampo1, parCampo2, parTabela, parValor: string): string;
    function setStatusPedido(st, pd: String): Boolean;
//    function AddColumnAndValueToListSqlInsert(strField, strValue: string;
//      lstCampoValorBD: TListCampoValorBD): TListCampoValorBD;

   function PesqCampos(strTabela: string; arrCampos, arrValores: array of string; strResultado: string): string;
   function NumeroPreco(strCliente, strRepresentante: string): integer;

    procedure aplicaDesconto(strPercDesc: string; dblIPEVL_PRE_DIG,
      dblIPEVL_UNITARIO, dblIPEVL_PRECO_TABELA: Double; strCodCli, strCodRepCli,
      strCodProd: string; dtmDataPedido: TDateTime; intIsnRegiao,
      intCodPrazo: integer; dblQuant: Double; strTPForma: string);


public
 ConfiguracaoGlobal: TConfiguracaoGlobal;

       property Cod_Cliente: Integer read FCod_Cliente write FCod_Cliente; //1: //ISN_CLIENTE
       property tipo_pedido: String read Ftipo_pedido write Ftipo_pedido;    //7: //ISN_TIPO_PEDIDO
       property Cod_pedido_local: Int64  read FCod_pedido_local write FCod_pedido_local; //9: //ISN_PEDIDO_PALM
       property isn_cfop: Integer read Fisn_cfop write Fisn_cfop;    //13: //ISN_CFOP
       property Usa_Palta: string read FUsa_Palta write FUsa_Palta;
       property Cod_cond_pag: Integer read FCod_cond_pag write FCod_cond_pag; //2: //ISN_FORMA_PAGAMENTO    //15: //ISN_PRAZO
       property data_pedido: TDateTime read Fdata_pedido write Fdata_pedido; //3: //PEDDT_PEDIDO
       property valor_total : Double read Fvalor_total  write Fvalor_total ; //4: //PEDVL_TOTAL
       property isn_bloqueio: Integer read Fisn_bloqueio write Fisn_bloqueio; //5: //ISN_BLOQUEIO
      // property isn_pedido: integer read Fisn_pedido write Fisn_pedido;   //8: //ISN_PEDIDO
       property cod_pedido_oficial: integer read Fcod_pedido_oficial write Fcod_pedido_oficial;       //0: //PEDCN_PEDIDO
       property cod_usuario: integer read Fcod_usuario write Fcod_usuario;  //10: //ISN_REPRESENTANTE
       property pedfg_implantado: string read Fpedfg_implantado write Fpedfg_implantado;  //11: //PEDFG_IMPLANTANDO  //Colocar "S" apenas no final da importação para só então conseguir imprimir Chamado 23201 (Graves e Agudos)
       property peddt_inclusao: TDateTime read Feddt_inclusao write Feddt_inclusao;  //12: //PEDDT_INCLUSAO   QuotedStr(FormatDateTime('MM/DD/YYYY HH:MM:00', Now));
       property isn_usuario_negocius: Integer read Fisn_usuario_negocius write Fisn_usuario_negocius; //14: //ISN_USUARIO
      // property pedfg_palm : string read Fpedfg_palm  write pedfg_palm ;  //16: //PEDFG_PALM
       property pedfg_virtual: string read Fpedfg_virtual write Fpedfg_virtual;  //17: //PEDFG_VIRTUAL
       property isn_empresa: integer read Fisn_empresa write Fisn_empresa; //18: //ISN_EMPRESA
       property  pedfg_pauta: string read Fpedfg_pauta write Fpedfg_pauta;
       property  pednr_carga_manifesto: integer read Fpednr_carga_manifesto write Fpednr_carga_manifesto; //20: //PEDNR_CARGA_MANIFESTO
       property  obs: string read Fobs write Fobs;  //6: //PEDDS_OBSERVACAO



      function Pesquisa(parCampo1, parCampo2, parTabela,parValor: string): string;
      function CarregarConfiguracoesGlobais: TConfiguracaoGlobal;
      function StringToDate (str : string): TDate;
      function NovoISN(Tabela: string): string; overload;
      function NovoISN(Tabela: string; Codigo: Boolean): string;  overload;
      function NumeroPedidoOficial(): string;
      function PedidoBloqueado(isn_cliente: string; TipoPedido: string): string;
      function isn_und_vend_prod(isn_produto: Integer): Integer;
      function custo_final_produto(isn_produto: Integer): Double;
      function ConsultaNumeroPreco(isn_cliente, cod_representante {usuario} : Integer) : Integer;
      function unidade_venda_produto(isn_produto: integer): Integer;
      function ProxSeq(parPedido: integer): integer;
      function Desconto( preco_preco_unitario, preco_digitado : Double) :  Double;
      function Acrescimo(preco_digitado , preco_preco_unitario : Double) :  Double;
      //sem uso


      function BloqueioPedValorMinimo (isn_pedido: Integer) : Integer;
      function PercentualDescPrazo(cod_prazo : Integer) : Integer;
      function Reserva_Estoque(isn_produto: Integer; Qtd:real; parTipo: string = 'V'; parFat: string = 'S'): string;

      function Iif(Teste: Boolean; ValorTrue, ValorFalse:String): String; overload;
      function Iif(Teste: Boolean; ValorTrue, ValorFalse:Real): Extended; overload;
      function Iif(Teste: Boolean; ValorTrue, ValorFalse:Integer): Integer; overload;
      function ConsultaCFOP(TipoPedido: string): Integer;
      function Cli_Usa_Palta(isn_cliente: Integer): String;

 var
     tpFiscal: string;
     tpDentroEstado: Boolean;
     isn_pedido : integer;

 //Método Aplica Desconto (Semelhante a digitação interna)
    dblResIPEVL_PRE_DIG ,dblResIPEVL_UNITARIO, dblResIPEVL_PRECO_TABELA,
    dblResIPEPR_DESCONTO, dblResIPEVL_ACRESCIMO, dblResIPEVL_DESCONTO, dblResPrDesc : Double;
    intResPreco : integer;
    intCodPrazo : integer;
    strTP_Forma : string;
    blnUtilizaPaf : Boolean;

const

  {----- NOMES DAS SECOES ------}
  SECAO_CLIENTES = 'CLIE_EXP';
  SECAO_PEDIDOS = 'PEDI_EXP';
  SECAO_ITENS = 'ITPP_EXP';
  SECAO_TITULOS_PAGOS = 'TIAT_EXP'; //PPAG_EXP
  {-----------------------------}

  BloqueiaPedido = 'S';
  DesbloqueiaPedido = 'S';

  {----- TAMANHOS DAS SECOES -----}
    //  Versao 1.7  //
  TAM_CLIENTES_V17 = 27;
  TAM_PEDIDOS_V17 = 12;
  TAM_ITENS_V17 = 4;
  TAM_PREVISAO_RECEBER_V17 = 9;
  TAM_CONTAS_RECEBER_V17 = 14;
  TAM_PAGAMENTO_PARCIAL_V17 = 10;
  TAM_LIVRO_CAIXA_V17 = 10;
  {-------------------------------}

  NULL = 'NULL';
  KEY = 0;
  VALUE = 1;


  {----- CAMPOS RELACIONADOS AS SECOES ------}
  // Versao 1.7 //
  CAM_PEDIDOS_V17: array[0..22] of string = ('PEDCN_PEDIDO', 'ISN_CLIENTE',
    'ISN_FORMA_PAGAMENTO', 'PEDDT_PEDIDO', 'PEDVL_TOTAL', 'ISN_BLOQUEIO',
    'PEDDS_OBSERVACAO', 'ISN_TIPO_PEDIDO', 'ISN_PEDIDO', 'ISN_PEDIDO_PALM',
    'ISN_REPRESENTANTE', 'PEDFG_IMPLANTADO', 'PEDDT_INCLUSAO', 'ISN_CFOP',
    'ISN_USUARIO', 'ISN_PRAZO', 'PEDFG_PALM', 'PEDFG_VIRTUAL', 'ISN_EMPRESA',
    'PEDFG_PAUTA', 'PEDNR_CARGA_MANIFESTO','PEDPR_DESC','PEDVL_TAXA_CLIENTE');

  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  //CUIDADO: AO ALTERAR O PEDIDO, COLOCAR UMA CHAVE EQUIVALENTE NA ARRAY ABAIXO
  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  CAM_ORCAMENTO_V17: array[0..18] of string = ('ORCCN_ORCAMENTO', 'ISN_CLIENTE',
    'ISN_FORMA_PAGAMENTO', 'ORCDT_ORCAMENTO', 'ORCVL_TOTAL', 'ISN_BLOQUEIO',
    'ORCDS_OBSERVACAO', 'ISN_TIPO_PEDIDO', 'ISN_ORCAMENTO', 'ISN_ORCAMENTO_PALM',
    'ISN_REPRESENTANTE', 'ORCFG_IMPLANTADO', 'ORCDT_INCLUSAO', 'ISN_CFOP',
    'ISN_USUARIO', 'ISN_PRAZO', 'ORCFG_PALM', 'ORCFG_VIRTUAL', 'ISN_EMPRESA');

  CAM_ITENS_V17: array[0..21] of string = ('ISN_PEDIDO', 'ISN_PRODUTO',
    'IPEQT_QUANTIDADE', 'IPEQT_QUANTIDADE_PALM', 'IPEVL_UNITARIO',
    'IPEVL_UNITARIO_PALM', 'ISN_ITEM_PEDIDO', 'IPENR_SEQUENCIAL', 'IPEPR_DESCPED',
    'IPEVL_DESCONTO', 'IPEVL_ACRESCIMO', 'IPEVL_PRE_DIG', 'ISN_UNIDADE_VENDA',
    'IPEVL_CUSTO_FINAL', 'IPEQT_UNIDADE_VENDA', 'ISN_CFOP', 'IPEVL_ULT_PRE',
    'IPEVL_PRECO_TABELA', 'IPEFG_FATURA', 'IPEPR_DESCONTO', 'IPENR_PRECO', 'ISN_EMPRESA');

  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  //CUIDADO: AO ALTERAR OS ITENS, COLOCAR UMA CHAVE EQUIVALENTE NA ARRAY ABAIXO
  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  CAM_ITENS_ORC_V17: array[0..19] of string = ('ISN_ORCAMENTO', 'ISN_PRODUTO',
  'IORCQT_QUANTIDADE', 'IORCQT_QUANTIDADE_PALM', 'IORCVL_UNITARIO',
  'IORCVL_UNITARIO_PALM', 'ISN_ITEM_ORCAMENTO', 'IORCNR_SEQUENCIAL', 'IORCPR_DESCPED',
  'IORCVL_DESCONTO', 'IORCVL_ACRESCIMO', 'IORCVL_PRE_DIG', 'ISN_UNIDADE_VENDA',
  'IORCVL_CUSTO_FINAL', 'IORCQT_UNIDADE_VENDA', 'ISN_CFOP', 'IORCVL_ULT_PRE',
  'IORCVL_PRECO_TABELA', 'IORCFG_FATURA', 'ISN_EMPRESA');

  CAM_CLIENTES_V17: array[0..34] of string = ('CLINR_CPF', 'CLINR_CGC',
    'ISN_CLIENTE', 'CLICN_CLIENTE', 'CLINM_CLIENTE', 'CLIDT_CADASTRO',
    'CLIDS_ENDERECO_COBRANCA', 'ISN_TIPO_CLIENTE', 'ISN_BAIRRO',
    'CLINR_CEP_COBRANCA', 'CLINR_FONE_COBRANCA', 'CLINR_CGF', 'CLINM_FANTASIA',
    'CLINM_UF', 'CLINM_CIDADE', 'CLINM_BAIRRO', 'ISN_ROTA', 'CLIFG_PORTE',
    'CLIFG_INATIVO', 'CLIFG_NAO_EXPORTA_PALM', 'CLINR_FONE_FATURAMENTO',
    'CLIDS_ENDERECO_FATURAMENTO', 'CLICN_NUMERO_END_FAT', 'ISN_ATIVIDADE',
    'CLINR_CEP', 'ISN_USUARIO', 'CLICN_CODIGO_ROTA', 'ISN_GRUPO_EMPRESARIAL',
    'ISN_BAIRRO_COBRANCA', 'CLIDS_ENDERECO_ENTREGA', 'CLINR_FONE_ENTREGA',
    'ISN_BAIRRO_ENTREGA', 'CLICN_NUMERO_END_ENT', 'CLICN_NUMERO_COB',
    'CLIFG_STATUS');

  CAM_PREVISAO_RECEBER_V17: array[0..8] of string = ('ISN_PREVISAO_RECEBER', 'ISN_FORMA_PAGAMENTO',
  'PVRNR_PARCELA', 'ISN_PEDIDO', 'PVRDT_VENCIMENTO', 'ISN_CLIENTE', 'PVRVL_VALOR',
  'ISN_REPRESENTANTE', 'PVRDT_DOCUMENTO');

  CAM_CONTAS_RECEBER_V17: array[0..13] of string = ('ISN_CONTAS_RECEBER', 'ISN_PREVISAO_RECEBER',
  'ISN_FORMA_PAGAMENTO', 'CRENR_PARCELA', 'CREDT_VENCIMENTO', 'CREVL_VALOR', 'CREDT_DOCUMENTO',
  'CREDT_PAGAMENTO', 'CREVL_PAGO', 'CREFG_STATUS', 'CREDS_HISTORICO', 'ISN_USUARIO', 'ISN_USUARIO_LANCAMENTO', 'ISN_EMPRESA');

  CAM_PAGAMENTO_PARCIAL_V17: array[0..9] of string = ('ISN_PAGAMENTO_PARCIAL', 'ISN_CONTAS_RECEBER',
  'PPADT_PAGAMENTO', 'PPAVL_VALOR', 'PPAVL_JUROS', 'PPADT_INCLUSAO', 'ISN_MOTIVO',
  'PPADS_OBSERVACAO', 'ISN_EMPRESA', 'ISN_USUARIO');

  CAM_LIVRO_CAIXA_V17: array[0..9] of string = ('ISN_LIVRO_CAIXA', 'ISN_CONTA_RECEBER',
  'ISN_CONTA_ORIGEM', 'ISN_CONTA_DESTINO', 'CNDDS_HISTORICO', 'CNDDT_LANCAMENTO', 'CODVL_VALOR',
  'LCXFG_FORMA_PAGAMENTO', 'ISN_USUARIO', 'ISN_EMPRESA');

  CAM_REPRESENTANTE_X_CLIENTE_V17: array[0..1] of string = ('ISN_CLIENTE', 'ISN_REPRESENTANTE');

  var
  CAM_ORCAMENTO_EQ_V17: array[0..2] of ^TPairKeyValue;


  strSecKey : string;


end;

implementation
Uses
  DateModule.Global{, uPedido};


function TFuncoes.NumeroPreco(strCliente, strRepresentante: string): integer;
var strPreco: string;
  strEquipe: string;
  strdtPreco: string;
  dtPreco: TDateTime;
  strPrecoTemp: string;
  strdtPrecoTemp: String;
begin
  strPreco   := PesqCampos('T_CLIENTE', ['CLICN_CLIENTE'], [strCliente], 'CLINR_PRECO');
  strdtPreco := PesqCampos('T_CLIENTE', ['CLICN_CLIENTE'], [strCliente], 'CLIDT_PRECO_VENDA');

  strPrecoTemp := '';
  strdtPrecoTemp := '';

  if (ConfiguracaoGlobal.strSeckey = 'DONIZETE') then
    begin
      strPrecoTemp   := PesqCampos('T_CLIENTE', ['CLICN_CLIENTE'], [strCliente], 'CLINR_PRECO_TEMP');
      strdtPrecoTemp := PesqCampos('T_CLIENTE', ['CLICN_CLIENTE'], [strCliente], 'CLIDT_PRECO_VENDA_TEMP');
    end;

  if strdtPreco <> '' then // Quando a Data do Preco na T_CLIENTE estiver em branco , valera para sempre
   begin
     dtPreco := strtodate(strdtPreco);
     if dtPreco < Now then // Quando a Data do Preco na T_CLIENTE for ultrapassada , não valera mais aquele preço
      strPreco := '';
   end;

  if ( (strPreco = '') or (strToint(strPreco) <= 0) ) then
   strPreco := PesqCampos('T_REPRESENTANTE', ['REPCN_REPRESENTANTE'], [strRepresentante], 'REPNR_PRECO');

  if ( (strPreco = '') or (strToint(strPreco) <= 0) ) then
   strPreco := PesqCampos('T_EQUIPE_VENDA', ['EQUCN_EQUIPE'], [strRepresentante], 'EQUNR_PRECO');

  if ( (strPreco = '') or (strToint(strPreco) <= 0) ) then
   strPreco := '1';


  if (strdtPrecoTemp <> '') and (strPrecoTemp <> '') then // Quando a Data do Preco na T_CLIENTE estiver em branco , valera para sempre
   begin
     dtPreco := strtodate(Copy(strdtPrecoTemp,1,10));
     if dtPreco >= Now then // Quando a Data do Preco na T_CLIENTE for ultrapassada , não valera mais aquele preço
      strPreco := strPrecoTemp;
   end;

  NumeroPreco := StrToInt(strPreco);
end;

//Gera Sequencial do item do pedido
function TFuncoes.ProxSeq(parPedido: integer): integer;
var
  qryRegistro: TFDQuery;
  DmGlobal: TdmGlobal;
  strSQL : string;
begin
  try
    DmGlobal := TDmGlobal.Create(nil);
    qryRegistro := TFDQuery.Create(nil);
    qryRegistro.Connection := DmGlobal.Conn;
    strSQL := ' SELECT MAX(IPENR_SEQUENCIAL) FROM T_ITEM_PEDIDO ' +
      ' WHERE ISN_PEDIDO = ' + inttostr(parPedido);
    qryRegistro.SQL.Add(strSQL);
    qryRegistro.Open;
    if not qryRegistro.eof then
    begin
      result := qryRegistro.Fields[0].AsInteger + 1;
    end;
    qryRegistro.close;
  finally
    qryRegistro.free;
  end;
  FreeAndNil(DmGlobal);
end;


function StrToFloatDef(const S: string; const Default: Extended): Extended;
begin
  if not TextToFloat(PChar(S), Result, fvExtended) then
    Result := Default;
end;

function Tfuncoes.CarregarConfiguracoesGlobais: TConfiguracaoGlobal;
var
  qryConf : TFDQuery;
  strSQL : String;
  recResult : TConfiguracaoGlobal;
  CFOP : STRING;
begin
  //Identifica CFOP de Venda e Tipo de Pedido EXTRA dentro do estado
  strSQL := 'SELECT  CFO.ISN_CFOP,TPE.isn_tipo_pedido FROM T_CFOP CFO,T_TIPO_PEDIDO TPE ' +
            'WHERE CFO.isn_cfop = TPE.isn_cfop ' +
            'AND TPE.tipfg_gera_financeiro = ''S'' ' +
            'AND TPE.tipfg_nota_fiscal = ''N'' ' +
            'AND CFOFG_DESTINO = ''S'' AND CFOFG_VENDA = ''S'' AND CFOFG_DENTRO_UF = ''S'' ';

  qryConf := TFDQuery.Create(nil);
  qryConf.Connection := DmGlobal.Conn;

  try
    qryConf.SQL.Add(strSQL);
    qryConf.Open;
    if not qryConf.eof then
    begin
     recResult.ExtraDentroEstado.IsnTipoPedido := qryConf.fields[1].AsInteger;
     recResult.ExtraDentroEstado.IsnCfop := qryConf.fields[0].AsInteger;
    end;
  finally
    qryConf.close;
  end;

  //Identifica CFOP de Venda e Tipo de Pedido EXTRA fora do estado
  strSQL := 'SELECT  CFO.ISN_CFOP,TPE.isn_tipo_pedido FROM T_CFOP CFO,T_TIPO_PEDIDO TPE ' +
            'WHERE CFO.isn_cfop = TPE.isn_cfop ' +
            'AND TPE.tipfg_gera_financeiro = ''S'' ' +
            'AND TPE.tipfg_nota_fiscal = ''N'' ' +
            'AND CFOFG_DESTINO = ''S'' AND CFOFG_VENDA = ''S'' AND CFOFG_DENTRO_UF <> ''S'' ';

  try
    qryConf.SQL.Add(strSQL);
    qryConf.Open;
    if not qryConf.eof then
    begin
     recResult.ExtraForaEstado.IsnTipoPedido := qryConf.fields[1].AsInteger;
     recResult.ExtraForaEstado.IsnCfop := qryConf.fields[0].AsInteger;
    end;
  finally
    qryConf.close;
  end;


  //Identifica parâmetros
  strSQL := 'SELECT P.PARDS_IDENTIFICADOR_PARAMETRO, P.PARDS_CONTEUDO '+
            'FROM T_PARAMETRO P '+
            'WHERE P.PARDS_IDENTIFICADOR_PARAMETRO IN (''PAR_CONTR_EST_FISC'', ''PAR_EST_NEG'', ''PAR_FAT_INDEP_ESTOQUE'') ';
  try
    qryConf.SQL.Add(strSQL);
    qryConf.Open;
    if not qryConf.eof then
    begin
      if(qryConf.Locate('PARDS_IDENTIFICADOR_PARAMETRO', 'PAR_CONTR_EST_FISC', [loCaseInsensitive]))then
        recResult.ControlaEstoqueFiscal := qryConf.Fields[1].AsString = 'S';

      if(qryConf.Locate('PARDS_IDENTIFICADOR_PARAMETRO', 'PAR_EST_NEG', [loCaseInsensitive]))then
        recResult.PermiteEstoqueNegativo := qryConf.Fields[1].AsString = 'S';

      if(qryConf.Locate('PARDS_IDENTIFICADOR_PARAMETRO', 'PAR_FAT_INDEP_ESTOQUE', [loCaseInsensitive]))then
        recResult.FatIndepEstoque := qryConf.Fields[1].AsString = 'S';

    end;
  finally
    qryConf.close;
  end;

  //Identifica parâmetros
  strSQL := 'SELECT CONF.CFGCN_CODEMP, CONF.CFGNM_CIDADE '+
            'FROM T_CONFIGURACAO CONF ';
  try
    qryConf.SQL.Add(strSQL);
    qryConf.Open;
    if not qryConf.eof then
    begin
      recResult.strSeckey := qryConf.Fields[0].AsString;
      recResult.Cidade := qryConf.Fields[1].AsString;
    end;
  finally
    qryConf.close;
  end;


  strSQL := 'SELECT PARDS_CONTEUDO '+
            'FROM T_PARAMETRO PAR WHERE PAR.PARDS_IDENTIFICADOR_PARAMETRO = ''PAR_INTEG_NEGOCIUS_SYSPDV'' ';
  try
    qryConf.SQL.Add(strSQL);
    qryConf.Open;
    if not qryConf.eof then
    begin
      recResult.strIntegraSysPDV := qryConf.Fields[0].AsString;
    end;
  finally
    qryConf.close;
  end;

  strSQL := 'SELECT PARDS_CONTEUDO '+
            'FROM T_PARAMETRO PAR WHERE PAR.PARDS_IDENTIFICADOR_PARAMETRO = ''PAR_PREVENDA_PDV_JPLM'' ';
  try
    qryConf.SQL.Add(strSQL);
    qryConf.Open;
    if not qryConf.eof then
    begin
      recResult.strPreVendPdvJPLM := qryConf.Fields[0].AsString;
    end;
  finally
    qryConf.close;
  end;

  Result := recResult;
end;

  //observação do cadastro do cliente
function TFuncoes.Observacao(obs2: string): string;
var
    strObsReturn: string;
    cliente: TFDQuery;
    DmGlobal : TDmGlobal;
begin
    DmGlobal := TDmGlobal.Create(nil);
    cliente := TFDQuery.Create(nil);
    cliente.Connection:= DmGlobal.Conn;

   strObsReturn := obs2;
  if(ConfiguracaoGlobal.strSeckey = 'DDCOMERCIO') then
  begin
    cliente.SQL.Clear;
    cliente.sql.Add('SELECT CLI.CLIDS_OBS FROM T_CLIENTE CLI WHERE CLI.ISN_CLIENTE = :ISN_CLIENTE');
    cliente.ParamByName('iISN_CLIENTE').Value := Cod_Cliente;
    cliente.Active := True;

    strObsReturn := obs2 + ' - ' +  CLIENTE.FieldByName('CLIDS_OBS').AsString;

  end;

  if (strObsReturn = '') then
    Result := 'NULL'
  else
    Result := quotedStr(strObsReturn);
    FreeAndNil(DmGlobal);
end;


//gera numero pedido
function TFuncoes.NumeroPedidoOficial(): string;
var
  Resultado: string;
  Pilha : Integer;
  strSQL : string;
  DmGlobal : TDmGlobal;
  qryImpAux : TFDQuery;

begin
  try
    Pilha := 0;
    DmGlobal := TDmGlobal.Create(nil);
    qryImpAux := TFDQuery.Create(nil);
    qryImpAux.Connection:= DmGlobal.Conn;

    strSQL := 'SELECT MAX(PED.PEDCN_PEDIDO)+1 MAXIMO FROM T_PEDIDO PED';
    qryImpAux.Close;
    qryImpAux.SQL.Add(strSQL);
    //qryImp.CommandText :=
    qryImpAux.Open;
    Pilha := 1;
    if not qryImpAux.Eof then
      Resultado := qryImpAux.Fields[0].AsString
    else
      Resultado := '0';

    qryImpAux.Close;
    qryImpAux.Free;
    qryImpAux := nil;

    Result := Resultado;
  except
    on E: Exception do
    begin
     // Show ('AVISO (NovoCN): ' + E.Message + '|Impossivel localizar PEDCN novo.');
    end;
  end;
  FreeAndNil(DmGlobal);
end;

  // Calcula Desconto  Automático  //Ok Testado Tiago.
function Tfuncoes.Desconto( preco_preco_unitario, preco_digitado : Double) :  Double;
  var
    ValorDesconto: double;
begin
       ValorDesconto := 0;

      if  (preco_digitado > 0) then
      begin

        if preco_preco_unitario > preco_digitado then
          // Calcula Desconto
          ValorDesconto := (preco_preco_unitario - preco_digitado)
      end ;

      Result := ValorDesconto;

end;

  // Calcula  acréscimo Automático  //ok testado Tiago
function Tfuncoes.Acrescimo( preco_digitado, preco_preco_unitario : Double) :  Double;
  var
    acrescimo: double;
begin
        Acrescimo := 0;
      if  (preco_digitado > 0) then
      begin

       if preco_preco_unitario < preco_digitado then
          // Calcula Acréscimo
          acrescimo := (preco_digitado - preco_preco_unitario);
      end;

      Result := acrescimo;
end;


// gera o Isn_pedido
function TFuncoes.NovoISN(Tabela: string): string;
var
  Resultado: string;
  Pilha : Integer;
  strSQL : string;
  DmGlobal : TDmGlobal;

  qryISN : TFDQuery;

  lngISN: longint;
  lngMaxISN: longint;
  strGenerator :String;
begin

  if ((trim(Tabela) = 'T_ITEM_PEDIDO') or (trim(Tabela) = 'T_PEDIDO')) { and not(blnUtilizaPaf)} then
  begin
    DmGlobal := TDmGlobal.Create(nil);
    qryISN := TFDQuery.Create(nil);
    qryISN.Connection:= DmGlobal.Conn;

    try
      Pilha := 0;
      DmGlobal.Conn.StartTransaction;
      Try
        strGenerator := 'GEN_'+ Copy(Tabela,3,length(Tabela));


        strSQL := 'SELECT GEN_ID('+ strGenerator +',1) FROM RDB$DATABASE ';

        qryISN.SQL.Add(strSQL);
        qryISN.Open;
        qryISN.First;

        Pilha := 1;
        if not (qryISN.Eof) then
          lngISN := qryISN.Fields[0].AsInteger;

        Pilha := 2;

        Result := inttostr(lngISN);

        // Fecha DataSet
        qryISN.Free;

        // Encerra transação
        DmGlobal.Conn.Commit;
      except
        on E: Exception do
          begin
            qryISN.Free;
            DmGlobal.Conn.Rollback;
           // raise ('Erro no ISN: ' + E.Message + ' da tabela:' + Tabela, Pilha.ToString);
            //Gera_Isn(parTabela);
          end;
      end;

    finally
      result := inttostr(lngISN);
    end;
  end
  else
  begin
    try
      DmGlobal := TDmGlobal.Create(nil);
      qryISN := TFDQuery.Create(nil);
      qryISN.Connection:= DmGlobal.Conn;

      strSQL := 'SELECT ISNNR_SEQUENCIAL+1 MAXIMO FROM T_ISN WHERE ISNDS_TABELA = ''' + Tabela + '''';
      qryISN.Close;
      qryISN.SQL.Add(strSQL);
      //qryImp.CommandText :=
      qryISN.Open;
      Pilha := 1;
      if not qryISN.Eof then
      begin
        Resultado := qryISN.Fields[0].AsString;
        if (Resultado <> '') then
          qryISN.ExecSQL('UPDATE T_ISN SET ISNNR_SEQUENCIAL = ' + Resultado +
            ' WHERE ISNDS_TABELA = ''' + Tabela + '''');
      end
      else
        Resultado := '0';
      Pilha := 2;

      qryISN.Close;
      qryISN.Free;
      qryISN := nil;

      Result := Resultado;
    except
      on E: Exception do
      begin
      //  Verbose('AVISO (NovoISN): ' + E.Message + '|Impossivel localizar ISN_PEDIDO novo.', Pilha);
      end;
    end;
  end;
  FreeAndNil(DmGlobal);
end;

//GENSQ_PEDIDO GERA SEQUANCIAL DO PEDIDO     (numero pedido)
function TFuncoes.NovoISN(Tabela: string; Codigo: Boolean): string;
var
  Resultado: string;
  Pilha : Integer;
  strSQL : string;
  qryImpAux : TFDQuery;
  DmGlobal : TDmGlobal;

  lngSeq: longint;
  qrySeq : TFDQuery;
  strGenerator :String;
begin

  if (Trim(Tabela) = 'T_PEDIDO') {and not(blnUtilizaPaf) } then
  begin
      DmGlobal := TDmGlobal.Create(nil);
      qrySeq := TFDQuery.Create(nil);
      qrySeq.Connection:= DmGlobal.Conn;
    try
      DmGlobal.Conn.StartTransaction;
      Try
        strGenerator := 'GENSEQ_'+ Copy(Tabela,3,length(Tabela));

        strSQL := 'SELECT GEN_ID('+ strGenerator +',1) FROM RDB$DATABASE ';
        Pilha := 0;
        qrySeq.SQL.Add(strSQL);
        qrySeq.Open;
        qrySeq.First;
        Pilha := 1;
        if not (qrySeq.Eof) then
          lngSeq := qrySeq.Fields[0].AsInteger;
        Pilha := 2;

        Result := inttostr(lngSeq);
        // Fecha DataSet
        qrySeq.Free;

        // Encerra transação
        DmGlobal.Conn.Commit;
      except
        on E: Exception do
          begin
            qrySeq.Free;
            DmGlobal.Conn.Rollback;

//            Errados.Add(fileBeingImported);
//            Verbose('Erro no SEQUENCIAL: ' + E.Message + ' da tabela:' + Tabela, Pilha);
            //AddLog('Erro no SEQ: ' + E.Message + ' da tabela:' + partabela);

          end;
      end;
    finally
      result := inttostr(lngSeq);
    end;

  end
  else
  begin
    try
      Pilha := 0;
      DmGlobal := TDmGlobal.Create(nil);
      qrySeq := TFDQuery.Create(nil);
      qrySeq.Connection:= DmGlobal.Conn;
      qrySeq.Close;
      if (not Codigo) then
      begin
        strSQL := 'SELECT ISNNR_SEQUENCIAL+1 MAXIMO FROM T_ISN WHERE ISNDS_TABELA = ''' + Tabela + '''';
        qrySeq.SQL.Add(strSQL);
        //qryImp.CommandText :=
      end
      else
      begin
        strSQL := 'SELECT ISNNR_CODIGO+1 MAXIMO FROM T_ISN WHERE ISNDS_TABELA = ''' + Tabela + '''';
        qrySeq.SQL.Add(strSQL);
        //qryImp.CommandText :=
      end;
      qrySeq.Open;
      Pilha := 1;
      if not qrySeq.Eof then
      begin
        Resultado := qrySeq.Fields[0].AsString;
        if (Resultado <> '') then
        begin
          if (not Codigo) then
           qrySeq.ExecSQL('UPDATE T_ISN SET ISNNR_SEQUENCIAL = ' + Resultado +
              ' WHERE ISNDS_TABELA = ''' + Tabela + '''')
          else
            qrySeq.ExecSQL('UPDATE T_ISN SET ISNNR_CODIGO = ' + Resultado +
              ' WHERE ISNDS_TABELA = ''' + Tabela + '''');

        end;
      end
      else
        Resultado := '0';
      Pilha := 2;

      qrySeq.Close;
      qrySeq.Free;
      qrySeq := nil;
      Result := Resultado;
    except
      on E: Exception do
      begin
//        Errados.Add(fileBeingImported);
//        Verbose('AVISO (NovoISN): ' + E.Message + '|Impossivel localizar ISN_PEDIDO novo.', Pilha);
      end;
    end;
  end;
  FreeAndNil(DmGlobal);

end;

// Identifica se o cliente Usa Palta.
function TFuncoes.cli_Usa_Palta(isn_cliente: Integer): String;
var
strUsaPauta : string;
Usa_Palta : String;
begin
   strUsaPauta := Pesquisa('ISN_CLIENTE', 'CLIFG_NFE_PAUTA', 'T_CLIENTE', Trim(IntToStr(isn_cliente)));

   Result :=  strUsaPauta;
end;

// Identifica ISN da unidade de Venda do Produto.
function TFuncoes.isn_und_vend_prod(isn_produto: Integer): Integer;
var
ins_und_venda_produto : String;
begin
   ins_und_venda_produto := Pesquisa('ISN_PRODUTO', 'ISN_UNIDADE_VENDA', 'T_PRODUTO', Trim(isn_produto.ToString));

   Result :=  ins_und_venda_produto.ToInteger;
end;

// Identifica O Custo Final do Produto ok, consultado com o sr Luciwagner.
function TFuncoes.custo_final_produto(isn_produto: Integer): Double;
var
Custo_Final : Double;
begin

//  custo_final := RoundFloat(StrToFloat(PesquisaNum('ISN_PRODUTO', 'ESTVL_PRECO_CUSTO_FINAL', 'T_ESTOQUE', Trim(IntToStr(isn_produto)))), 2);


 Custo_Final:= StrToFloat(Pesquisa('ISN_PRODUTO', 'ESTVL_PRECO_CUSTO_FINAL', 'T_ESTOQUE', isn_produto.ToString));

  Result :=  Custo_Final;
end;

// Identifica O Custo Final do Produto ok, consultado com o sr Luciwagner.
function TFuncoes.RoundFloat(Value: Extended; Digits: Integer): Extended;
var
  StrFmt: string;
begin
  StrFmt := '%.' + IntToStr(Digits) + 'f';
  Result := StrToFloat(Format(StrFmt, [Value]));
end;

//Consulta o CFOP pelo tipo de pedido  tiago ok
function TFuncoes.ConsultaCFOP(TipoPedido: string): Integer;
 var
  strCfop: string;
begin
      strCfop := Pesquisa('ISN_TIPO_PEDIDO', 'ISN_CFOP', 'T_TIPO_PEDIDO',
      Trim(TipoPedido));

     Result := StrToInt(strCfop);
 end;

 //Consulta o unidade de venda do produto
function TFuncoes.unidade_venda_produto(isn_produto: integer): Integer;
 var
  und_venda: String;
begin
      und_venda := Pesquisa('ISN_PRODUTO', 'PROQT_UNIDADE_VENDA', 'T_PRODUTO',
                            isn_produto.ToString);

      Result := und_venda.ToInteger;
 end;

 //Cosulta o Número do preço do cliente
function TFuncoes.ConsultaNumeroPreco(isn_cliente, cod_representante {usuario} : Integer) : Integer;
var
    strResultPesq : string;
    validade, Agora : TDateTime;
    strNumPreco : String;
begin
      Agora := Now;

          strResultPesq := Pesquisa('ISN_CLIENTE', 'CLIDT_PRECO_VENDA', 'T_CLIENTE', trim(IntToStr(isn_cliente)));
        if (Trim(strResultPesq) <> '') and (Trim(strResultPesq) <> 'Não Cadastrado') then
          validade := StrToDate(strResultPesq)
        else
          validade := Agora;

        //Verbose('Ponto 8', Pilha);   //numero do preco
        strNumPreco := Pesquisa('ISN_CLIENTE', 'CLINR_PRECO', 'T_CLIENTE',  trim(IntToStr(isn_cliente)));
        if ( trim(strNumPreco) = '0' ) or ( trim(strNumPreco) = '' ) or ( validade < Agora ) then
          strNumPreco := Pesquisa('ISN_REPRESENTANTE', 'REPNR_PRECO', 'T_REPRESENTANTE', trim(IntToStr(cod_representante)));
        if ( trim(strNumPreco) = '0' ) or ( trim(strNumPreco) = '' ) then
          strNumPreco := '1';

      Result := strNumPreco.ToInteger;

end;

function TFuncoes.PedidoBloqueado(isn_cliente: string; TipoPedido: string):
  string;
var
 DmGlobal : TDmGlobal;
 intIsnBloq : Integer;




  strCfop: string;
  qryCfop: TFDQuery;
  strCodCliente: string;
  strSQL: string;
  qryImpAux : TFDQuery;

begin
    DmGlobal := TDmGlobal.Create(nil);
    qryCfop := TFDQuery.Create(nil);
    qryCfop.Connection:= DmGlobal.Conn;

    intIsnBloq := 0;

  Result := NULL;


  //   2   - Ultrapassou limite de Credito do Cliente
  //   5   - Pedido proposta
  //   7   - Bloqueio Bonificação / Troca
  //  15   - Bloqueio Faturamento PALM
  //  22   - Cliente bloqueado para faturamento
  //  23   - Pedido a negociar

  strCfop := Pesquisa('ISN_TIPO_PEDIDO', 'ISN_CFOP', 'T_TIPO_PEDIDO',
    Trim(TipoPedido));

  if (Pesquisa('ISN_TIPO_PEDIDO', 'TIPFG_PROPOSTA', 'T_TIPO_PEDIDO',
    Trim(TipoPedido)) = 'S') then
  begin
    Result := '5';
  end
  else if (Pesquisa('ISN_CFOP', 'CFOFG_BONIFICACAO', 'T_CFOP',
    QuotedStr(strCfop)) = 'S') and (ConfiguracaoGlobal.strSeckey <> 'JLDISTXI') then
  begin
    Result := '7';
  end
  else if (Pesquisa('ISN_CFOP', 'CFOFG_NEGOCIAR', 'T_CFOP', QuotedStr(strCfop)) =
    'S') then
  begin
    Result := '23';
  end
  else
  begin
    qryImpAux := TFDQuery.Create(nil);
    qryImpAux.Connection:= DmGlobal.Conn;
    qryImpAux.Close;
    qryImpAux.SQL.Add( 'SELECT CLIVL_LIMITE, CLIFG_STATUS FROM T_CLIENTE WHERE ISN_CLIENTE = :ISN_CLIENTE');
    qryImpAux.ParamByName('ISN_CLIENTE').value := isn_cliente; //codigo do cliente
    qryImpAux.Open;

    if not qryImpAux.Eof then
    begin

      if qryImpAux.Fields[1].AsString = 'F' then
        Result := '22';

      if (Result.IsEmpty) then
        if (not (qryImpAux.Fields[0].IsNull)) then
        begin

          if ((qryImpAux.Fields[0].AsFloat -
             Calc_Limite(Cod_Cliente)<(StrToInt(arrPedido[6]) / 100))
             and (ConfiguracaoGlobal.strSeckey <> 'JLDISTXI'))
          then
            Result := '2'
          else
            Result := Unassigned;

        end
        else
        begin

          if ((Calc_Limite(Cod_Cliente))<(StrToInt(arrPedido[6]) /
            100)) then
            Result := '2'
          else
            Result := Unassigned;

        end;

    end;

  end;
  qryImpAux.Close;
  qryImpAux.Free;
  qryImpAux := nil;
  FreeAndNil(DmGlobal);

end;

function TFuncoes.Pesquisa(parCampo1, parCampo2, parTabela, parValor: string): string;
var
 DmGlobal : TDmGlobal;
  qryPesquisa: TFDQuery;
  ret: string;

begin
  if parValor <> '' then
  begin
    try
      DmGlobal := TDmGlobal.Create(nil);
      qryPesquisa := TFDQuery.Create(nil);
      qryPesquisa.Connection:= DmGlobal.Conn;

      qryPesquisa.SQL.Clear;
      qryPesquisa.SQL.Add('SELECT ' + parCampo2 + ' FROM ' );
      qryPesquisa.SQL.Add( parTabela + ' WHERE ' + parCampo1 + ' = ' + parValor);
      qryPesquisa.Open;

      if qryPesquisa.Eof then
      begin
        //MessageDlg('Não Cadastrado',MTerror,[MbOk],0);
        ret := 'Não Cadastrado';
      end
      else
      begin
        //ret := qryPesquisa.Fields[1].AsString;
        ret := qryPesquisa.FieldByName(parCampo2).AsString;
      end;
      qryPesquisa.Close;
      qryPesquisa.Free;
    except
      ret := '';
    end;
  end
  else
    ret := '';
  Pesquisa := ret;
  FreeAndNil(DmGlobal);

end;


function TFuncoes.GetQtdPedidosAbertoCliente(IntIsnCliente : Integer): Integer;
var
  qryRegistro : TFDQuery;
  strSQL: string;
  DmGlobal : TDmGlobal;
begin
  try
      DmGlobal := TDmGlobal.Create(nil);
      qryRegistro := TFDQuery.Create(nil);
      qryRegistro.Connection:= DmGlobal.Conn;

    strSQL := 'SELECT COUNT(DISTINCT(PED.PEDCN_PEDIDO)) QTD_PED_ABERTO '+
    'FROM T_PEDIDO PED '+
    'JOIN T_CLIENTE CLI ON (PED.ISN_CLIENTE = CLI.ISN_CLIENTE) '+
    'JOIN T_PREVISAO_RECEBER PRV ON (PRV.ISN_PEDIDO = PED.ISN_PEDIDO) '+
    'JOIN T_CONTAS_RECEBER CTR ON (CTR.ISN_PREVISAO_RECEBER = PRV.ISN_PREVISAO_RECEBER) '+
    'WHERE CLI.ISN_CLIENTE = '+inttostr(IntIsnCliente)+' AND '+
    'CTR.CREFG_STATUS = ''A''';


    qryRegistro.SQL.Add(strSQL);
    qryRegistro.Open;
    GetQtdPedidosAbertoCliente := qryRegistro.FieldByName('QTD_PED_ABERTO').AsInteger;

  finally
    qryRegistro.Free;
  end;
  FreeAndNil(DmGlobal);
end;

function TFuncoes.Calc_Limite(lngIsnCliente: Integer): Double;
var
  qryLimCliente: TFDQuery;
  LrlLImite: Real;
  strISNContaReceber: string;
  strSQL: string;
  DmGlobal : TDmGlobal;
begin
  LrlLimite := 0;

      DmGlobal := TDmGlobal.Create(nil);
      qryLimCliente := TFDQuery.Create(nil);
      qryLimCliente.Connection:= DmGlobal.Conn;

  // Verifica na Tabela de Previsão de Contas a Receber Venda
  strSQL := 'SELECT SUM(PR.PVRVL_VALOR) AS DEBITO ' +
    'FROM T_PREVISAO_RECEBER PR ' +
    'JOIN T_PEDIDO PED ON (PR.ISN_PEDIDO = PED.ISN_PEDIDO) ' +
    'WHERE PVRDT_PRESTACAO_CONTAS IS NULL ' +
    'AND PED.ISN_PEDIDO_ORIGEM IS NULL ' +
    'AND PR.ISN_CLIENTE = ' + inttostr(lngIsnCliente);

  qryLimCliente.SQL.add(strSQL);
  qryLimCliente.open;

  if not qryLimCliente.Eof then
    LrlLimite := LrlLimite + qryLimCliente.FieldByName('DEBITO').AsFloat;
  qryLimCliente.close;

  // Verifica na Tabela de Previsão de Contas a Receber Devolução
  strSQL := 'SELECT SUM(PR.PVRVL_VALOR) AS CREDITO ' +
    'FROM T_PREVISAO_RECEBER PR ' +
    'JOIN T_PEDIDO PED ON (PR.ISN_PEDIDO = PED.ISN_PEDIDO) ' +
    'JOIN T_PEDIDO PED1 ON (PED1.ISN_PEDIDO = PED.ISN_PEDIDO_ORIGEM) ' +
    'JOIN T_PREVISAO_RECEBER PR1 ON (PR1.ISN_PEDIDO = PED1.ISN_PEDIDO) ' +
    'WHERE PR.PVRDT_PRESTACAO_CONTAS IS NULL ' +
    'AND PED.ISN_PEDIDO_ORIGEM IS NOT NULL ' +
    'AND PR1.PVRDT_PRESTACAO_CONTAS IS NULL ' +
    'AND PR.ISN_CLIENTE = ' + inttostr(lngIsnCliente);

  qryLimCliente.SQL.add(strSQL);
  qryLimCliente.open;
  if not qryLimCliente.Eof then
    LrlLimite := LrlLimite - qryLimCliente.FieldByName('CREDITO').AsFloat;
  qryLimCliente.close;

  // Verifica na tabela de Contas a Receber, Status A- Conta Aberta (Devedora)
  strSQL := 'SELECT SUM(CREVL_VALOR) AS DEBITO ' +
    'FROM T_PREVISAO_RECEBER T_PCR ' +
    'JOIN T_CONTAS_RECEBER T_CRE ON (T_PCR.ISN_PREVISAO_RECEBER = T_CRE.ISN_PREVISAO_RECEBER) ' +
    'WHERE CREFG_STATUS = ''A'' ' +
    'AND T_PCR.ISN_CLIENTE = ' + inttostr(lngIsnCliente);
  qryLimCliente.SQL.add(strSQL);
  qryLimCliente.Open;
  if not qryLimCliente.Eof then
    LrlLimite := LrlLimite + qryLimCliente.FieldByName('DEBITO').AsFloat;
  qryLimCliente.close;

  // Verifica se há pagamento parcial do contas a receber
  strSQL := 'SELECT SUM(PP.PPAVL_VALOR) AS CREDITO ' +
    'FROM T_PAGAMENTO_PARCIAL PP ' +
    'JOIN T_CONTAS_RECEBER CR ON (CR.ISN_CONTAS_RECEBER = PP.ISN_CONTAS_RECEBER) ' +
    'JOIN T_PREVISAO_RECEBER PR ON (PR.ISN_PREVISAO_RECEBER = CR.ISN_PREVISAO_RECEBER) ' +
    'WHERE CR.CREFG_STATUS = ''A'' ' +
    'AND PR.ISN_CLIENTE = ' + inttostr(lngIsnCliente);
  qryLimCliente.SQL.add(strSQL);
  qryLimCliente.Open;
  if not qryLimCliente.Eof then
    LrlLimite := LrlLimite - qryLimCliente.FieldByName('CREDITO').AsFloat;
  qryLimCliente.close;

  // Verifica se há pedidos sem faturar e tira do limite
  strSQL := 'SELECT SUM(PED.PEDVL_TOTAL) AS DEBITO ' +
    'FROM T_PEDIDO PED ' +
    'JOIN T_CFOP CFOP ON (PED.ISN_CFOP = CFOP.ISN_CFOP) ' +
    'INNER JOIN T_TIPO_PEDIDO TPED ON (TPED.ISN_TIPO_PEDIDO = PED.ISN_TIPO_PEDIDO) ' +
    'WHERE CFOP.CFOFG_VENDA = ''S'' AND TPED.TIPFG_ESTOQUE_LOJA = ''N'' ' +
    'AND PEDFG_CANCELADO = ''N'' AND PEDFG_TRANSFERIDO = ''N'' ' +
    'AND ISN_CLIENTE = ' + inttostr(lngIsnCliente);

  qryLimCliente.SQL.add(strSQL);
  qryLimCliente.Open;

  if not qryLimCliente.Eof then
    LrlLimite := LrlLimite + qryLimCliente.FieldByName('DEBITO').AsFloat;
  qryLimCliente.Close;
  qryLimCliente.Free;
  Calc_Limite := LrlLimite;

  FreeAndNil(DmGlobal);
end;


procedure TFuncoes.aplicaDesconto(strPercDesc : string; dblIPEVL_PRE_DIG : Double; dblIPEVL_UNITARIO : Double; dblIPEVL_PRECO_TABELA : Double;
                                       strCodCli : string; strCodRepCli : string; strCodProd : string; dtmDataPedido : TDateTime;
                                       intIsnRegiao : integer; intCodPrazo : integer; dblQuant : Double; strTPForma : string
                                      );
var
  dblPrecoFaixa : double;
  fltDescMax : double;
begin

  dblResIPEVL_PRE_DIG := 0;
  dblResIPEVL_UNITARIO := 0;
  dblResIPEVL_PRECO_TABELA := 0;
  dblResIPEPR_DESCONTO := 0;
  dblResPrDesc := StrToFloatDef(strPercDesc, 0) / 100;

  if (dblIPEVL_PRE_DIG > 0) and (ConfiguracaoGlobal.strSeckey = 'CONSTRU') then
  begin
    if (dblResPrDesc > 0) then
      begin
        dblIPEVL_UNITARIO := dblIPEVL_PRE_DIG / (1 - dblResPrDesc);

        if dblIPEVL_UNITARIO < dblIPEVL_PRE_DIG then
          dblResIPEVL_ACRESCIMO := dblIPEVL_UNITARIO - dblIPEVL_PRE_DIG
        else
          dblResIPEVL_ACRESCIMO := 0;

        dblResIPEVL_DESCONTO := dblIPEVL_UNITARIO - dblIPEVL_PRE_DIG;
        //qryItemTOTAL.Value := dblIPEVL_PRE_DIG * qryItemIPEQT_QUANTIDADE.Value;
      end;

    if (dblResPrDesc = 0) then
      begin
        dblIPEVL_UNITARIO := dblIPEVL_PRECO_TABELA;
        if dblResIPEVL_ACRESCIMO = 0 then
        begin
          dblIPEVL_PRE_DIG := 0;
          dblResIPEVL_ACRESCIMO := 0;
        end;
        dblResIPEVL_DESCONTO := 0;
        //qryItemTOTAL.Value := dblIPEVL_UNITARIO * qryItemIPEQT_QUANTIDADE.Value;
      end;
  end
  else if (dblIPEVL_PRE_DIG > 0) then
  begin
    if (dblResPrDesc > 0) then
      begin

        dblIPEVL_PRE_DIG := dblIPEVL_PRECO_TABELA - (dblIPEVL_PRECO_TABELA * dblResPrDesc);

        if dblIPEVL_UNITARIO < dblIPEVL_PRE_DIG then
          dblResIPEVL_ACRESCIMO := dblIPEVL_UNITARIO - dblIPEVL_PRE_DIG
        else
          dblResIPEVL_ACRESCIMO := 0;

        dblResIPEVL_DESCONTO := dblIPEVL_UNITARIO - dblIPEVL_PRE_DIG;

        //qryItemTOTAL.Value := dblIPEVL_PRE_DIG * qryItemIPEQT_QUANTIDADE.Value;

      end;

    if (dblResPrDesc = 0) then
      begin
        if (ConfiguracaoGlobal.strSeckey <> 'BIO') and (ConfiguracaoGlobal.strSeckey <> 'RALINE') then
         dblIPEVL_UNITARIO := dblIPEVL_PRECO_TABELA;

        if (Trim(ConfiguracaoGlobal.strSeckey) <> 'PROSPACK') and (Trim(ConfiguracaoGlobal.strSeckey) <> 'REIJERS') and
           (Trim(ConfiguracaoGlobal.strSeckey) <> 'DANSUL') then
          dblIPEVL_PRE_DIG := 0;

        dblResIPEVL_ACRESCIMO := 0;
        dblResIPEVL_DESCONTO := 0;
        //qryItemTOTAL.Value := dblIPEVL_UNITARIO * qryItemIPEQT_QUANTIDADE.Value;
      end;
  end

  else if dblIPEVL_UNITARIO > 0 then
  begin
    if (dblResPrDesc > 0) then //and (qryItemIPEVL_ACRESCIMO.Value = 0) then
    begin

      if ( Pos(Trim(ConfiguracaoGlobal.strSeckey),'DDCOMERCIO')>0 ) Then
        begin
          fltDescMax := StrToFloatDef
          (Pesquisa('PROD.PROCC_PRODUTO',
          'PRODI.PROPR_DESCONTO_MAXIMO',
          'T_PRODUTO PROD INNER JOIN T_PRODUTO_IMPOSTO PRODI ON (PRODI.ISN_PRODUTO = PROD.ISN_PRODUTO) ',strCodProd),0); // TESTE LW

          fltDescMax := fltDescMax/100;
          If dblResPrDesc > fltDescMax Then
            dblResPrDesc := fltDescMax;
        end;

      dblIPEVL_UNITARIO := dblIPEVL_UNITARIO - (dblIPEVL_UNITARIO * dblResPrDesc);
      dblIPEVL_PRE_DIG := dblIPEVL_UNITARIO;
      //qryItemUNITARIOLIQUIDO.Value := dblIPEVL_UNITARIO;
      dblIPEVL_UNITARIO := dblIPEVL_PRE_DIG / (1 - dblResPrDesc);

      if dblIPEVL_UNITARIO < dblIPEVL_PRE_DIG then
        dblResIPEVL_ACRESCIMO := dblIPEVL_UNITARIO - dblIPEVL_PRE_DIG
      else
        dblResIPEVL_ACRESCIMO := 0;

      dblResIPEVL_DESCONTO := dblIPEVL_UNITARIO - dblIPEVL_PRE_DIG;
      //qryItemTOTAL.Value := qryItemUNITARIOLIQUIDO.Value * qryItemIPEQT_QUANTIDADE.Value;
      dblResIPEPR_DESCONTO := dblResPrDesc*100;

    end;

    if (dblResPrDesc = 0) then
      begin
      {  intResPreco := NumeroPreco(strCodCli, strCodRepCli);
        dblPrecoFaixa := PegaPreco(strCodProd, dtmDataPedido, intResPreco, intIsnRegiao,
                                   intCodPrazo, dblQuant, strTPForma
                                   ); }

        if dblPrecoFaixa = 0 then
        begin
          if dblIPEVL_PRECO_TABELA > 0 then
           dblIPEVL_UNITARIO := dblIPEVL_PRECO_TABELA;
          dblIPEVL_PRE_DIG := 0;
          dblResIPEVL_ACRESCIMO := 0;
          dblResIPEVL_DESCONTO := 0;
          //qryItemTOTAL.Value := dblIPEVL_UNITARIO *
          //  qryItemIPEQT_QUANTIDADE.Value;
        end;
      end;

  end;
  dblResIPEVL_PRE_DIG := dblIPEVL_PRE_DIG;
  dblResIPEVL_UNITARIO := dblIPEVL_UNITARIO;
  dblResIPEVL_PRECO_TABELA := dblIPEVL_PRECO_TABELA;
  dblResIPEPR_DESCONTO := dblResPrDesc*100;
end;


function TFuncoes.CalculaValores(Digitado: Double; Atual: Double):
  TDoubleArray;
var
  arrFinal: TDoubleArray;
  Diferenca, aux: Double;
  i: integer;
begin
  SetLength(arrFinal, 3); //0 Desconto | 1 Acrescimo | 2 Digitado
  Diferenca := Digitado - Atual;
  if (Diferenca = 0) then
  begin
    arrFinal[0] := 0;
    arrFinal[1] := 0;
  end;
  if (Diferenca > 0) then
  begin
    arrFinal[0] := 0;
    arrFinal[1] := (Diferenca);
  end;
  if (Diferenca < 0) then
  begin
    arrFinal[0] := (Diferenca * (-1));
    arrFinal[1] := 0;
  end;
  arrFinal[2] := Atual;
  for i := 0 to Length(arrFinal) - 1 do
    arrFinal[i] := RoundFloat(arrFinal[i], intNumCasaDecimal);
  Result := arrFinal;
end;

//Percentual de desconto pelo  prazo.  //ok  testado
function TFuncoes.PercentualDescPrazo(cod_prazo : Integer) : Integer;
var
 percentual : string;
begin
  Result := 0;

  percentual := Pesquisa('ISN_PRAZO', 'PRAPR_DESCONTO', 'T_PRAZO', Trim(cod_prazo.ToString));

 if not TryStrToInt(percentual, Result) then
    Result := 0;

end;


//RESERVA ESTOQUE
function TFuncoes.Reserva_Estoque (isn_produto: Integer;
                                    Qtd:real; parTipo: string = 'V';
                                    parFat: string = 'S'): string;
var
 strSQL:string;
 rlUniVenda: real;
 qryRegistro : TFDQuery;
 DmGlobal : TDmGlobal;

begin
      try
          DmGlobal := TDmGlobal.Create(nil);
          DmGlobal.Conn.StartTransaction;

        Try
          // Fator da Unidade de Venda
          If parTipo = 'V' then       // Estoque de Venda
             begin

               qryRegistro:= TFDQuery.Create(nil);
               qryRegistro.Connection := DmGlobal.Conn;
               strSQL := 'SELECT PROQT_UNIDADE_VENDA AS UNI_VENDA FROM T_PRODUTO WHERE ISN_PRODUTO=' + inttostr(isn_produto);
               qryRegistro.SQL.Add(strSQL);
               qryRegistro.Open;
               rlUniVenda := qryRegistro.FieldByName('UNI_VENDA').AsFloat;
               qryRegistro.Close;

               If ParFat = 'S' Then
                 // Reserva de estoque de venda
                 strSQL := 'UPDATE T_ESTOQUE SET ESTQT_RESERVA= ESTQT_RESERVA + ' + PontoVirg(floattostr(Qtd * rlUniVenda))  +
                           ',ESTQT_RESERVA_FISCAL = ESTQT_RESERVA_FISCAL + ' + PontoVirg(floattostr(Qtd*rlUniVenda))  +
                           ' WHERE ISN_PRODUTO=' + inttostr(isn_produto)
               Else
                 strSQL := 'UPDATE T_ESTOQUE SET ESTQT_RESERVA= ESTQT_RESERVA + ' + PontoVirg(floattostr(Qtd * rlUniVenda))  +
                           ' WHERE ISN_PRODUTO=' + inttostr(isn_produto);
             end
          else if parTipo = 'U' then     // Estoque Unitário
             begin

               If ParFat = 'S' Then
                 // Reserva de estoque unitário
                 strSQL := 'UPDATE T_ESTOQUE SET ESTQT_RESERVA= ESTQT_RESERVA + ' + floattostr(Qtd)  +
                           ',ESTQT_RESERVA_FISCAL = ESTQT_RESERVA_FISCAL + ' + floattostr(Qtd)  +
                           ' WHERE ISN_PRODUTO=' + inttostr(isn_produto)
               Else
                 // Reserva de estoque unitário
                 strSQL := 'UPDATE T_ESTOQUE SET ESTQT_RESERVA= ESTQT_RESERVA + ' + floattostr(Qtd)  +
                           ' WHERE ISN_PRODUTO=' + inttostr(isn_produto);

             end;
             // Atualiza Reserva de estoque
             try
              DmGlobal.Conn.ExecSQL(strSQL)
             except on ex:exception do
                ShowMessage('Erro ao reservar estoque do produto, operação não efetuada. Entre em contato com o Administrador' + ex.Message);
             end;

        Except
          On E: Exception do  ShowMessage(E.Message);
        End
      finally
      DmGlobal.Conn.Commit;
      FreeAndNil(DmGlobal);
      end;
end;

//BLOQUEIO POR VALOR DO PEDIDO MÍNIMO///////////////////
function TFuncoes.BloqueioPedValorMinimo (isn_pedido: Integer) : Integer;
var
   qryImpAux : TFDQuery;
   DmGlobal : TDmGlobal;
   strSQL : string;
begin
    DmGlobal := TDmGlobal.Create(nil);
    qryImpAux := TFDQuery.Create(nil);
    qryImpAux.Connection:= DmGlobal.Conn;

    strSQL := 'SELECT PED.PEDVL_TOTAL, PRA.PRAVL_PEDIDO_MINIMO FROM T_PEDIDO PED ' +
              'JOIN T_PRAZO PRA ON (PRA.ISN_PRAZO = PED.ISN_PRAZO) ' +
              'WHERE PED.ISN_PEDIDO = ' + isn_pedido.ToString;

    qryImpAux.Close;
    qryImpAux.SQL.Add(strSQL);
    qryImpAux.Open;

    if (qryImpAux.Fields[0].AsFloat < qryImpAux.Fields[1].AsFloat) then
    begin
      strSQL := ' UPDATE T_PEDIDO ' +
                ' SET ISN_BLOQUEIO = 24 ' +
                ' WHERE ISN_BLOQUEIO <> 32 AND ISN_PEDIDO = ' + isn_pedido.ToString;

      qryImpAux.ExecSQL(strSQL);
    end;

    qryImpAux.Close;

    FreeAndNil(qryImpAux);
    FreeAndNil(DmGlobal);
end;


function TFuncoes.setStatusPedido(st, pd: String): Boolean;
var strSQL : string;
 qry : TFDQuery;
begin
    qry := TFDQuery.Create(nil);
    qry.Connection := DmGlobal.Conn;

  strSQL := 'UPDATE T_PEDIDO SET PEDFG_IMPLANTADO = ''S''  WHERE ISN_PEDIDO = ' + pd;
  qry.ExecSQL(strSQL);

  Result := True;
  qry.Close;
  qry.Free;

end;

function TFuncoes.Iif(Teste: Boolean; ValorTrue, ValorFalse:String): String;
begin
  If Teste then
    Result := ValorTrue
  else
    Result := ValorFalse;
end;

function TFuncoes.Iif(Teste: Boolean; ValorTrue, ValorFalse:Real): Extended;
begin
  If Teste then
    Result := ValorTrue
  else
    Result := ValorFalse;
end;

function TFuncoes.Iif(Teste: Boolean; ValorTrue, ValorFalse:Integer): Integer;
begin
  If Teste then
    Result := ValorTrue
  else
    Result := ValorFalse;
end;

function TFuncoes.getValorTaxaCliente(
  strIsnClienteP, strIsnFormaPagamentoP : string): Double;
var fltValorTaxa : Double;
    strSQL : string;
    qryTemp : TFDQuery;
    strFormPag : string;
    DmGlobal : TDmGlobal;
begin
    DmGlobal := TDmGlobal.Create(nil);
    qryTemp := TFDQuery.Create(nil);
    qryTemp.Connection:= DmGlobal.Conn;

  strSQL := 'SELECT COALESCE(CLI.CLIVL_TAXA,0) VL_TAXA, COALESCE(CLI.CLIVL_TAXA_ENTREGA,0) VL_TAXA_ENTREGA FROM T_CLIENTE CLI WHERE CLI.ISN_CLIENTE = ' + strIsnClienteP;
  qryTemp.SQL.Add(strSQL);
  qryTemp.Open;
  fltValorTaxa := 0;

  strFormPag := Pesquisa('ISN_FORMA_PAGAMENTO', 'FPACN_FORMA', 'T_FORMA_PAGAMENTO', strIsnFormaPagamentoP);

  if Trim(strFormPag) = 'DP' then
    fltValorTaxa := qryTemp.FieldByName('VL_TAXA').AsFloat;

  fltValorTaxa := fltValorTaxa + qryTemp.FieldByName('VL_TAXA_ENTREGA').AsFloat;
  qryTemp.Free;

  Result := fltValorTaxa;
end;


{
   function.....: PegaPreco
   Objetivo.....: Retornar o preço de um produto
   strProduto...: Código do produto
   dtValidade...: Data de validade do preço
   intTabela....: Número do preço
   strRegiao....: Código da região
   strPrazo.....: Código do prazo
   dblQuantidade: Quantidade para verificar a faixa
}

function TFuncoes.PegaPreco(strProduto: string;
  dtValidade: TDateTime;
  intTabela: integer;
  intRegiao: longint;
  intPrazo: longint;
  dblQuantidade: double): double;
var
  strSql: string;
  qryResult: TFDQuery;
  intI: integer;
  fltRet: double;
  strIsnProduto: string;
  strIsnRegiao: string;
  strIsnPrazo: string;
begin
  fltRet := 0;

  strIsnProduto := PesqCampos('T_PRODUTO', ['PROCC_PRODUTO'],
    [QuotedStr(strProduto)], 'ISN_PRODUTO');

  // LW 28/12/2005
//  txtResF := TEdit.Create(Application);
//  txtResP := TEdit.Create(Application);
//  PesqGen('SELECT FORN.FORFG_PRECO_IGUAL,PROD.PROFG_PRECO_UNICO FROM T_PRODUTO PROD,T_FORNECEDOR FORN WHERE PROD.ISN_FORNECEDOR = FORN.ISN_FORNECEDOR '
//    +
//    'AND PROD.ISN_PRODUTO = ' + strIsnProduto, [txtResF, txtResP]);

//  strSql := 'SELECT FPR.FPRVL_VALOR ';
//
//  if (txtResP.Text = 'N') or (Pesquisa('PARDS_IDENTIFICADOR_PARAMETRO',
//    'PARDS_CONTEUDO', 'T_PARAMETRO', Quotedstr('PAR_PRAZO_PROD_UNICO')) = 'S')
//    then
//    strSql := strSQL + '*(1+pra.prapr_acrescimo/100) ';
//
//  if (txtResF.Text = 'N') and (txtResP.Text = 'N') then
//    strSQL := strSQL + '*(1+reg.regpr_acrescimo/100) ';

  strSQL := strSQL +
    ' AS PRECO FROM T_FAIXA_PRECO FPR,T_REGIAO reg,T_PRAZO pra,T_PRODUTO PROD ' +
    'WHERE PROD.PROCC_PRODUTO = ' + QuotedStr(strProduto) + ' AND ' +
    'reg.ISN_REGIAO = ' + IntToStr(intRegiao) + ' AND ' +
    'FPR.ISN_PRODUTO = PROD.ISN_PRODUTO AND ' +
    'PRA.PRACN_PRAZO = ' + IntToStr(intPrazo) + ' AND ' +
    'FPR.FPRNR_PRECO = ' + IntToStr(intTabela) + ' AND ' +
    'PRAFG_INATIVO = ''N'' ' +
    'AND (' + VirgPont(dblQuantidade) + ' >= FPR.FPRQT_INICIAL) ' +
    'AND (' + VirgPont(dblQuantidade) + ' <= FPR.FPRQT_FINAL) ' +
    'AND FPR.FPRDT_VALIDADE = ' +
    '(SELECT MAX(FPR1.FPRDT_VALIDADE) ' +
    'FROM T_FAIXA_PRECO FPR1 WHERE FPR1.FPRDT_VALIDADE <= ' +
      QuotedStr(FormatDateTime('MM/dd/YYYY 23:59:59', dtValidade)) + ' AND ' +
    'FPR1.ISN_PRODUTO = FPR.ISN_PRODUTO AND FPR1.FPRNR_PRECO=' +
      IntToStr(intTabela) + ')';

//  intI := DmGlobal.Conn.Execute(strSql, nil, @qryResult);

//  if not qryResult.Fields[0].IsNull then
//    fltRet := qryResult.Fields[0].Value;
//
//  PegaPreco := fltRet;
//  txtResF.Free; // LW 28/12/2005
//  txtResP.Free; // LW 28/12/2005
end;

function TFuncoes.VirgPont(Valor: double): string;
var
  str: string;
begin
  str := FloatToStr(Valor);
  str := StringReplace(str, ',', '.', [rfIgnoreCase]);
  Result := str;
end;

function TFuncoes.PegaPrecoIsn(strProduto: string;
  dtValidade: TDateTime;
  intTabela: integer;
  intRegiao: longint;
  intPrazo: longint): double;
var
  strSql: string;
  qryResult: TFDQuery;
  intI: integer;
  fltRet: double;
  strIsnProduto: string;
  strIsnRegiao: string;
  strIsnPrazo: string;
//  txtResF: TEdit; // LW 28/12/2005 Resultado do Fornecedor
//  txtResP: TEdit; // LW 28/12/2005 Resultado do Produto
begin
  fltRet := 0;

  strIsnProduto := strProduto;

  // LW 28/12/2005
//  txtResF := TEdit.Create(Application);
//  txtResP := TEdit.Create(Application);
//  PesqGen('SELECT FORN.FORFG_PRECO_IGUAL,PROD.PROFG_PRECO_UNICO FROM T_PRODUTO PROD,T_FORNECEDOR FORN WHERE PROD.ISN_FORNECEDOR = FORN.ISN_FORNECEDOR '
//    +
//    'AND PROD.ISN_PRODUTO = ' + strIsnProduto, [txtResF, txtResP]);
//
//  strSql := 'SELECT preco.PREVL_PRECO  ';

//  if (txtResP.Text = 'N') or (Pesquisa('PARDS_IDENTIFICADOR_PARAMETRO',
//    'PARDS_CONTEUDO', 'T_PARAMETRO', Quotedstr('PAR_PRAZO_PROD_UNICO')) = 'S') then
    // LW 28/12/2005
    strSql := strSQL + '*(1+pra.prapr_acrescimo/100) ';
//
//  if (txtResF.Text = 'N') and (txtResP.Text = 'N') then // LW 28/12/2005
//    strSQL := strSQL + '*(1+reg.regpr_acrescimo/100) ';

  strSQL := strSQL +
    ' AS PRECO FROM T_PRECO PRECO,T_REGIAO reg,T_PRAZO pra,T_PRODUTO PROD ' +
    'WHERE PROD.ISN_PRODUTO = ' + QuotedStr(strProduto) + ' AND ' +
    'reg.ISN_REGIAO = ' + IntToStr(intRegiao) + ' AND ' +
    'PRECO.ISN_PRODUTO = PROD.ISN_PRODUTO AND ' +
    'PRA.ISN_PRAZO = ' + IntToStr(intPrazo) + ' AND ' +
    'PRECO.PRENR_PRECO = ' + IntToStr(intTabela) + ' AND ' +
    'PRAFG_INATIVO = ''N'' ' +
    'AND PRECO.PREDT_INICIO_VALIDADE = ' +
    '(SELECT MAX(PREDT_INICIO_VALIDADE) ' +
    'FROM T_PRECO TPRE WHERE PREDT_INICIO_VALIDADE <= ' +
      QuotedStr(FormatDateTime('MM/dd/YYYY 23:59:59', dtValidade)) + ' AND ' +
    'TPRE.ISN_PRODUTO = PRECO.ISN_PRODUTO AND TPRE.PRENR_PRECO=' +
      IntToStr(intTabela) + ')';

//  intI := qryResult.ExecSQL(strSql, nil, @qryResult);

  if not qryResult.Fields[0].IsNull then
  begin
    fltRet := qryResult.Fields[0].Value;
  end;

  PegaPrecoIsn := fltRet;
//  txtResF.Free; // LW 28/12/2005
//  txtResP.Free; // LW 28/12/2005
end;

function TFuncoes.FloatType(num: string): string;
var strTemp : string;
begin
  strTemp := StringReplace(FloatToStr(StrToFloat(Num) / 100), ',', '.',
      [rfIgnoreCase]);
  if ConfiguracaoGlobal.strSeckey = 'VIALACTEA' then
    Result := StringReplace(FloatToStr(StrToFloat(Num) / 1000), ',', '.',
      [rfIgnoreCase])
  else
    Result := strTemp;
      //StringReplace(FloatToStr(StrToFloat(Num) / 100), ',', '.',
      //[rfIgnoreCase]);
end;

function TFuncoes.PesquisaNum(parCampo1, parCampo2, parTabela, parValor: string): string;
var qryPesquisa : TFDQuery;
    ret : string;
begin
  if parvalor <> '' then
    begin
      try
        qryPesquisa := TFDQuery.Create(nil);
        qryPesquisa.Connection := DmGlobal.Conn;
        qryPesquisa.SQL.Clear;
        qryPesquisa.SQL.Add('SELECT ' + 'COALESCE (' + parCampo2 + ',0) ' + parCampo2 + ' FROM ' +
          parTabela + ' WHERE ' + parCampo1 + ' = ' + parValor);
        qryPesquisa.Open;

        if qryPesquisa.Eof then
          begin
            ret := 'Não Cadastrado';
          end
        else
          begin
            ret := qryPesquisa.FieldByName(parCampo2).AsString;
          end;
        qryPesquisa.Close;
        qryPesquisa.Free;
        qryPesquisa := nil;
      except
        ret := '';
      end;
  end
  else
    ret := '';
  PesquisaNum := ret;
end;

function TFuncoes.PesqCampos(strTabela: string; arrCampos: array of string;
  arrValores: array of string; strResultado: string): string;
var
  strSql: string;
  strSep: string;
  strarrCampos: string;
  qryPesq: TFDQuery;
  i: byte;
begin
  strarrCampos := '';
  strSep := '';

  for i := 0 to High(arrCampos) do
  begin
    strarrCampos := strarrCampos + strSep + arrCampos[i] + ' = ' +
      arrValores[i];
    strSep := ' and ';
  end;

  strSql := 'SELECT ' + strResultado + ' FROM ' + strTabela + ' WHERE ' +
    strarrCampos;

  qryPesq := TFDQuery.Create(nil);
  qryPesq.Connection := DmGlobal.Conn;
  qryPesq.Close;
  qryPesq.SQL.Add(strSql);
  qryPesq.Open;

  if qryPesq.Fields[0].IsNull then
    PesqCampos := ''
  else
    PesqCampos := qryPesq.Fields[0].AsString;
  qryPesq.Close;
  qryPesq.Free;
end;

//Converte String para data
function Tfuncoes.StringToDate (str : string): TDate;
var
 dia, mes, ano : Integer;
begin
   {
   Essa função devolverá a data formatada, para não importar em qual
   regição esteja o aparelho, e nem qual o baco de dados, pois
   será encodado na forma que o banco inserirá a data sem erros.
   1° Crio as variáveis para armazenar os dias mes e ano,
   2° dos dados recebidos na variável str, copio na primeira posição os dois primeiros digitos
   ex:  Copy(str, 1, 2), e assim sucessivamente...
   Com isso a instruão é asseguinte:
   Copy(str, 1, 2) : Copie de STR a partir da 1° posição os dois primeiros algarismos...
   Copy(str, 4, 2) : Copie de STR a partir da 4° posição os dois primeiros algarismos...
   Copy(str, 7, 4) : Copie de STR a partir da 7° posição os quatro primeiros algarismos...
   }
  //Formato do imput dos dados dd/mm/aaaa

   dia := Copy(str, 1, 2).ToInteger;
   mes := Copy(str, 4, 2).ToInteger;
   ano := Copy(str, 7, 4).ToInteger;

   {
    Ao fim passo no result, o ENCODEDATE, pra que o delphi codifique de acordo com
    a regionalização do aparelho e devolver a data sempre certa. Indepedete da linguagem que a máquina estiver
   }

   Result := EncodeDate(ano, mes , dia);
end;

end.


