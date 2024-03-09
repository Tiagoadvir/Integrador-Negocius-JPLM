unit uClienteSync;

interface

uses
    FMX.Dialogs,
    RESTRequest4D,
    uConstante,
    LogUnit,

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
 loop : Boolean;
 i : Integer;
begin


    lDmCliente := TDmCliente.Create;

      pagina := 0;
      loop := True;
     while loop do
     begin
        try
             Inc(pagina);

              obj   := TJSONObject.Create;
              clientes := TJSONArray.Create;
              clientes := lDmCliente.ListarClientes(DateTimeToStr(FrmPrincipal.DateUltiSync.DateTime + Time), pagina);

              if clientes.Count = 0 then
              begin
                Log( 'Clientes syncronizados com sucesso ', 'LogClienteSync');
                loop := False;
                 if assigned(obj) then
                    obj.Free;
              exit;
              end;

              obj.AddPair('clientes', clientes);

              lResp := TRequest.New.BaseURL(URL_CLIENTE)
                       .Resource('/v1/cliente/inserir')
                       .TokenBearer(TGetToken.SolicitaToken)
                       .ContentType('application/json')
                       .AddBody(obj)
                       .Post;

          if lresp.StatusCode <> 200 then
          begin
             ShowMessage(lresp.Content);
             Log('Erro ao gravar clientes' + lresp.Content, 'LogClietneSync' );
             loop := false;
          end;

       except on ex:exception do
         begin
          log( ' Erro ao sincronizar Clientes ' + lResp.Content, 'LogClietneSync');
          loop := False;
          exit;
         end;
         end;
     end;
          ShowMessage('Rotina executada com sucesso');
end;

end.
