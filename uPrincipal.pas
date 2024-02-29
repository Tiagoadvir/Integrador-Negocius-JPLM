unit uPrincipal;

interface

uses
  Horse,
  RESTRequest4D,
  uClienteSync,
  uPedidoSync,
  uPrazosSync,
  uProdutoSync,
  uRepresntanteSync,
  uConstante,

  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Dialogs,
  FMX.Edit,
  FMX.Forms,
  FMX.Graphics,
  FMX.Memo,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.StdCtrls,
  FMX.Types,

  Horse.CORS,
  Horse.Jhonson,
  Horse.OctetStream,
  Horse.Upload,

  System.Classes,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants;

type
  TFrmPrincipal = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Label2: TLabel;
    edt_cliente_ID: TEdit;
    Edit2: TEdit;
    Button9: TButton;
    Label3: TLabel;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Label4: TLabel;
    edt_secret_id: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
  private
    FForma : TprazosSync;
    FCliente : TClienteSync;
    FRrepresentante : TRepresentanteSync;
    FProduto : TProdutoSync;
    FPEdido : TPedidoSync;
 procedure InstanciaClassesSync;
    function SolicitaToken: String;

    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

uses
  Controllers.CondPagto;
{$R *.fmx}

procedure TFrmPrincipal.Button10Click(Sender: TObject);
begin
  FProduto.ListarEstoque;
end;

procedure TFrmPrincipal.Button11Click(Sender: TObject);
begin
 FPedido.ListarTipoPedido;
end;

procedure TFrmPrincipal.Button12Click(Sender: TObject);
begin
  ClienteID := edt_cliente_ID.Text;
  SecretID  := edt_secret_id.Text;
  FPEdido.ListarPedidosWeb('1800-01-01', 'S', 1);
end;

procedure TFrmPrincipal.Button1Click(Sender: TObject);
begin
   FForma.SincronicaFormaPagamento;
end;

procedure TFrmPrincipal.Button2Click(Sender: TObject);
begin
   FForma.ListarPrazo;
end;

procedure TFrmPrincipal.Button3Click(Sender: TObject);
begin
 FForma.Lista_Cliente_x_forma_pagamento;
end;

procedure TFrmPrincipal.Button4Click(Sender: TObject);
begin
    FCliente.ListarClientes;
end;

procedure TFrmPrincipal.Button5Click(Sender: TObject);
begin
  FRrepresentante.ListarRepresentantes;
end;

procedure TFrmPrincipal.Button6Click(Sender: TObject);
begin
  FRrepresentante.ListaRepresentante_X_cliente;
end;

procedure TFrmPrincipal.Button7Click(Sender: TObject);
begin
   FProduto.ListarProdutos;
end;

procedure TFrmPrincipal.Button8Click(Sender: TObject);
begin
 FForma.Lista_forma_pagamento_x_pedido;
end;

procedure TFrmPrincipal.Button9Click(Sender: TObject);
begin
   THorse.Listen(strtoint(Edit2.Text));
end;

procedure TFrmPrincipal.InstanciaClassesSync;
begin
     FForma := TprazosSync.Create;
     FCliente := TClienteSync.Create;
     FRrepresentante := TRepresentanteSync.Create;
     FProduto := TProdutoSync.Create;
     FPedido := TPedidoSync.create;
end;

function TFrmPrincipal.SolicitaToken : String;
var
 lResp : Iresponse;
begin
    lResp := TRequest.New.BaseURL('http://localhost:9000')
             .Resource('/token')
             .ContentType('application/json')
             .BasicAuthentication( edt_cliente_ID.text, edt_secret_id.text)
             .Post;

    if lResp.StatusCode <> 201 then
       raise Exception.Create(lresp.Content)
    else
    Result := lResp.JSONValue.GetValue<string>('access_token');
end;

procedure TFrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    FForma.Free;
    FCliente.Free;
    FRrepresentante.Free;
    FProduto.Free;
    FPedido.Free;
end;

//levanta o servidor
procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
      ClienteID := edt_cliente_ID.Text;
      SecretID  := edt_secret_id.Text;

      InstanciaClassesSync;

      {
      informo no momento que o forme é exibido os middwares(plugins) que o horse irá utilizar
      Chamando a classe Thorse, e passando para ela o midware desejado, que será utilizado
      }

     THorse.Use(Jhonson); // Informo ao horse para usar esse middware
     THorse.Use(CORS);   // Informo ao horse para usar esse middware
     THorse.Use(OctetStream);  // Informo ao horse para usar esse middware
     THorse.Use(Upload);  // Informo ao horse para usar esse middware

     //Registrar as rotas...

     //Chamo o unit que foi implementado o controle para registrar a rota

     Controllers.CondPagto.RegistrarRotas;


      {
       Para fazer uma requisição
      1° chamo a classe thorse,
      2° Indigo qual verbo irei utilizar (GET / POST /PUT / PATCH / DELETE)
      3° Informp o recurso a rota(recuro) a ser utilizada
      4° passo a assinatura da procedure
       procedure (Req : THorseRequest; Resp:THorseResponse; next: TProc);

      ficará assim:

       THorse.Get('/Rota_aser _usada',
       procedure (Req : THorseRequest; Resp:THorseResponse; next: TProc)
       begin
         res.send('/resposata_a_ser_enviada que será um Json neste caso);
       end);

       Basicamente, intercepta a conexão, identifica qual o verbo e a rota
       sempre que obedecer executa-se a procedura e o código que quiser...

       }

//     THorse.Post('/usuarios', procedure (Req : THorseRequest; Res : THorseResponse; next: TProc)
//     begin
//        Res.Send('{"Mensagem":"usuario cadastrado"}');
//     end); }


     {
      Agora para levantar a aplicação
      1° Chamo a classe THorse, que é o que implementa a aplicação
      2° Chamo o método listem, que é para informar que o servidor estará online
      3° Passo os parametros,
      a porta que usará
      a procedure
      como parametro da procedure, passo o Horse (HHorse:THorse)
      e dentro dessa procedure adiciono as implementações que desejo
      para quando o servidor entrar no ar,
      aqui informarei nomemo que o ervidor estará no ar, e informarei a porta


     }

  //   THorse.Listen(9001);
end;

end.
