unit uRepresntanteSync;

interface
  uses
    RESTRequest4D,
    uConstante,

    Controllers.Auth,
    System.IOUtils,

    DateModule.Global,
    DataModule.Representante,

    Horse.Request,
    Horse.Response,

    System.JSON,

    system.SysUtils;

type
TRepresentanteSync = class
  public
  procedure ListarRepresentantes;
  procedure ListaRepresentante_X_cliente;

end;

implementation
uses
 uPrincipal;

{ TRepresentanteSync }

procedure TRepresentanteSync.ListarRepresentantes;
var
 lRes : IResponse;
 json : TJSONObject;
 representantes : TJSONArray;
 DmRepresentante : TDmRepresentante;
begin

    DmRepresentante := TDmRepresentante.Create;
  try
    json := TJSONObject.Create;
    representantes := TJSONArray.Create;

    representantes :=  DmRepresentante.Listar_representante;
    json.AddPair('representantes', representantes);

    lRes := TRequest.New.BaseURL(URL)
            .Resource('/v1/representante')
            .ContentType('application/json')
            .AddBody(json)
            .Post;
  finally
     DmRepresentante.Free;
  end;
end;

procedure TRepresentanteSync.ListaRepresentante_X_cliente;
var
 lRes : IResponse;
 json : TJSONObject;
 representantes_x_cliente : TJSONArray;
 DmRepresentante : TDmRepresentante;
begin

    DmRepresentante := TDmRepresentante.Create;
  try
    json := TJSONObject.Create;
    representantes_x_cliente := TJSONArray.Create;

    representantes_x_cliente :=  DmRepresentante.Listar_representante_x_cliente;
    json.AddPair('representante_x_cliente', representantes_x_cliente);

    lRes := TRequest.New.BaseURL(URL)
            .Resource('/v1/representante/rep_x_cliente')
            .ContentType('application/json')
            .AddBody(json)
            .Post;
  finally
     DmRepresentante.Free;
  end;
end;

end.
