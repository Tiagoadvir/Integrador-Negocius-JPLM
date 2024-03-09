
unit DateModule.Cliente;

interface

uses
  uFunctions,
  Uni,
  uMD5,

  Data.DB,

  DataSet.Serialize,

  DateModule.Global,

  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.DApt,
  FireDAC.DApt.Intf,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Async,
  FireDAC.Stan.Error,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,

  System.Classes,
  System.JSON,
  System.SysUtils;

type
  TDmCliente = class(TDataModule)
  private
    { Private declarations }
    Conexao    : TDmGlobal;
    UniQuery   : TUniQuery;
    qryCliente : TFDQuery;
  public
    { Public declarations }
    constructor create;
    destructor destroy; override;
    function ListarClientes(dt_ultima_sincronizacao : String; pagina: Integer) : TJSONArray;
  end;

var
  DmCliente: TDataModule;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

//Lista os cientes
constructor TDmCliente.create;
begin
  conexao := TDmGlobal.Create(nil);
  qryCliente:= TFDQuery.Create(nil);
  qryCliente.Connection := conexao.Conn;
  UniQuery:= TUniQuery.Create(nil);
end;

destructor TDmCliente.destroy;
begin
  conexao.Free;
  qryCliente.Free;
  qryCliente.Free;
  UniQuery.Free;
  inherited;
end;

function TDmCliente.ListarClientes (dt_ultima_sincronizacao : String;
                                    pagina: Integer) : TJSONArray;
 var
 lqryCliente : TFDQuery; // se fosse utilizar sem compnente em tempo de execução
 LDmGlobal : TDmGlobal;
