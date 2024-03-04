unit uRepresntanteSync;

interface

uses
    FMX.Dialogs,
    RESTRequest4D,
    uConstante,
    LogUnit,

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
 loop : boolean;
 pagina : integer;
begin
  loop:= True;
  pagina := 0;

  DmRepresentante := TDmRepresentante.create;
  try
    while loop do
    begin
      Inc(pagina);

      try
       json := TJSONObject.Create;
       representantes := TJSONArray.Create;

       representantes :=  DmRepresentante.Listar_representante(pagina);
       json.AddPair('representantes', representantes);

       if representantes.Size = 0 then
       begin
          log( 'Representantes syncronizados com sucesso ' + lRes.Content, 'RepresentantesSync');
          loop := False;
         if assigned(json) then
            json.Free;
            exit;
       end;

       lRes := TRequest.New.BaseURL(URL_AWS)
              .Resource('/v1/representante/inserir')
              .TokenBearer(TGetToken.SolicitaToken)
              .ContentType('application/json')
              .AddBody(json)
              .Post;

         if lRes.StatusCode <> 200 then
         begin
          Log('Erro ao enviar Representantes' + lres.Content, 'RepresententesSync');
          loop := False;
         end;

      except on ex:exception do
         begin
           ShowMessage(lRes.Content);
           Log('Erro ao enviar Representantes' + lres.Content, 'ErroRepresententesSync');
           loop := False;
         end
      end;
     end;

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
 loop : boolean;
 pagina : integer;
begin
  loop:= True;
  pagina := 0;

    DmRepresentante := TDmRepresentante.Create;
  try

   while loop do
   begin
      Inc(pagina);

      try
        json := TJSONObject.Create;
        representantes_x_cliente := TJSONArray.Create;

        representantes_x_cliente :=  DmRepresentante.Listar_representante_x_cliente(pagina);
        json.AddPair('representante_x_cliente', representantes_x_cliente);

       if representantes_x_cliente.Size = 0 then
       begin
          log('RepresentanteX_Cliente syncronizados com sucesso ' + lRes.Content, 'LogRepresentante_X_clienteSync');
          loop := False;
         if assigned(json) then
            json.Free;
            exit;
       end;

        lRes := TRequest.New.BaseURL(URL_AWS)
                .Resource('/v1/representante/rep_x_cliente')
                .TokenBearer(TGetToken.SolicitaToken)
                .ContentType('application/json')
                .AddBody(json)
                .Post;

        if lRes.StatusCode <> 200 then
         begin
          Log('Erro ao enviar Representantes' + lres.Content, 'ErroRepresentente_X_ClienteSync');
          loop := False;
         end;

      except on ex:exception do
         begin
           ShowMessage(lRes.Content);
           Log('Erro ao enviar Representantes_X_Cliente' + lres.Content, 'ErroRepresentente_X_ClienteSync');
           loop := False;
         end
      end;
   end;
  finally
     DmRepresentante.Free;
  end;
end;

end.
