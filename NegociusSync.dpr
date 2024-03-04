program NegociusSync;

uses
  System.StartUpCopy,
  FMX.Forms,
  uPrincipal in 'uPrincipal.pas' {FrmPrincipal},
  Controllers.CondPagto in 'controllers\Controllers.CondPagto.pas',
  Controllers.Produto in 'controllers\Controllers.Produto.pas',
  DateModule.Global in 'DataModule\DateModule.Global.pas' {DmGlobal: TDataModule},
  UFuncoes in 'Units\UFuncoes.pas',
  uMD5 in 'Units\uMD5.pas',
  UProdutoNegocius in 'Units\UProdutoNegocius.pas',
  DateModule.CondPagto in 'DataModule\DateModule.CondPagto.pas' {DmCondPagto: TDataModule},
  Controllers.Auth in 'controllers\Controllers.Auth.pas',
  uPrazosSync in 'Prazos\uPrazosSync.pas',
  Biblioteca in 'Units\Biblioteca.pas',
  DateModule.BloqueioPedido in 'DataModule\DateModule.BloqueioPedido.pas' {DmBloqueioPedido: TDataModule},
  DateModule.ChecaCliente in 'DataModule\DateModule.ChecaCliente.pas' {DmChecaCliente: TDataModule},
  DateModule.Cliente in 'DataModule\DateModule.Cliente.pas' {DmCliente: TDataModule},
  DateModule.Pedido in 'DataModule\DateModule.Pedido.pas' {DmPedido: TDataModule},
  DateModule.Produto in 'DataModule\DateModule.Produto.pas' {DmProduto: TDataModule},
  uClienteSync in 'Cliente\uClienteSync.pas',
  uConstante in 'Units\uConstante.pas',
  uRepresntanteSync in 'Representante\uRepresntanteSync.pas',
  DataModule.Representante in 'DataModule\DataModule.Representante.pas',
  uProdutoSync in 'Produtos\uProdutoSync.pas',
  uPedidoSync in 'Pedido\uPedidoSync.pas',
  LogUnit in 'Units\LogUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.CreateForm(TDmGlobal, DmGlobal);
  Application.CreateForm(TDmCondPagto, DmCondPagto);
  Application.CreateForm(TDmBloqueioPedido, DmBloqueioPedido);
  Application.CreateForm(TDmChecaCliente, DmChecaCliente);
  Application.CreateForm(TDmPedido, DmPedido);
  Application.CreateForm(TDmProduto, DmProduto);
  Application.Run;
end.