begin
    if dt_ultima_sincronizacao.IsEmpty then
    raise Exception.Create('O parâmetro dt_ultima_sincronizacao, não foi informado.');

    try
        LDmGlobal := TDmGLobal.Create(nil);
        lqryCliente := TFDQuery.Create(nil);
        lqryCliente.Connection := LDmGlobal.Conn;

        //BANCO DE DADOS NEGOCIUS
        lqryCliente.Active := False;
        lqryCliente.sql.Clear;
        lqryCliente.FetchOptions.Mode := fmAll;
        lqryCliente.SQL.Add('SELECT FIRST :FIRST SKIP :SKIP * FROM (');
        lqryCliente.SQL.Add('SELECT');
        lqryCliente.SQL.Add('ISN_CLIENTE AS COD_CLIENTE,');
        lqryCliente.SQL.Add('CLICN_CLIENTE AS COD_CLIENTE_LOCAL,');
        lqryCliente.SQL.Add('CLINM_CLIENTE AS NOME_CLIENTE,');
        lqryCliente.SQL.Add('CLINM_FANTASIA AS FANTASIA,');
        lqryCliente.SQL.Add('COALESCE(NULLIF(TRIM(CLINR_CGC), ''''), CLINR_CPF) AS CNPJ_CPF,');
        lqryCliente.SQL.Add('CLINR_CGF AS INSCRICAO_ESTADUAL,');
        lqryCliente.SQL.Add('CLINR_FONE_FATURAMENTO AS FONE,');
        lqryCliente.SQL.Add('CLIDS_ENDERECO_FATURAMENTO AS ENDERECO,');
        lqryCliente.SQL.Add('CLIDS_COMPLEMENTO_FAT AS COMPLEMENTO,');
        lqryCliente.SQL.Add('CLICN_NUMERO_END_FAT AS NUMERO,');
        lqryCliente.SQL.Add('CLINM_BAIRRO AS BAIRRO,');
        lqryCliente.SQL.Add('CLINM_CIDADE AS CIDADE,');
        lqryCliente.SQL.Add('CLINR_CEP AS CEP,');
        lqryCliente.SQL.Add('CASE');
        lqryCliente.SQL.Add('WHEN CLI.CLIFG_NAO_EXPORTA_PALM = ''S''');
        lqryCliente.SQL.Add('  OR CLI.CLIFG_INATIVO = ''S'' ');
        lqryCliente.SQL.Add('THEN ''N'' ELSE ''S''');
        lqryCliente.SQL.Add('END AS IND_SINCRONIZAR,');
        lqryCliente.SQL.Add('CLINM_UF AS UF,');
        lqryCliente.SQL.Add('CLIDS_EMAIL AS EMAIL,');
        lqryCliente.SQL.Add('CLIFG_STATUS AS BLOQUEADO_FATURAMENTO,');
        lqryCliente.SQL.Add('CLINR_PRECO AS NUMERO_TABELA_PRECO,');
        lqryCliente.SQL.Add('CLIVL_LIMITE AS VALOR_LIMITE_CREDITO,');
        lqryCliente.SQL.Add('CLI.ISN_PRAZO AS COD_FORMA_PAGAMENTO,');
        lqryCliente.SQL.Add('PRA.PRADS_PRAZO AS PRAZO,');
        lqryCliente.SQL.Add('CLI.CLIFG_NAO_EXPORTA_PALM AS NAO_EXPORTAR_PALM,');
        lqryCliente.SQL.Add('CLI.ISN_PRAZO_MAX_TEMP AS COD_PRAZO_MAXIMO_TEMPORARIO,');
        lqryCliente.SQL.Add('CLIDT_PRAZO_TEMP AS DATA_PRAZO_TEMPRARIO,');
        lqryCliente.SQL.Add('CLINR_LATITUDE AS LATITUDE,');
        lqryCliente.SQL.Add('CLINR_LONGITUDE AS LONGITUDE,');
        lqryCliente.SQL.Add('CLI.DATA_ULTIMA_ALTERACAO');
        lqryCliente.SQL.Add('FROM T_CLIENTE CLI');
        lqryCliente.SQL.Add('JOIN T_BAIRRO BAIRRO ON (CLI.ISN_BAIRRO = BAIRRO.ISN_BAIRRO)');
        lqryCliente.SQL.Add('JOIN T_CIDADE CID ON (CID.ISN_CIDADE = BAIRRO.ISN_CIDADE)');
        lqryCliente.SQL.Add('JOIN T_ESTADO UF ON (UF.ISN_UF = CID.ISN_UF)');
        lqryCliente.SQL.Add('JOIN T_TIPO_CLIENTE TIPOCLI ON (CLI.ISN_TIPO_CLIENTE = TIPOCLI.ISN_TIPO_CLIENTE)');
        lqryCliente.SQL.Add('JOIN T_TIPO_LOGRADOURO TPLOGR ON (TPLOGR.ISN_TIPO_LOGRADOURO = CLI.ISN_TIPO_LOGRADOURO)');
        lqryCliente.SQL.Add('LEFT OUTER JOIN T_PRAZO PRA ON (PRA.ISN_PRAZO = CLI.ISN_PRAZO)');
        lqryCliente.SQL.Add('WHERE CLI.CLIDT_ULTIMO_RECADASTRAMENTO > :DATA_ULTIMA_ALTERACAO   --DATA_ULTIMA_ALTERACAO > :DATA_ULTIMA_ALTERACAO');
        lqryCliente.SQL.Add('ORDER BY ISN_CLIENTE');
        lqryCliente.SQL.Add(')');

        lqryCliente.ParamByName('DATA_ULTIMA_ALTERACAO').AsDateTime := ConverteData(dt_ultima_sincronizacao);

          //TRATAR A PAGINAÇÃO
        lqryCliente.ParamByName('FIRST').AsInteger := QTD_DE_REG_PAGINA_CLIENTE; //Quantos registro quero trazer
        lqryCliente.ParamByName('SKIP').AsInteger := (pagina * QTD_DE_REG_PAGINA_CLIENTE) - QTD_DE_REG_PAGINA_CLIENTE;  //Quantos tenho que pular...
        {
         o calculo do salto de registro acima é a página atual x quantidade de registro que quero,
         menos a quanditade de registro que já possui
        }
        lqryCliente.Active := True;

        // Após, Monta um  array objeto json com o resultado da query
        Result := lqryCliente.ToJSONArray;

    finally
       lDmGlobal.Free;
       lqryCliente.Free;
    end;

    {$REGION 'CODIGO ANTERIOR COMENTADO'}

