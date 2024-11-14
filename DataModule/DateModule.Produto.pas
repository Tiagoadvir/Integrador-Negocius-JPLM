unit DateModule.Produto;

interface

uses
  uFunctions,

  Data.DB,

  DataSet.Serialize,
  DataSet.Serialize.Config,

  DateModule.Global,

  FMX.Graphics,

  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.DApt,
  FireDAC.DApt.Intf,
  FireDAC.DatS,
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
  FireDAC.Stan.Param,
  FireDAC.Stan.Pool,
  FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait,

  System.Classes,
  System.JSON,
  System.SysUtils,
  System.Variants,

  system.IniFiles;

type
  TDmProduto = class(TDataModule)
    qryProduto: TFDQuery;
    EventAlerter: TFDEventAlerter;
    procedure EventAlerterAlert(ASender: TFDCustomEventAlerter; const AEventName: string; const AArgument: Variant);
    procedure DataModuleCreate(Sender: TObject);
  private
    Conn : TFDConnection;
    Conexao : TDmGlobal;
    procedure ConfiguraParametrosDatasetSerialize;
    function EnviaAtualizacaoEstoque(Const aNomeEvento : string ; out aEstoque : TJSONArray) : Boolean;

    { Private declarations }
  public
    { Public declarations }
    constructor create;
    destructor destroy; override;
    function ListarProdutos(dt_ultima_sincronizacao: String;
                                             pagina: Integer): TJSONArray;
    function Listar_Estoque_Produtos(pagina: Integer) : TJSONArray;
  end;

var
  DmProduto: TDmProduto;

implementation

uses
  RESTRequest4D,
  uConstante,
  uMD5,

  FMX.Dialogs;

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

constructor TDmProduto.create;
begin
   Conexao   := TDmGlobal.Create(nil);
   qryProduto := TFDQuery.Create(nil);
   qryProduto.Connection :=  Conexao.conn;
end;

procedure TDmProduto.DataModuleCreate(Sender: TObject);
begin
   EventAlerter.Connection := DmGlobal.Conn;
   EventAlerter.Active := true;
end;

destructor TDmProduto.destroy;
begin
  Conexao.Free;
  qryProduto.Free;
  inherited;
end;

procedure TDmProduto.ConfiguraParametrosDatasetSerialize;
begin
   //Configuro para que o datasetSeriaize não altere os nomes na hora de montar o Json
   //Apenas converta para minúsculo
     TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower; // ---> Nome_usuario --> nome_usuario e não nomeusuario
   //Define o separador de milhar padrão com .
     TDatasetSerializeConfig.GetInstance.Import.DecimalSeparator := '.';  //--> R500,00 ---> 500.00

     DmGlobal.Conn.Connected := True;
end;

//Lista produtos
function TDmProduto.ListarProdutos(dt_ultima_sincronizacao : String;
                                  pagina: Integer) : TJSONArray;
begin
    ConfiguraParametrosDatasetSerialize;

    if dt_ultima_sincronizacao.IsEmpty then
    raise Exception.Create('O parâmetro dt_ultima_sincronizacao, não foi informado.');


            //BANCO DE DADOS NEGOCIUS
           qryProduto.Active := False;
           qryProduto.SQL.Clear;
           qryProduto.FetchOptions.Mode := fmAll;
           qryProduto.SQL.Add('SELECT  FIRST :FIRST SKIP :SKIP * FROM ( -- //TRATAR A PAGINAÇÃO');
           qryProduto.SQL.Add('SELECT DISTINCT');
           qryProduto.SQL.Add('PROD.ISN_PRODUTO COD_PRODUTO,');
           qryProduto.SQL.Add('PROD.PROCC_PRODUTO COD_PRODUTO_LOCAL,');
           qryProduto.SQL.Add('PROD.PRODS_PRODUTO DESCRICAO,');
           qryProduto.SQL.Add('PROD.PROQT_MULT_VENDA MULTIPLO_DE_VENDA,');
           qryProduto.SQL.Add('(EST.ESTQT_QUANTIDADE - EST.ESTQT_RESERVA) QTD_ESTOQUE,');
           qryProduto.SQL.Add('PREC.PREVL_UNITARIO VALOR,');
           qryProduto.SQL.Add('PROD.PROVL_PRECO_MINIMO AS PRECO_MINIMO,');
           qryProduto.SQL.Add('PROD.PROVL_PRECO_MAXIMO AS PRECO_MAXIMO,');
           qryProduto.SQL.Add('PROD.PROFG_EXPORTA_PALM,');
           qryProduto.SQL.Add('PROD.DATA_ULTIMA_ALTERACAO');
           qryProduto.SQL.Add('FROM T_PRODUTO PROD');
           qryProduto.SQL.Add('JOIN T_PRECO PREC ON (PREC.ISN_PRODUTO = PROD.ISN_PRODUTO)');
           qryProduto.SQL.Add('JOIN T_ESTOQUE EST ON (EST.ISN_PRODUTO = PROD.ISN_PRODUTO)');
           qryProduto.SQL.Add('JOIN T_TIPO_PRODUTO  TIPO ON (TIPO.ISN_TIPO_PRODUTO = PROD.ISN_TIPO_PRODUTO)');
           qryProduto.SQL.Add('WHERE (EST.ESTQT_QUANTIDADE - EST.ESTQT_RESERVA) > 0');
           qryProduto.SQL.Add('AND  PROD.PROFG_USO = ''S''');
           qryProduto.SQL.Add('AND PREC.PRENR_PRECO = 1 --//TABELA DE PRECO');
           qryProduto.SQL.Add('AND  TIPO.TPFG_TIPO_PRODUTO = ''V''');
           qryProduto.SQL.Add('AND PREC.prefg_ult_preco = ''S''');
           qryProduto.SQL.Add('AND PROD.DATA_ULTIMA_ALTERACAO > :DATA_ULTIMA_ALTERACAO ');
           qryProduto.SQL.Add('ORDER BY PRODS_PRODUTO)');
           qryProduto. ParamByName('DATA_ULTIMA_ALTERACAO').Value := dt_ultima_sincronizacao;

           //TRATAR A PAGINAÇÃO
          qryProduto.ParamByName('FIRST').Value := QTD_DE_REG_PAGINA_PRODUTO; //Quantos registro quero trazer
          qryProduto.ParamByName('SKIP').Value := (pagina * QTD_DE_REG_PAGINA_PRODUTO) - QTD_DE_REG_PAGINA_PRODUTO;  //Quantos tenho que pular...
           {
           o calculo do salto de registro acima é a página atual x quantidade de registro que quero,
             menos a quanditade de registro que já possui
           }

           qryProduto.Active := True;


        // Após, Monta um  array objeto json com o resultado da query
         Result := qryProduto.ToJSONArray;
