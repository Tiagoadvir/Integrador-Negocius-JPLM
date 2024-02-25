unit DateModule.Produto;

interface

uses
  uFunctions,
  Data.DB,

  DataSet.Serialize,
  DataSet.Serialize.Config,

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

  system.IniFiles, DateModule.Global, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.Comp.DataSet;

type
  TDmProduto = class(TDataModule)
    qryProduto: TFDQuery;
  private
    Conn : TFDConnection;
    Conexao : TDmGlobal;
    procedure ConfiguraParametrosDatasetSerialize;

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
  uMD5;

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

constructor TDmProduto.create;
begin
   Conexao   := TDmGlobal.Create(nil);
   qryProduto := TFDQuery.Create(nil);
   qryProduto.Connection :=  Conexao.conn;
end;

destructor TDmProduto.destroy;
begin
  Conexao.Free;
  qryProduto.Free;
  inherited;
end;

procedure TDmProduto.ConfiguraParametrosDatasetSerialize;
begin
   //Configuro para que o datasetSeriaize n�o altere os nomes na hora de montar o Json
   //Apenas converta para min�sculo
     TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower; // ---> Nome_usuario --> nome_usuario e n�o nomeusuario
   //Define o separador de milhar padr�o com .
     TDatasetSerializeConfig.GetInstance.Import.DecimalSeparator := '.';  //--> R500,00 ---> 500.00

     DmGlobal.Conn.Connected := True;
end;

//Lista produtos
function TDmProduto.ListarProdutos(dt_ultima_sincronizacao : String;
                                  pagina: Integer) : TJSONArray;
begin
    ConfiguraParametrosDatasetSerialize;

    if dt_ultima_sincronizacao.IsEmpty then
    raise Exception.Create('O par�metro dt_ultima_sincronizacao, n�o foi informado.');


            //BANCO DE DADOS NEGOCIUS
           qryProduto.Active := False;
           qryProduto.SQL.Clear;
           qryProduto.FetchOptions.Mode := fmAll;
           qryProduto.SQL.Add('SELECT  FIRST :FIRST SKIP :SKIP * FROM ( -- //TRATAR A PAGINA��O');
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

           //TRATAR A PAGINA��O
          qryProduto.ParamByName('FIRST').Value := QTD_DE_REG_PAGINA_PRODUTO; //Quantos registro quero trazer
          qryProduto.ParamByName('SKIP').Value := (pagina * QTD_DE_REG_PAGINA_PRODUTO) - QTD_DE_REG_PAGINA_PRODUTO;  //Quantos tenho que pular...
           {
           o calculo do salto de registro acima � a p�gina atual x quantidade de registro que quero,
             menos a quanditade de registro que j� possui
           }

           qryProduto.Active := True;


        // Ap�s, Monta um  array objeto json com o resultado da query
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

            //TRATAR A PAGINA��O
            ParamByName('FIRST').Value := QTD_DE_REG_PAGINA_ESTOQUE; //Quantos registro quero trazer
            ParamByName('SKIP').Value := (pagina * QTD_DE_REG_PAGINA_ESTOQUE) - QTD_DE_REG_PAGINA_ESTOQUE;  //Quantos tenho que pular...
            {
            o calculo do salto de registro acima � a p�gina atual x quantidade de registro que quero,
              menos a quanditade de registro que j� possui
            }

            Active := True;
    end;
        // Ap�s, Monta um  array objeto json com o resultado da query
           Result := qryProduto.ToJSONArray;
end;

end.