//    try
//       {
//         Instancio aqui o DmGlobal, e desdruo no final da procedure com um FreeAndNill(DmGlobal)
//         para utilizar o  conceito de statless, o dmglobal não é instanciado junto com a aplicação,
//         e no final da query é destruído para não manter a conexão com o banco ativa
//        }
//
//        DmGlobal := TDmGLobal.Create(nil);
//
//        with qryCliente do
//        begin
//          {
//          Fazo select na tabela, e lista os clientes
//          }
//            Active := False;
//            sql.Clear;
//            SQL.Add('SELECT FIRST :FIRST SKIP :SKIP * '); //PARA TRATAR A PAGINAÇÃO
//            SQL.Add('FROM TAB_CLIENTE_FASTPED');
//            SQL.Add('WHERE DATA_ULT_ALTERACAO > :DATA_ULT_ALTERACAO');
//            SQL.Add('ORDER BY COD_CLIENTE');
//
//            ParamByName('DATA_ULT_ALTERACAO').Value := dt_ultima_sincronizacao;
//            //TRATAR A PAGINAÇÃO
//            ParamByName('FIRST').Value := QTD_DE_REG_PAGINA_CLIENTE; //Quantos registro quero trazer
//            ParamByName('SKIP').Value := (pagina * QTD_DE_REG_PAGINA_CLIENTE) - QTD_DE_REG_PAGINA_CLIENTE;  //Quantos tenho que pular...
//            {
//            o calculo do salto de registro acima é a página atual x quantidade de registro que quero,
//              menos a quanditade de registro que já possui
//            }
//            Active := True;
//
//            //BANCO DE DADOS NEGOCIUS
//          {  Active := False;
//            sql.Clear;
//            SQL.Add('SELECT FIRST :FIRST SKIP :SKIP * '); //TRATAR A PAGINAÇÃO
//            SQL.Add('FROM T_REPRESENTANTE_X_CLIENTE REPCLI');
//            SQL.Add('JOIN T_REPRESENTANTE REP on( REP.ISN_REPRESENTANTE = REPCLI.ISN_REPRESENTANTE )');
//            SQL.Add('join T_CLIENTE  CLI ON (CLI.ISN_CLIENTE = REPCLI.ISN_CLIENTE)');
//            SQL.Add('WHERE CLI.CLIDT_ULTIMO_RECADASTRAMENTO > :DATA_ULT_ALTERACAO');
//          //  SQL.Add('AND REP.REPCN_REPRESENTANTE = :COD_REPRESENTANTE ');
//            SQL.Add('ORDER BY CLICN_CLIENTE');
//
//            ParamByName('DATA_ULT_ALTERACAO').Value := dt_ultima_sincronizacao;
//
//            //TRATAR A PAGINAÇÃO
//            ParamByName('FIRST').Value := QTD_DE_REG_PAGINA_CLIENTE; //Quantos registro quero trazer
//            ParamByName('SKIP').Value := (pagina * QTD_DE_REG_PAGINA_CLIENTE) - QTD_DE_REG_PAGINA_CLIENTE;  //Quantos tenho que pular...
//            {
//            o calculo do salto de registro acima é a página atual x quantidade de registro que quero,
//              menos a quanditade de registro que já possui
//            }
//
//          //  Active := True;
//
//        end;
//
//        // Após, Monta um  array objeto json com o resultado da query
//           Result := qry.ToJSONArray;
//
//    finally
//         FreeAndNil(DmGlobal);
//    end;

    {$ENDREGION}
end;

end.
