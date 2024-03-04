unit DateModule.CondPagto;

interface
 Uses
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

  system.IniFiles,
  DateModule.Global,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet;

  type
 TDmCondPagto = class(TDataModule)
    qry: TFDQuery;
    qryforma: TFDQuery;


  private
  public
    procedure ConfiguraParametrosDatasetSerialize;
    function ListarCondPagto: TJSONArray;
    function ListarPrazo(pagina : integer) : TJSONArray;
    function ListarFormaPagto: TJSONArray;
    function ListarClienteFormaPagto(dt_ultima_sincronizacao : String;
                                              cod_usuario: Integer) : TJSONArray;
    function Listar_prazo_x_pedido(dt_ultima_alteracao: string): TJSONArray;
    public
  end;

var
  DmCondPagto: TDmCondPagto;

implementation

uses
  uMD5;
{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}


procedure TDmCondPagto.ConfiguraParametrosDatasetSerialize;
var
 DmGlobal : TDmGlobal;
begin
    DmGlobal := TDmGlobal.Create(nil);
   //Configuro para que o datasetSeriaize não altere os nomes na hora de montar o Json
   //Apenas converta para minúsculo
     TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower; // ---> Nome_usuario --> nome_usuario e não nomeusuario
   //Define o separador de milhar padrão com .
     TDatasetSerializeConfig.GetInstance.Import.DecimalSeparator := '.';  //--> R500,00 ---> 500.00


     DmGlobal.Conn.Connected := True;
end;


//Lista As condições de pagamento
function TDmCondPagto.ListarCondPagto : TJSONArray;
 var
  qry : TFDQuery; // se fosse utilizar sem compnente em tempo de execução
  DmGlobal : TDmGlobal;
begin
     ConfiguraParametrosDatasetSerialize;
    try
     DmGlobal := TDmGlobal.Create(nil);
     qry := TFDQuery.Create(nil);
     qry.Connection := DmGlobal.conn;

          {
          Fazo select na tabela, e lista as condições de pagamento
          }
            qry.Active := False;
            qry.sql.Clear;
            qry.SQL.Add('SELECT ISN_PRAZO COD_PRAZO,');
            qry.SQL.Add('PRADS_PRAZO DESCRICAO_PRAZO,');
            qry.SQL.Add('PRAVL_PEDIDO_MINIMO VALOR_MINIMO,');
            qry.SQL.Add('PRAFG_EXP_PALM,');
            qry.SQL.Add('PRANR_PARCELA NUMERO_PARCELAS,');
            qry.SQL.Add('PRAQT_INTERVALO INTERVALO_ENTRE_PARCELA,');
            qry.SQL.Add('PRAQT_DIAS_ENTRADA DIAS_ENTRADA');
            qry.SQL.Add('FROM  T_PRAZO');
            qry.SQL.Add('WHERE PRAFG_EXP_PALM = ''S''');
            qry.SQL.Add('ORDER BY ISN_PRAZO');

           qry.Active := True;


        // Após, Monta um  array objeto json com o resultado da query
           Result := qry.ToJSONArray;

    finally
         FreeAndNil(qry);
         FreeAndNil(DmGlobal);
    end;

end;


//-----  DISPARA DADOS PARA API-----------
//Lista As condições os prazos   OK (06/02/2024)
function TDmCondPagto.ListarPrazo(pagina : integer) : TJSONArray;
 var
  qry : TFDQuery; // se fosse utilizar sem compnente em tempo de execução
  DmGlobal : TDmGlobal;
begin
     ConfiguraParametrosDatasetSerialize;

    try
     DmGlobal := TDmGlobal.Create(nil);
     qry := TFDQuery.Create(nil);
     qry.Connection := DmGlobal.conn;

        with qry do
        begin
          {
          Fazo select na tabela, e lista as condições de pagamento
          }
          Active := False;
          sql.Clear;
          SQL.Add('SELECT  FIRST :FIRST SKIP :SKIP * FROM ( SELECT ');
          SQL.Add('ISN_PRAZO AS COD_PRAZO,');
          SQL.Add('PRADS_PRAZO AS DESCRICAO_PRAZO,');
          SQL.Add('PRAVL_PEDIDO_MINIMO AS VALOR_PED_MINIMO,');
          SQL.Add('PRAFG_EXP_PALM AS EXPORTA_PALM,');
          SQL.Add('PRANR_PARCELA AS QTD_PARCELA,');
          SQL.Add('PRAQT_INTERVALO AS INTERVALO_ENTRE_PARCELA,');
          SQL.Add('PRAQT_DIAS_ENTRADA AS DIAS_ENTRADA');
          SQL.Add('FROM');
          SQL.Add('T_PRAZO');
          SQL.Add('WHERE');
          SQL.Add('PRAFG_EXP_PALM = ''S''');
          SQL.Add('ORDER BY');
          SQL.Add('ISN_PRAZO)');

                     //TRATAR A PAGINAÇÃO
          ParamByName('FIRST').Value := QTD_DE_REG_PAGINA_PRODUTO; //Quantos registro quero trazer
          ParamByName('SKIP').Value := (pagina * QTD_DE_REG_PAGINA_PRODUTO) - QTD_DE_REG_PAGINA_PRODUTO;

          Active := True;
        end;

        // Após, Monta um  array objeto json com o resultado da query
           Result := qry.ToJSONArray;

    finally
         FreeAndNil(qry);
         FreeAndNil(DmGlobal);
    end;

