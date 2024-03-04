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
 loop : boolean;
begin
    pagina := 0;
    loop := true;

    DmCondicaoPagamento := TDmCondPagto.Create(nil);

   try
      while loop do
      begin
         inc(pagina);
         try

            obj   := TJSONObject.Create;
            Forma := TJSONArray.Create;
            Forma := DmCondicaoPagamento.ListarFormaPagto(pagina);

            if Forma.Size = 0 then
            begin
               log( 'Formas de pagamento syncronizados com sucesso ' + lResp.Content, 'ProdutoSync');
               loop := False;
               if assigned(Forma) then
                Forma.Free;
              exit;
            end;

            obj.AddPair('forma', Forma);

            lResp := TRequest.New.BaseURL(URL_AWS)
                     .Resource('/v1/formapagto/inserir')
                     .TokenBearer(TGetToken.SolicitaToken)
                     .AddBody(obj)
                     .Post;

            if lResp.StatusCode <> 200 then
            begin
             Log('Erro ao enviar prazos' + lresp.Content, 'PrazoSync');
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
         log( 'Prazos syncronizados com sucesso ' + lResp.Content, 'ProdutoSync');
         loop := False;
         if assigned(Prazo) then
          Prazo.Free;
        exit;
      end;

      obj.AddPair('prazo', Prazo);

      lResp := TRequest.New.BaseURL(URL_AWS)
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
 loop : boolean;
begin
    pagina := 0;
    loop := true;

   DmPrazo := TDmCondPagto.Create(nil);
  try
    while loop do
    begin
       inc(pagina);
      try
        obj   := TJSONObject.Create;
        cliente_x_forma_pagto := TJSONArray.Create;
        cliente_x_forma_pagto := DmPrazo.ListarClienteFormaPagto('01/01/1900', pagina);

        obj.AddPair('cliente_forma_pagto', cliente_x_forma_pagto);

       if cliente_x_forma_pagto.Size = 0 then
        begin
           log( 'Cliente_x_forma_pagamento syncronizados com sucesso ' + lResp.Content, 'formaPagtoPorPedidoSync');
           loop := False;
           if assigned(cliente_x_forma_pagto) then
            cliente_x_forma_pagto.Free;
          exit;
        end;


        lResp := TRequest.New.BaseURL(URL_AWS)
               .Resource('/v1/cliente_x_forma/inserir')
               .TokenBearer(TGetToken.SolicitaToken)
               .AddBody(obj)
               .Post;

        if lResp.StatusCode <> 200 then
        begin
         Log('Erro ao enviar Cliente_x_forma_pagamento ' + lresp.Content, 'ErroformaPagtoPorPedidoSync');
         loop := False;
         end;

      except on ex:exception do
             begin
                ShowMessage(lResp.Content);
                Log('Erro ao enviar Cliente_x_forma_pagamento ' + lresp.Content, 'ErroformaPagtoPorPedidoSync');
                loop := False;
             end
       end;
    end;
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
 loop : boolean;
begin
    pagina := 0;
    loop := true;

   DmPrazo := TDmCondPagto.Create(nil);
  try
    while loop do
    begin
       inc(pagina);
      try
        obj   := TJSONObject.Create;
        forma_pagto_x_pedido := TJSONArray.Create;
        forma_pagto_x_pedido := DmPrazo.Listar_prazo_x_pedido('01/01/1900', pagina);

        if forma_pagto_x_pedido.Size = 0 then
        begin
           log( 'forma_pagamento_x_pedidos syncronizados com sucesso ' + lResp.Content, 'formaPagtoPorPedidoSync');
           loop := False;
           if assigned(forma_pagto_x_pedido) then
            forma_pagto_x_pedido.Free;
          exit;
        end;

        obj.AddPair('prazo_x_pedido', forma_pagto_x_pedido);

        lResp := TRequest.New.BaseURL(URL_AWS)
                 .Resource('/v1/prazo/prazo_x_pedido/inserir')
                 .TokenBearer(TGetToken.SolicitaToken)
                 .AddBody(obj)
                 .Post;

        if lResp.StatusCode <> 200 then
        begin
         Log('Erro ao enviar forma_pagamento_x_pedidos' + lresp.Content, 'ErroformaPagtoPorPedidoSync');
         loop := False;
         end;

      except on ex:exception do
               begin
                ShowMessage(lResp.Content);
                Log('Erro ao enviar forma_pagamento_x_pedido' + lresp.Content, 'ErroformaPagtoPorPedidoSync');
                loop := False;
                end
       end;
    end;
  finally
     FreeAndNil(DmPrazo);
   end;
end;

end.
