unit uPedidoSync;

interface

uses
  FMX.Dialogs,
  RESTRequest4D,
  uConstante,

  Controllers.Auth,
  System.IOUtils,

  DateModule.Pedido,

  Horse.Request,
  Horse.Response,

  System.JSON,

  system.SysUtils;

type
TPedidoSync = class
  private
  public
  procedure ListarTipoPedido;
  function ListarPedidosWeb(dt_ult_sinc, ind_sincronizar: string; Pagina: Integer): TJSONArray;

end;

implementation
uses
  uPrincipal;

{ TPedidoSync }

procedure TPedidoSync.ListarTipoPedido;
var
 lResp : IResponse;
 lDmPedido : TDmPedido;
 cod_usuario, pagina : Integer;
 tipo : TJSONArray;
 obj : TJSONObject;
begin

  try
    lDmPedido := TDmPedido.Create(nil);

    obj   := TJSONObject.Create;
    tipo := TJSONArray.Create;
    tipo := DmPedido.ListarTipoPedido;

    obj.AddPair('tipo', tipo);


    lResp := TRequest.New.BaseURL(URL)
             .Resource('/v1/pedido/tipo')
             .TokenBearer(TGetToken.SolicitaToken)
             .AddBody('grant_type', 'client_credentials')
             .AddBody(obj)
             .Post;
  finally
     FreeAndNil(lDmPedido);
  end;
end;

//Lista o condição de pagamento
function TPedidoSync.ListarPedidosWeb(dt_ult_sinc, ind_sincronizar: string; Pagina: Integer): TJSONArray;
var
 resp : IResponse;   //precisa da unit restrequest4delphi
 pedido : TJSonArray;
 itens  : TJSONArray;
 pedidoAtual: TJSONObject;
 pedidoAtualString: string;
 I, J: Integer;
begin

          resp := TRequest.New.BaseURL(URL)
                   .Resource('/v1/pedido/importar')  //resource é a  rota a ser consumida.
                   .TokenBearer(TGetToken.SolicitaToken)
                   .AddParam('dt_ultima_sincronizacao', dt_ult_sinc)
                   .AddParam('pagina', pagina.ToString)
                   .AddParam('ind_sinc', ind_sincronizar)
                   .Accept('application/json') //Indica o formato de dados que será trabalhado
                   .Get;    //Envio o tipo de requisião

          if resp.StatusCode <> 200 then
             raise exception.Create(resp.Content)
          else

        pedido :=  TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(resp.Content), 0) as TJSONArray;

        // Verificar se o pedido foi analisado corretamente


        if Assigned(pedido) then
        begin
          // Iterar sobre cada objeto JSON dentro do array de pedidos
          for I := 0 to pedido.Size - 1 do
            begin
            pedidoAtual := pedido.Items[I] as TJSONObject;
            pedidoAtualString := pedidoAtual.ToString;
            DmPedido.InserirEditarPedido(
                              pedidoAtual.GetValue<Integer>('cod_usuario'),
                              pedidoAtual.GetValue<int64>('cod_pedido_local'),
                              pedidoAtual.GetValue<Integer>('cod_cliente'),
                              pedidoAtual.GetValue<Integer>('cod_prazo'),
                              pedidoAtual.GetValue<Integer>('cod_forma_pagto'),
                              0, // pedidoAtual.GetValue<Int64>('cod_pedido_oficial',0),
                              pedidoAtual.GetValue<string>('tipo_pedido'),
                              pedidoAtual.GetValue<string>('data_pedido'),
                              pedidoAtual.GetValue<string>('contato'),
                              pedidoAtual.GetValue<string>('observacao'),
                              pedidoAtual.GetValue<string>('prazo_entrega'),
                              pedidoAtual.GetValue<string>('data_entrega'),
                              pedidoAtual.GetValue<string>('data_ultima_alteracao'),
                              pedidoAtual.GetValue<Double>('valor_total'),
                              pedidoAtual.GetValue<TJSONArray>('item')
                              );
          end;
        end;
end;

end.
