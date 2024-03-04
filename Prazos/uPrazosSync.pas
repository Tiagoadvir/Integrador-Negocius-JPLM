unit uPrazosSync;

interface

uses
  LogUnit,
  RESTRequest4D,
  uConstante,

  Controllers.Auth,

  DateModule.CondPagto,
  DateModule.Global,

  FMX.Dialogs,

  Horse.Request,
  Horse.Response,

  System.IOUtils,
  System.JSON,

  system.SysUtils;

type

TprazosSync = class
  private
  public
  procedure SincronicaFormaPagamento;
  procedure ListarPrazo;
  procedure Lista_Cliente_x_forma_pagamento;
  procedure Lista_forma_pagamento_x_pedido;
end;

implementation

uses
  uPrincipal;
Const
  URL = 'http://localhost:9000';

{ ControlleFormasPrazosPGTO }

procedure TprazosSync.SincronicaFormaPagamento;
var
 lResp : IResponse;

 DmGlobal : TDmGlobal;
 DmCondicaoPagamento : TDmCondPagto;
 cod_usuario, pagina : Integer;
 Forma : TJSONArray;
 obj : TJSONObject;

begin
   try
    DmCondicaoPagamento := TDmCondPagto.Create(nil);

    obj   := TJSONObject.Create;
    Forma := TJSONArray.Create;
    Forma := DmCondicaoPagamento.ListarFormaPagto;

    obj.AddPair('forma', Forma);

    lResp := TRequest.New.BaseURL(URL)
             .Resource('/v1/formapagto')
             .AddBody(obj)
             .Post;
   finally
     FreeAndNil(DmCondicaoPagamento);
   end;

end;

procedure TprazosSync.ListarPrazo;
var
 lResp : IResponse;
 DmPrazo : TDmCondPagto;
 cod_usuario, pagina : Integer;
 Prazo : TJSONArray;
 obj : TJSONObject;
 loop : boolean;
begin
    pagina := 0;
    loop := true;

  try
    while loop do
    begin
       inc(pagina);
     try
      DmPrazo := TDmCondPagto.Create(nil);

      obj   := TJSONObject.Create;
      Prazo := TJSONArray.Create;
      Prazo := DmPrazo.ListarPrazo(pagina);

      if Prazo.Size = 0 then
      begin
         log( 'Produtos syncronizados com sucesso ' + lResp.Content, 'ProdutoSync');
         loop := False;
         if assigned(Prazo) then
          Prazo.Free;
        exit;
      end;

      obj.AddPair('prazo', Prazo);

      lResp := TRequest.New.BaseURL(URL_PRAZO)
               .Resource('/v1/prazo/inserir')
               .TokenBearer(TGetToken.SolicitaToken)
               .AddBody(obj)
               .Post;

      if lResp.StatusCode <> 200 then
      begin
       Log('Erro ao enviar produtos' + lresp.Content, 'ErroPrazoSync');
       loop := False;
       end;

    except on ex:exception do
             begin
              ShowMessage(lResp.Content);
              Log('Erro ao enviar Prazos' + lresp.Content, 'ErroPrazoSync');
              loop := False;
              end
     end;
    end;
  finally
     FreeAndNil(DmPrazo);
   end;

end;

procedure TprazosSync.Lista_Cliente_x_forma_pagamento;
var
 lResp : IResponse;
 DmPrazo : TDmCondPagto;
 cod_usuario, pagina : Integer;
 cliente_x_forma_pagto : TJSONArray;
 obj : TJSONObject;
begin

  try
    DmPrazo := TDmCondPagto.Create(nil);

    obj   := TJSONObject.Create;
    cliente_x_forma_pagto := TJSONArray.Create;
    cliente_x_forma_pagto := DmPrazo.ListarClienteFormaPagto('01/01/1900', 1);

    obj.AddPair('cliente_forma_pagto', cliente_x_forma_pagto);


    lResp := TRequest.New.BaseURL(URL)
             .Resource('/v1/cliente_x_forma')
             .AddBody(obj)
             .Post;
  finally
     FreeAndNil(DmPrazo);
   end;
end;

procedure TprazosSync.Lista_forma_pagamento_x_pedido;
var
 lResp : IResponse;
 DmPrazo : TDmCondPagto;
 cod_usuario, pagina : Integer;
 forma_pagto_x_pedido : TJSONArray;
 obj : TJSONObject;
begin

  try
    DmPrazo := TDmCondPagto.Create(nil);

    obj   := TJSONObject.Create;
    forma_pagto_x_pedido := TJSONArray.Create;
    forma_pagto_x_pedido := DmPrazo.Listar_prazo_x_pedido('01/01/1900');

    obj.AddPair('prazo_x_pedido', forma_pagto_x_pedido);

    lResp := TRequest.New.BaseURL(URL)
             .Resource('/v1/prazo/prazo_x_pedido')
             .AddBody(obj)
             .Post;
  finally
     FreeAndNil(DmPrazo);
   end;
end;

end.
