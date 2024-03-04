unit uProdutoSync;

interface

uses
  RESTRequest4D,
  UConstante,
  LogUnit,

  Controllers.Auth,

  DateModule.Produto,

  FMX.Dialogs,

  Horse.Request,
  Horse.Response,

  System.IOUtils,
  System.JSON,

  system.SysUtils;

type

TProdutoSync = class
  private
  public
    procedure ListarProdutos;
    procedure ListarEstoque;

end;

implementation
uses
 uprincipal;

{ TProdutoSync }

procedure TProdutoSync.ListarProdutos;
var
 lResp : IResponse;
 DmProduto : TDmProduto;
 Produtos : TJSONArray;
 json : TJSONObject;
 loop : boolean;
 pagina : integer;
begin
    pagina := 0;
    loop := true;

    DmProduto := TDmProduto.Create;

    try
      while loop do
      begin
        inc(pagina);
         try
            json   := TJSONObject.Create;
            Produtos := TJSONArray.Create;
            Produtos := DmProduto.ListarProdutos('01/01/1800 00:00:00', pagina);

            if produtos.Size = 0 then
            begin
              log( 'Produtos syncronizados com sucesso ' + lResp.Content, 'ProdutoSync');
              loop := False;
               if assigned(Produtos) then
                  Produtos.Free;
              exit;
            end;

            json.AddPair('produto', Produtos);

            lResp := TRequest.New.BaseURL(URL_AWS)
                     .Resource('/v1/produto/inserir')
                     .TokenBearer(TGetToken.SolicitaToken)
                     .ContentType('application/json')
                     .AddBody(json)
                     .Post;

           if lResp.StatusCode <> 200 then
           begin
            Log('Erro ao enviar produtos' + lresp.Content, 'ErroProdutoSync');
            loop := False;
           end;

         except on ex:exception do
           begin
            ShowMessage(lResp.Content);
            Log('Erro ao enviar produtos' + lresp.Content, 'ErroProdutoSync');
            loop := False;
            end
         end;
      end;
    finally
      DmProduto.Free;
    end;
end;

procedure TProdutoSync.ListarEstoque;
var
 lResp : IResponse;
 DmProduto : TDmProduto;
 Estoque : TJSONArray;
 json : TJSONObject;

begin

    DmProduto := TDmProduto.Create;
    try
       try
            json   := TJSONObject.Create;
            Estoque := TJSONArray.Create;
            Estoque := DmProduto.Listar_Estoque_Produtos(1);

            json.AddPair('estoque', Estoque);

         lResp := TRequest.New.BaseURL(URL_AWS)
                   .Resource('/v1/produto/estoque')
                   .TokenBearer(TGetToken.SolicitaToken)
                   .ContentType('application/json')
                   .AddBody(json)
                   .Post;

        if lResp.StatusCode = 200 then
           Log('Estoque Enviado com sucesso ' + lresp.Content, 'EstoqueSync')
        else
          Log('Erro ao gravar estoque ' + lresp.Content, 'ErroEstoqueSync')      
                   
       except on ex:exception do
         begin
            Log('Erro ao enviar produtos' + lresp.Content, 'ErroProdutoSync');
         end;
       end;
    finally
      DmProduto.Free;
    end;
end;

end.