end;

//Lista As formas de pagamento   OK (06/02/2024)
function TDmCondPagto.ListarFormaPagto : TJSONArray;
 var
 qryforma : TFDQuery; // se fosse utilizar sem compnente em tempo de execução
  DmGlobal : TDmGlobal;
begin
     ConfiguraParametrosDatasetSerialize;
    try
     DmGlobal := TDmGlobal.Create(nil);
     qryforma := TFDQuery.Create(nil);
     qryforma.Connection := DmGlobal.conn;

     {
       Fazo select na tabela, e lista as condições de pagamento
     }
         qryforma.Active := False;
         qryforma.sql.Clear;
         qryforma.SQL.Add('SELECT ISN_FORMA_PAGAMENTO ID_FORMA, FPADS_FORMA DESCRICAO_FORMA');
         qryforma.SQL.Add('FROM T_FORMA_PAGAMENTO ');
         qryforma.SQL.Add('WHERE FPAFG_EXP_PALM = ''S'' ');
         qryforma. Active := True;


        // Após, Monta um  array objeto json com o resultado da query
           Result := qryforma.ToJSONArray;

    finally
         FreeAndNil(qryforma);
         FreeAndNil(DmGlobal);
    end;

end;

//Lista As condições de pagamento
function TDmCondPagto.ListarClienteFormaPagto(dt_ultima_sincronizacao : String;
                                              cod_usuario: Integer) : TJSONArray;
 var
 qryforma : TFDQuery; // se fosse utilizar sem compnente em tempo de execução
  DmGlobal : TDmGlobal;
begin
     ConfiguraParametrosDatasetSerialize;
     DmGlobal := TDmGlobal.Create(nil);
     qryforma := TFDQuery.Create(nil);
     qryforma.Connection := DmGlobal.conn;

    try

        with qryforma do
        begin
          {
          Fazo select na tabela, e lista as condições de pagamento
          }
           Active := False;
            SQL.Add('SELECT DISTINCT CFPA.ISN_FORMA_PAGAMENTO ID_FORMA, CFPA.ISN_CLI_FORMA_PAGAMENTO ID_CLIENTE_FORMA_PAGTO, CFPA.ISN_CLIENTE ID_CLIENTE,');
            SQL.Add('CLI.CLICN_CLIENTE COD_CLIENTE_OFICIAL, CFPA.DATA_ULTIMA_ALTERACAO');
            SQL.Add('FROM T_REPRESENTANTE_X_CLIENTE REP ');
            SQL.Add('JOIN T_CLIENTE CLI ON (CLI.ISN_CLIENTE = REP.ISN_CLIENTE) ');
            SQL.Add('JOIN T_CLIENTE_X_FORMA_PAGAMENTO CFPA ON (CFPA.ISN_CLIENTE = CLI.ISN_CLIENTE)');
            SQL.Add('JOIN T_REPRESENTANTE REP1 ON (REP1.ISN_REPRESENTANTE = REP.ISN_REPRESENTANTE)');
            // SQL.Add('WHERE CLI.CLIFG_INATIVO = ''N'' ');
            SQL.Add('WHERE CLI.DATA_ULTIMA_ALTERACAO > :DATA_ULTIMA_ALTERACAO');
            SQL.Add('AND REP1.REPCN_REPRESENTANTE = :REPCN_REPRESENTANTE');  //COLOCAR O CÓDIGO DO REPRESENTANTE


            ParamByName('DATA_ULTIMA_ALTERACAO').Value := dt_ultima_sincronizacao;
            ParamByName('REPCN_REPRESENTANTE').Value := cod_usuario;

            Active := True;
        end;

        // Após, Monta um  array objeto json com o resultado da query
           Result := qryforma.ToJSONArray;

    finally
         FreeAndNil(qryforma);
         FreeAndNil(DmGlobal);
    end;

    {$REGION 'CODIGO ANTERIOR PAGINANDO PARA O MOBIBLE - COMENTADO'}

