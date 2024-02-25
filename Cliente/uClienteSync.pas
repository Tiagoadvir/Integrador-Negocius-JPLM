unit uClienteSync;

interface

uses
    FMX.Dialogs,
    RESTRequest4D,
    uConstante,

    Controllers.Auth,
    System.IOUtils,

    DateModule.Cliente,
    DateModule.Global,

    Horse.Request,
    Horse.Response,

    System.JSON,

    system.SysUtils;
type

TClienteSync = class
  public

  procedure ListarClientes;

end;

implementation

uses
  UPrincipal;
{ TClienteSync }

procedure TClienteSync.ListarClientes;
var
 lResp : IResponse;
 lDmCliente : TDmCliente;
 cod_usuario, pagina : Integer;
 clientes : TJSONArray;
 obj : TJSONObject;
begin
  lDmCliente := TDmCliente.Create;

    obj   := TJSONObject.Create;
    clientes := TJSONArray.Create;
    clientes := lDmCliente.ListarClientes('01/01/1800 00:00:00', 0);

    obj.AddPair('clientes', clientes);

    lResp := TRequest.New.BaseURL(URL)
             .Resource('/v1/clientes/inserir')
             .ContentType('application/json')
             .AddBody(obj)
             .Post;

    ShowMessage(lresp.Content);
end;

end.
