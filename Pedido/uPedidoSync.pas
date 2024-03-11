unit uPedidoSync;

interface

uses
  FMX.Dialogs,
  RESTRequest4D,
  uConstante,
  LogUnit,

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
    procedure EnviaCodPedidoOficial(cod_ped_local, CodPedidoOficial : int64);
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

      lResp := TRequest.New.BaseURL(URL_AWS)
               .Resource('/v1/pedido/importar/tipo')
               .TokenBearer(TGetToken.SolicitaToken)
               .AddBody(obj)
               .Post;

     if lResp.StatusCode <> 200 then
     begin
       raise exception.Create(lResp.Content) ;
       Log('Erro ao enviar tipo de pedido : ' + lResp.Content, 'ErrTipoPedidoSync');
     end
     else
     begin
       Log('Tipo de pedido enviado com sucesso : ' + lResp.Content, 'TipoPedidoSync');
       ShowMessage('Rotina executada com sucesso');
     end;
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
 cod_pedido_oficial : Int64;
 I, J: Integer;
begin

      resp := TRequest.New.BaseURL(URL_PEDIDO)
              .TokenBearer(TGetToken.SolicitaToken)
              .Resource('/v1/pedido/exportar')  //resource é a  rota a ser consumida.
              .AddParam('dt_ultima_sincronizacao', dt_ult_sinc)
              .AddParam('pagina', pagina.ToString)
              .AddParam('ind_sinc', ind_sincronizar)
              .Accept('application/json') //Indica o formato de dados que será trabalhado
              .Get;    //Envio o tipo de requisião

        if resp.StatusCode <> 200 then
        begin
             raise exception.Create(resp.Content) ;
             Log('Erro ao enviar Cliente_x_forma_pagamento : ' + resp.Content, 'ErroImportacaoPedidoSync');
        end
        else
        begin
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
                                cod_pedido_oficial, // pedidoAtual.GetValue<Int64>('cod_pedido_oficial',0),
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

                EnviaCodPedidoOficial(pedidoAtual.GetValue<int64>('cod_pedido_local'), cod_pedido_oficial )
            end;
          end;
         Log(' Importado pedido : ' + pedido.ToString, 'ImportarcaoPedidoSync');
         ShowMessage('Rotina executada com sucesso');
        end;
end;

procedure TPedidoSync.EnviaCodPedidoOficial(cod_ped_local, CodPedidoOficial: Int64);
var
  lResp: IResponse;
  Obj: TJSONObject;
begin
  // Crie um objeto JSON para conter os dados a serem enviados
  Obj := TJSONObject.Create;
  Obj.AddPair('cod_pedido_oficial', CodPedidoOficial); // Adicione o código do pedido oficial ao objeto JSON
  Obj.AddPair('cod_pedido_local',  cod_ped_local);

  // Envie a solicitação PATCH com os parâmetros adequados
  lResp := TRequest.New.BaseURL(URL_PEDIDO)
            .Resource('/v1/pedido/retorno-codigo-oficial/inserir')
            .ContentType('application/json')
            .AddBody(Obj) // Adicione o objeto JSON como o corpo da solicitação
            .TokenBearer(TGetToken.SolicitaToken)
            .Post;
end;

end.
