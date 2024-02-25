unit uProdutoSync;

interface

uses
  RESTRequest4D,

  Controllers.Auth,
  UConstante,

  DateModule.Produto,

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
begin

    DmProduto := TDmProduto.Create;
    try
       try
            json   := TJSONObject.Create;
            Produtos := TJSONArray.Create;
            Produtos := DmProduto.ListarProdutos('01/01/1800 00:00:00', 1);

            json.AddPair('produto', Produtos);

         lResp := TRequest.New.BaseURL(URL)
                   .Resource('/v1/produto')
                   .ContentType('application/json')
                   .AddBody(json)
                   .Post;
       except

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

         lResp := TRequest.New.BaseURL(URL)
                   .Resource('/v1/produto/estoque')
                   .ContentType('application/json')
                   .AddBody(json)
                   .Post;
       except

       end;
    finally
      DmProduto.Free;
    end;
end;

end.