end;

function TDmProduto.Listar_Estoque_Produtos(pagina: Integer) : TJSONArray;
begin
    ConfiguraParametrosDatasetSerialize;

    with qryProduto do
    begin
          {
          Fazo select na tabela, e lista os produtos
          }


            //BANCO DE DADOS NEGOCIUS
            Active := False;
            sql.Clear;
            SQL.Add('SELECT FIRST :FIRST SKIP :SKIP * FROM (');
            SQL.Add('SELECT DISTINCT');
            SQL.Add('EST.ISN_PRODUTO COD_PRODUTO,');
            SQL.Add('PROD.PRODS_PRODUTO,');
            SQL.Add('PROD.PROQT_MULT_VENDA,');
            SQL.Add('(EST.ESTQT_QUANTIDADE - EST.ESTQT_RESERVA) AS SALDO_FISCAL');
            SQL.Add('FROM T_ESTOQUE EST');
            SQL.Add('JOIN T_PRODUTO PROD ON PROD.ISN_PRODUTO = EST.ISN_PRODUTO');
            SQL.Add('JOIN T_TIPO_PRODUTO TIPO ON TIPO.ISN_TIPO_PRODUTO = PROD.ISN_TIPO_PRODUTO');
            SQL.Add('WHERE TIPO.TPFG_TIPO_PRODUTO =''V''');
            SQL.Add('AND PROD.PROFG_USO = ''S''');
            SQL.Add('ORDER BY EST.ISN_PRODUTO');
            SQL.Add(')');

            //TRATAR A PAGINAÇÃO
            ParamByName('FIRST').Value := QTD_DE_REG_PAGINA_ESTOQUE; //Quantos registro quero trazer
            ParamByName('SKIP').Value := (pagina * QTD_DE_REG_PAGINA_ESTOQUE) - QTD_DE_REG_PAGINA_ESTOQUE;  //Quantos tenho que pular...
            {
            o calculo do salto de registro acima é a página atual x quantidade de registro que quero,
              menos a quanditade de registro que já possui
            }

            Active := True;
    end;
        // Após, Monta um  array objeto json com o resultado da query
           Result := qryProduto.ToJSONArray;
end;

procedure TDmProduto.EventAlerterAlert(ASender: TFDCustomEventAlerter; const AEventName: string; const AArgument: Variant);
var
  lresp : Iresponse;
  Estoque : TJSONArray;
  json : TJSONObject;
begin


   // Verificar se o evento é 'estoque_fiscal_disponivel_alterado'
  if AEventName.StartsWith('estoque_fiscal_disponivel_alterado') then
  begin

     if   EnviaAtualizacaoEstoque(AEventName, Estoque) then
     begin
       json := TJSONObject.Create;
       json.AddPair('estoque_atual', Estoque);
     end;

   lresp := TRequest.New.BaseURL(URL_AWS)
            .Resource('/v1/produto/estoque/atualiza')
            .TokenBearer(TGetToken.SolicitaToken)
            .ContentType('application/json')
            .AddBody(json)
            .Post;
  end;

end;

function TDmProduto.EnviaAtualizacaoEstoque(Const aNomeEvento : string ; out aEstoque : TJSONArray) : Boolean;
begin

  qryProduto.Active := false;
  qryProduto.SQL.Clear;
  qryProduto.SQL.Add('select PRODUTOID, RESERVAFISCAL from LOGEVENTOS where EVENTONOME = :EVENTONOME');
  qryProduto.ParamByName('EVENTONOME').AsString := aNomeEvento;
  qryProduto.Active := True;

  aEstoque := qryProduto.ToJSONArray() ;

  Result := qryProduto.RecordCount > 0;

   // Realiza o DELETE após a leitura dos dados
   for var I := 0 to aEstoque.Size - 1 do
   begin
     var  JSONObj := TJSONObject.Create;

      JSONObj := aEstoque.Items[I] as TJSONObject;

    qryProduto.Active := false;
    qryProduto.SQL.Clear;
    qryProduto.SQL.Add('DELETE FROM LOGEVENTOS where EVENTONOME = :EVENTONOME AND PRODUTOID = :PRODUTOID');
    qryProduto.ParamByName('EVENTONOME').AsString := aNomeEvento;
    qryProduto.ParamByName('PRODUTOID').AsInteger := JSONObj.GetValue<Integer>('produtoid');
    qryProduto.ExecSQL;
   end;

end;
end.
