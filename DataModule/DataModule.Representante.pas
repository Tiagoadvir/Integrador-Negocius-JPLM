unit DataModule.Representante;

interface

uses
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

  TDmRepresentante = class
  private
    qryRep: TFDQuery;
    Conexao : TDmGlobal;

  public
    constructor Create;
    destructor destroy; override;
    function Listar_representante : TJSONArray;
    function Listar_representante_x_cliente: TJSONArray;

  end;

implementation

{ TDmRepresentante }

constructor TDmRepresentante.Create;
begin
  Conexao := TDmGlobal.Create(nil);
  qryRep  := TFDQuery.Create(nil);
  qryRep.Connection := Conexao.Conn;
end;

destructor TDmRepresentante.destroy;
begin
   Conexao.Free;
   qryRep.Free;
  inherited;
end;

function TDmRepresentante.Listar_representante: TJSONArray;
begin
    qryRep.Active := false;
    qryRep.SQL.Clear;
    qryRep.SQL.Add('SELECT');
    qryRep.SQL.Add('R.ISN_REPRESENTANTE COD_REPRESENTANTE,');
    qryRep.SQL.Add('R.REPCN_REPRESENTANTE COD_REPRESENTANTE_LOCAL,');
    qryRep.SQL.Add('R.REPNM_REPRESENTANTE NOME_REPRESENTANTE,');
    qryRep.SQL.Add('R.REPNR_FONE1 FONE,');
    qryRep.SQL.Add('R.REPDS_EMAIL EMAIL,');
    qryRep.SQL.Add('R.REPFG_BLOQUEADO BLOQUEADO,');
    qryRep.SQL.Add('R.REPFG_EXP_PALM EXPORTA_PALM,');
    qryRep.SQL.Add('R.REPDS_LOGIN  LOGIN,');
    qryRep.SQL.Add('R.REPDS_SENHA  SENHA,');
    qryRep.SQL.Add('R.REPFG_IGNORA_MULTIPLO_PRODUTO IGNORA_MULTIPLO_PRODUTO,');
    qryRep.SQL.Add('R.ISN_EMPRESA COD_EMPRESA');
    qryRep.SQL.Add('FROM T_REPRESENTANTE  R');
    qryRep.Open;

    Result := qryRep.ToJSONArray;
end;

function TDmRepresentante.Listar_representante_x_cliente: TJSONArray;
begin
    qryRep.Active := false;
    qryRep.SQL.Clear;
    qryRep.SQL.Add('SELECT');
    qryRep.SQL.Add('RC.ISN_REPRESENTANTE_CLIENTE COD_REPRESENTANTE_CLIENTE,');
    qryRep.SQL.Add('RC.ISN_CLIENTE COD_CLIENTE,');
    qryRep.SQL.Add('RC.ISN_REPRESENTANTE COD_REPRESENTANTE,');
    qryRep.SQL.Add('RC.ISN_LINHA COD_LINHA_PRODUTO');
    qryRep.SQL.Add('FROM T_REPRESENTANTE_X_CLIENTE RC');
    qryRep.SQL.Add('JOIN T_REPRESENTANTE R on (R.ISN_REPRESENTANTE = RC.ISN_REPRESENTANTE)');
    qryRep.SQL.Add('WHERE R.REPFG_BLOQUEADO = ''N''  AND');
    qryRep.SQL.Add('R.REPFG_EXP_PALM = ''S''   AND');
    qryRep.SQL.Add('R.REPFG_IGNORA_MULTIPLO_PRODUTO = ''N'' AND');
    qryRep.SQL.Add('R.REPFG_RESTRICAO_DEMISSAO = ''N'';');
    qryRep.Open;

    Result := qryRep.ToJSONArray;
end;

end.
