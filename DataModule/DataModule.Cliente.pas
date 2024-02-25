unit DataModule.Cliente;

interface
 Uses
  Data.DB,

  DataSet.Serialize,
  DataSet.Serialize.Config,
  RESTRequest4D,
  sYSTEM.JSON,

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
  System.SysUtils,
  System.Variants,

  system.IniFiles, DateModule.Global, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.Comp.DataSet;
type
  TDmCliente = class(TDataModule)
    qryCliente: TFDQuery;

  private
    { Private declarations }
    procedure ConfiguraParametrosDatasetSerialize;

  public
    { Public declarations }
     function ListarClientes(dt_ultima_sincronizacao : String; pagina, cod_usuario: Integer) : TJSONArray;
  end;

var
  DmCliente: TDmCliente;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDmCliente.ConfiguraParametrosDatasetSerialize;
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
 function TDmCliente.ListarClientes(dt_ultima_sincronizacao : String; pagina, cod_usuario: Integer) : TJSONArray;
 var
  qrycliente : TFDQuery; // se fosse utilizar sem compnente em tempo de execução
  DmGlobal : TDmGlobal;
begin
     ConfiguraParametrosDatasetSerialize;
    try
     DmGlobal := TDmGlobal.Create(nil);
     qryCliente := TFDQuery.Create(nil);
     qryCliente.Connection := DmGlobal.conn;

        with qryCliente do
        begin
          {
          Fazo select na tabela, e lista as condições de pagamento
          }
           Active := False;
            sql.Clear;

            SQL.Add('SELECT FIRST :FIRST SKIP :SKIP  * FROM (SELECT CLI.ISN_CLIENTE , CLI.CLICN_CLIENTE AS COD_CLIENTE_OFICIAL,');
            SQL.Add('CLI.CLINM_CLIENTE, CLI.CLINM_FANTASIA,ISN_PRAZO AS COD_PRAZO, CLI.CLIFG_INATIVO AS IND_SINCRONIZAR,');
            SQL.Add('CLI.CLINR_CGC, CLI.CLINR_FONE_ENTREGA, CLI.CLIDS_EMAIL, CLI.CLIDS_ENDERECO_ENTREGA,');
            SQL.Add('CLI.CLICN_NUMERO_END_ENT,CLI.CLINR_CEP_COBRANCA,CLI.CLIDS_OBS,CLI.CLIVL_LIMITE,');
            SQL.add('CLI.CLINM_CIDADE, CLI.CLINM_UF, CLI.CLINM_BAIRRO, CLI.CLIDS_COMPLEMENTO_ENT,');
            SQL.add('CLI.CLINR_LATITUDE, CLI.CLINR_LONGITUDE, CLI.CLIDT_ULTIMO_RECADASTRAMENTO');
            SQL.add('FROM T_CLIENTE CLI');
            SQL.add('JOIN T_REPRESENTANTE_X_CLIENTE REPCLI ON (REPCLI.ISN_CLIENTE = CLI.ISN_CLIENTE)');
            SQL.add('JOIN T_REPRESENTANTE REP ON (REP.ISN_REPRESENTANTE = REPCLI.ISN_REPRESENTANTE)');
            SQL.add('WHERE REP.REPCN_REPRESENTANTE = :COD_REPRESENTANTE '); //PASSAR REPCN_REPRESENTANTE = :COD_REPRESENTANTE  COMO PARAMETRO O CÓDIGO DO VENDEDOR
            SQL.Add('AND CLI.CLIDT_ULTIMO_RECADASTRAMENTO  > :CLIDT_ULTIMO_RECADASTRAMENTO )');

            ParamByName('COD_REPRESENTANTE').Value := cod_usuario;
            ParamByName('CLIDT_ULTIMO_RECADASTRAMENTO').Value := dt_ultima_sincronizacao;
            //TRATAR A PAGINAÇÃO
            ParamByName('FIRST').Value := QTD_DE_REG_PAGINA_CLIENTE; //Quantos registro quero trazer
            ParamByName('SKIP').Value := (pagina * QTD_DE_REG_PAGINA_CLIENTE) - QTD_DE_REG_PAGINA_CLIENTE;  //Quantos tenho que pular...
            {
            o calculo do salto de registro acima é a página atual x quantidade de registro que quero,
              menos a quanditade de registro que já possui
            }

           Active := True;
        end;

        // Após, Monta um  array objeto json com o resultado da query
           Result := qrycliente.ToJSONArray;

    finally
         FreeAndNil(qrycliente);
         FreeAndNil(DmGlobal);
    end;

end;
end.
