
unit DateModule.Cliente;

interface

uses
  Uni,
  uMD5,

  Data.DB,

  DataSet.Serialize,

  DateModule.Global,

  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.DApt,
  FireDAC.Stan.Option,

  System.Classes,
  System.JSON,
  System.SysUtils, FireDAC.Stan.Intf, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async;

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
        lqryCliente.SQL.Add('SELECT');
        lqryCliente.SQL.Add('ISN_CLIENTE COD_CLIENTE,');
        lqryCliente.SQL.Add('CLICN_CLIENTE COD_CLIENTE_LOCAL,');
        lqryCliente.SQL.Add('CLINM_CLIENTE NOME_CLIENTE,');
        lqryCliente.SQL.Add('CLINM_FANTASIA FANTASIA,');
        lqryCliente.SQL.Add('COALESCE(NULLIF(TRIM(CLINR_CGC), ''''), CLINR_CPF) AS CNPJ_CPF,');
        lqryCliente.SQL.Add('CLINR_CGF INSCRICAO_ESTADUAL,');
        lqryCliente.SQL.Add('CLINR_FONE_FATURAMENTO FONE,');
        lqryCliente.SQL.Add('CLIDS_ENDERECO_FATURAMENTO ENDERECO,');
        lqryCliente.SQL.Add('CLIDS_COMPLEMENTO_FAT,');
        lqryCliente.SQL.Add('CLICN_NUMERO_END_FAT NUMERO,');
        lqryCliente.SQL.Add('CLINM_BAIRRO BAIRRO,');
        lqryCliente.SQL.Add('CLINM_CIDADE CIDADE,');
        lqryCliente.SQL.Add('CLINR_CEP CEP,');
        lqryCliente.SQL.Add('CLINM_UF UF,');
        lqryCliente.SQL.Add('CLIDS_EMAIL EMAIL,');
        lqryCliente.SQL.Add('CLIFG_INATIVO INATIVO,');
        lqryCliente.SQL.Add('CLIFG_STATUS BLOQUEADO_FATURAMENTO,');
        lqryCliente.SQL.Add('CLINR_PRECO NUMERO_TABELA_PRECO,');
        lqryCliente.SQL.Add('CLIVL_LIMITE VALOR_LIMITE_CREDITO,');
     //   lqryCliente.SQL.Add('TIPOCLI.ISN_FORMA_PAGAMENTO COD_FORMA_PAGAMENTO,');
        lqryCliente.SQL.Add('CLI.ISN_PRAZO COD_FORMA_PAGAMENTO,');
        lqryCliente.SQL.Add('PRA.PRADS_PRAZO PRAZO,');
        lqryCliente.SQL.Add('CLI.CLIFG_NAO_EXPORTA_PALM NAO_EXPORTAR_PALM,');
        lqryCliente.SQL.Add('CLI.ISN_PRAZO_MAX_TEMP COD_PRAZO_MAXIMO_TEMPORARIO,');
        lqryCliente.SQL.Add('CLIDT_PRAZO_TEMP DATA_PRAZO_TEMPRARIO,');
        lqryCliente.SQL.Add('CLINR_LATITUDE LATITUDE,');
        lqryCliente.SQL.Add('CLINR_LONGITUDE LONGITUDE,');
        lqryCliente.SQL.Add('CLI.DATA_ULTIMA_ALTERACAO');
        lqryCliente.SQL.Add('from T_CLIENTE CLI');
        lqryCliente.SQL.Add('join T_BAIRRO BAIRRO on (CLI.ISN_BAIRRO = BAIRRO.ISN_BAIRRO)');
        lqryCliente.SQL.Add('join T_CIDADE CID on (CID.ISN_CIDADE = BAIRRO.ISN_CIDADE)');
        lqryCliente.SQL.Add('join T_ESTADO UF on (UF.ISN_UF = CID.ISN_UF)');
        lqryCliente.SQL.Add('join T_TIPO_CLIENTE TIPOCLI on (CLI.ISN_TIPO_CLIENTE = TIPOCLI.ISN_TIPO_CLIENTE)');
        lqryCliente.SQL.Add('join T_TIPO_LOGRADOURO TPLOGR on (TPLOGR.ISN_TIPO_LOGRADOURO = CLI.ISN_TIPO_LOGRADOURO)');
        lqryCliente.SQL.Add('left outer join T_PRAZO PRA on (PRA.ISN_PRAZO = CLI.ISN_PRAZO)');
        lqryCliente.SQL.Add('WHERE CLI.CLIFG_NAO_EXPORTA_PALM = ''N''');
        lqryCliente.SQL.Add('AND CLI.DATA_ULTIMA_ALTERACAO  > :DATA_ULTIMA_ALTERACAO');
        lqryCliente.SQL.Add('ORDER BY ISN_CLIENTE');

        lqryCliente.ParamByName('DATA_ULTIMA_ALTERACAO').Value := dt_ultima_sincronizacao;
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