//    try
//
//        with qryforma do
//        begin
//          {
//          Fazo select na tabela, e lista as condições de pagamento
//          }
//           Active := False;
//            sql.Clear;
//            SQL.Add('SELECT FIRST :FIRST SKIP :SKIP  * FROM (');
//            SQL.Add('SELECT DISTINCT CFPA.ISN_FORMA_PAGAMENTO ID_FORMA, CFPA.ISN_CLI_FORMA_PAGAMENTO ID_CLIENTE_FORMA_PAGTO, CFPA.ISN_CLIENTE ID_CLIENTE,');
//            SQL.Add('CLI.CLICN_CLIENTE COD_CLIENTE_OFICIAL');
//            SQL.Add('FROM T_REPRESENTANTE_X_CLIENTE REP ');
//            SQL.Add('JOIN T_CLIENTE CLI ON  ( CLI.ISN_CLIENTE = REP.ISN_CLIENTE) ');
//            SQL.Add('JOIN T_CLIENTE_X_FORMA_PAGAMENTO CFPA ON (CFPA.ISN_CLIENTE = CLI.ISN_CLIENTE)');
//            SQL.Add('JOIN T_REPRESENTANTE REP1 ON (REP1.ISN_REPRESENTANTE =REP.ISN_REPRESENTANTE)');
//           // SQL.Add('WHERE CLI.CLIFG_INATIVO = ''N'' ');
//            SQL.Add('WHERE CLI.CLIDT_ULTIMO_RECADASTRAMENTO > :CLIDT_ULTIMO_RECADASTRAMENTO');
//            SQL.Add('AND REP1.REPCN_REPRESENTANTE = :REPCN_REPRESENTANTE )');  //COLOCAR O CÓDIGO DO REPRESENTANTE
//
//            ParamByName('CLIDT_ULTIMO_RECADASTRAMENTO').Value := dt_ultima_sincronizacao;
//            ParamByName('REPCN_REPRESENTANTE').Value := cod_usuario;
//
//            //TRATAR A PAGINAÇÃO
//            ParamByName('FIRST').Value := QTD_DE_REG_PAGINA_CLI_X_FORMA_PAGTO; //Quantos registro quero trazer
//            ParamByName('SKIP').Value := (pagina * QTD_DE_REG_PAGINA_CLI_X_FORMA_PAGTO) - QTD_DE_REG_PAGINA_CLI_X_FORMA_PAGTO;  //Quantos tenho que pular...
//
//
//            Active := True;
//        end;
//
//        // Após, Monta um  array objeto json com o resultado da query
//           Result := qryforma.ToJSONArray;
//
//    finally
//         FreeAndNil(qryforma);
//         FreeAndNil(DmGlobal);
//    end;

    {$ENDREGION}
end;

function TDmCondPagto.Listar_prazo_x_pedido(dt_ultima_alteracao: string): TJSONArray;
 var
  qryforma : TFDQuery; // se fosse utilizar sem compnente em tempo de execução
  DmGlobal : TDmGlobal;
begin
     ConfiguraParametrosDatasetSerialize;

     DmGlobal := TDmGlobal.Create(nil);
     qryforma := TFDQuery.Create(nil);
     qryforma.Connection := DmGlobal.conn;
  try
     qryforma.Active := false;
     qryforma.SQL.Clear;
//     qryforma.SQL.Add('SELECT  FIRST :FIRST SKIP :SKIP * FROM (');
     qryforma.SQL.Add('SELECT');
     qryforma.SQL.Add('TPP.ISN_TIPO_PEDIDO_PRAZO COD_PRAZO_X_PEDIDO,');
     qryforma.SQL.Add('TPP.ISN_TIPO_PEDIDO COD_TIPO_PEDIDO,');
     qryforma.SQL.Add('TPP.ISN_PRAZO COD_PRAZO');
     qryforma.SQL.Add('FROM T_TIPO_PEDIDO_PRAZO TPP');
     qryforma.SQL.Add('JOIN T_TIPO_PEDIDO TP ON (TP.ISN_TIPO_PEDIDO = TPP.ISN_TIPO_PEDIDO)');
     qryforma.SQL.Add('JOIN T_PRAZO TPZ ON (TPZ.ISN_PRAZO = TPP.ISN_PRAZO)');
     qryforma.SQL.Add('WHERE TP.TIPFG_EXPORTA_PALM = ''S''');
     qryforma.SQL.Add('AND TPZ.PRAFG_EXP_PALM = ''S''');
     qryforma.SQL.Add('AND TPZ.PRAFG_INATIVO = ''N'' ');
     qryforma.SQL.Add('AND TPP.DATA_ULTIMA_ALTERACAO > :DATA_ULTIMA_ALTERACAO');

     qryforma.ParamByName('DATA_ULTIMA_ALTERACAO').Value := dt_ultima_alteracao;

     qryforma.Active := True;


     // Após, Monta um  array objeto json com o resultado da query
     Result := qryforma.ToJSONArray;

  finally
    FreeAndNil(qryforma);
    FreeAndNil(DmGlobal);
  end;

end;


end.

