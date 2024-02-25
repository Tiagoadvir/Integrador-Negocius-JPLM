unit Controllers.Produto;

interface

Uses
    Horse,
    horse.Jhonson,
    Horse.CORS,
    Horse.OctetStream,
    Horse.Upload, // para trabalhar com upload de fotos
    DateModule.Global,
    DateModule.Produto,
    System.SysUtils,
    System.JSON,
    Controllers.Auth,
    System.Classes,
    Horse.JWT,
    FMX.Graphics; // Necess�rio para  Trabalhar com   Imagens.

    procedure RegistrarRotas;
    procedure ListarProdutos (Req : THorseRequest; Res : THorseResponse; Next : TProc);
    Procedure ListarEstoque (Req : THorseRequest; Res : THorseResponse; Next : TProc);
    procedure InserirEditarProduto ( Req : THorseRequest; Res : THorseResponse; Next : TProc);
    procedure ListarFoto ( Req : THorseRequest; Res : THorseResponse; Next : TProc);
    procedure EditarFoto (Req : THorseRequest; Res : THorseResponse; Next : TProc);

implementation

 {
  A assinatura das procedures horse, deve ter a assinatura exatramente igual a esta:
  procedure( Req : THorseRequest; Res : THorseResponse; Next : TProc
 }
procedure RegistrarRotas;
begin
  {
  � aqui que defino se a rota � protejida ou n�o, se precisa de autentica��o ou n�o
  neste momento realizo a implementa��o para que se a rota for protejida, nem execute a proxima rotina
  j� devolva o erro para o usu�rio

  Middware � o "pugin" que fica entre a requisi��o, e a rotina interna, ele intercepta a requisi��o
  e realiza algumas tarefas, neste caso da autentica��o ser� utilizado o middware
  vai refificar a requisi��o o token jwt  que est� chegando � valido ou nao , se estiver tudo certo deixar�
  a requisi��o seguir o cruso normal, caso n�o j� devolve um erro para o usu�rio.

  1�  chamo a classe Thorse
  2� Na classe Thorse, chamo o m�todo Addcallback()
      Thorse.AddCallback()

  3� Passo como parametro do addcallback o HorseJWT()  (adicionar o Horse.JWT nas uses), que utilizar� o middware
      Thorse.AddCallback(Horse.JWT())



  4� O Horse.JWT espera como parametro middware onde se encontra
     o secret que est� implementado dentro do Controller.Auth ,
     e o SECRET.

       HorseJWT(Controller.Auth.Secret)...

       ficando asintaxe assim

       Thorse.Callback(THorse.JWT(unit onde se encontra o SECRET)).


   5�   O SECRET � o segundo parametro esperado pelo Horse.JWT, respons�vel por abrir validar o token saber,
        se est� valido ou n�o. Esse secrety est� na classe TMyclaims, e para acessar utilizar essa classe nesse
        parametro

         * Acesso as  configura��es do Horse.JWT,  ThorseJWTConfig
         * inicio uma nova CONFIGURACAO com o .new ficando  -> ThorseJWConfig.new
         * chamo a sessionclass, para instanciar uma nova classe ficando assim - > THorseJWTConfig.New.Sessionclass
         * e a SESSIONCLASS espera como parametro a classe onde se encontra o secret a TMyclaims


         THorseJWTConfig.new.SessionClass(TmayClams)

  Thorse.Callbak(ThorseJWT(unit onde esta localizado o secret, THorseJWTConfig.new.sessionclass(classe que implementa onde decodifica o token, e valida as informa��es))))

   A sintaxe ficar� assim:
     THorse.AddCallback(Horse.JWT(Controllers.Auth.SECRET, ThorseJWTConfig.new.SessionClass(TMyclaims)))

  5� Ap�s o callback � que � passado o verbo e a rota a ser consumida
     .Post ('/usuarios/login', login );

     A sintaxe final ficar� assim:

     THorse.AddCallback(HorseJWT(Controllers.Auth.SECRET, ThorseJWTconfig.New.SessionClass(TMyClaims)))
                        .Post('/usuarios/push', push);
  }


  THorse.AddCallback(HorseJWT(Controllers.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Get('/produtos/sincronizacao', ListarProdutos);  // GET, o parametro vem na URL

  THorse.AddCallback(HorseJWT(Controllers.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Post('/produtos/sincronizacao', InserirEditarProduto);

  THorse.AddCallback(HorseJWT(Controllers.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Get('produtos/foto/:cod_produto', ListarFoto);

  THorse.AddCallback(HorseJWT(Controllers.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Put('/produtos/foto/:cod_produto', EditarFoto);

  THorse.AddCallback(HorseJWT(Controllers.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Get('/produtos/sincronizacao/listarestoque', ListarEstoque);

    //As procedures, podem ser gigantes, entao pra isso fragmentei em procedures e coloquei o apelido delas no local
    // da procedue, para que quando ela for ser exaturada, v� at� o procedimento criado

end;


procedure ListarProdutos (Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
 DmGlobal : TDmGLobal;
 dt_ultima_sincronizacao: string;
 pagina : Integer;
       {
       o Verbo GET, n�o vem no corpo da requisi��o, ele vem na pr�pria URL,
       precedido de uma interroga��o
        http://servidor : porta / rota ? nome do parametro = valor parametro & outro parametro = valor & parametro = valor
      ex:
       Http://localhost:9000/produtos/sincronizacao?= 2022-11-02  08:00:00
       }
begin
   try
        try
            //Levanto o m�duo de dados(crio ele)
            DmGlobal := TDmGLobal.Create(nil);

            //recebe a data da ultima sincroniza��o do lado mobile
            try
             dt_ultima_sincronizacao := Req.Query['dt_ultima_sincronizacao']; //yyyy-mm-dd  hh:nn:ss
            except
             dt_ultima_sincronizacao := '';
            end;

            //recebe a p�gina do lado mobile
            try
             pagina := Req.Query['pagina'].ToInteger;
            except
             pagina := 1;
            end;
            {
            Vai no DmGlobal, passa o parametro recebido, faz a query com o retorno
            Monta uma lista, um  jsonArray com o retorno da query, utilizando o TJsonArray
            e devolve para o usu�rio
            }


           //  Res.Send<TJSONArray>(DmGlobal.ListarProdutos(dt_ultima_sincronizacao, pagina)).Status(200); // se o login foi encontrado devolvo o objeto JSON

            //Tras do banco do negocius
            Res.Send<TJSONArray>(DmProduto.ListarProdutos(dt_ultima_sincronizacao, pagina)).Status(200); // se o login foi encontrado devolvo o objeto JSON

        except on ex:exception do
            Res.Send(ex.Message).Status(500); //devolve o status 500 caso de erro no servidor
        end;
   finally
        //Destruo e tiro da memoria o dmglobal
            FreeAndNil(DmGlobal);
   end;
end;

procedure ListarEstoque(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
 DmGlobal : TDmGLobal;
 isn_produto, pagina : Integer;
       {
       o Verbo GET, n�o vem no corpo da requisi��o, ele vem na pr�pria URL,
       precedido de uma interroga��o
        http://servidor : porta / rota ? nome do parametro = valor parametro & outro parametro = valor & parametro = valor
      ex:
       Http://localhost:9000/produtos/sincronizacao?dt_tultima_sincronizacao= 2022-11-02  08:00:00
       }
begin
   try
        try
            //Levanto o m�duo de dados(crio ele)
            DmGlobal := TDmGLobal.Create(nil);

            //recebe a p�gina do lado mobile
            try
             pagina := Req.Query['pagina'].ToInteger;
            except
             pagina := 1;
            end;

      //      isn_produto  := req.Query['cod_produto_oficial'].ToInteger;

            {
            Vai no DmGlobal, passa o parametro recebido, faz a query com o retorno
            Monta uma lista, um  jsonArray com o retorno da query, utilizando o TJsonArray
            e devolve para o usu�rio
            }


           //  Res.Send<TJSONArray>(DmGlobal.ListarProdutos(dt_ultima_sincronizacao, pagina)).Status(200); // se o login foi encontrado devolvo o objeto JSON

            //Tras do banco do negocius
            Res.Send<TJSONArray>(DmProduto.Listar_Estoque_Produtos(pagina)).Status(200); // se o login foi encontrado devolvo o objeto JSON

        except on ex:exception do
            Res.Send(ex.Message).Status(500); //devolve o status 500 caso de erro no servidor
        end;
   finally
        //Destruo e tiro da memoria o dmglobal
            FreeAndNil(DmGlobal);
   end;
end;


procedure InserirEditarProduto(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
 DmGlobal : TDmGLobal;
 nome, email, senha : String;
 cod_usuario :Integer;
 body, json_ret : TJsonObject;
begin
   try
    try
            //Levanto o m�duo de dados(crio ele)
             DmGlobal := TDmGLobal.Create(nil);

            {
            Recupera o c�digo do usu�rio dentro do token jwt, enviando
            para afun��o que cria e decripta o token ,
            1� Chamo a fun��o que est� o controller.Auth
               get_usuario_request();
            2� Passo o parametro que � o request,
            }
            cod_usuario := Get_Usuario_Request(Req);

            //Acesso o corpo da requsi��o que contem o usuario e senha
            body := Req.Body<TJSONObject>;

            {
             esse Json, � um json recebido, montado l� do lado mobile
            }
           json_ret := DmGlobal.InserirEditarProduto( cod_usuario,
                                               body.GetValue<Integer>('cod_produto_local', 0),
                                               body.GetValue<integer>('cod_produto_oficial', 0),
                                               body.GetValue<Double>('valor', 0),
                                               body.GetValue<Double>('qtd_estoque', 0),
                                               body.GetValue<string>('descricao', ''),
                                               body.GetValue<string>('dt_ult_sincronizacao', ''));

           //Adiciono manualmente no retorno do json, um par contendo o c�digo do produto local
           json_ret.AddPair('cod_produto_local', TJSONNumber.Create(body.GetValue<Integer>('cod_produto_local', 0)));

           cod_usuario := json_ret.GetValue<Integer>('cod_usuario', 0);   {"cod_produto_local":250, "cod_produto_oficial": 2560}

           //Gerar o token contendo o cod_usu�rio
           //Adiciono um par extra antes de devolver o json que �  TOKEN JWT
           // json_ret.AddPair('token', Criar_Token(cod_usuario));
           //-------------------------------------------------------------

          Res.Send<TJSONObject>(json_ret).Status(201); // se o login foi encontrado devolvo o objeto JSON

    except on ex:exception do
           Res.Send(ex.Message).Status(500); //devolve o status 500 caso de erro no servidor
    end;
   finally
     FreeAndNil(DmGlobal);
   end;

end;


procedure ListarFoto (Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
 DmGlobal : TDmGLobal;
 cod_produto : Integer;
       {
       o Verbo GET, n�o vem no corpo da requisi��o, ele vem na pr�pria URL,
       precedido de uma interroga��o
        http://servidor : porta / rota ? nome do parametro = valor parametro & outro parametro = valor & parametro = valor
      ex:
       Http://localhost:9000/produtos/foto/1234
       }
begin
    {

            para trabalhar com foto importe na uses a system.classes,
            Para trabalhar com STREAM, importe para a UNIT ATUAL E unitprincipal o middware responsavel
            que � o HORSE.OCTETSTREAM, importa para o Horse, informar o uso do middware no evento onformshow DO FORMPRINCIPAL
            EXEMPLO

            Uses
            Hose.octetStream,

            implementation

            Tfromprincipal.Show(sender : Tobject)
            begin
            THorse.Use(OctetStream);
            end;
    }


   try
        try
            //Levanto o m�duo de dados(crio ele)
            DmGlobal := TDmGLobal.Create(nil);

            //recebe a data da ultima sincroniza��o do lado mobile
            try
               {
                Para pegar direto o parametro que chama de URI params da requisi��o, sem o uso do & comercial
                ex:
                    produto/foto/nome_parametro = valor_parametro & parametro  <-- chamado de query params
                    produto/foto/valor_parametro  <---- chamado de uri parametro

                1 � Req
                2� .params
                3� .items[]
                e coloco o parametro uri dentro dos conchetes
                ex:
                 req.params.items["parametro"]

               }
             cod_produto := Req.Params.Items['cod_produto'].ToInteger;
            except
             cod_produto := 0;
            end;

            {
            Vai no DmGlobal, passa o parametro recebido, faz a query com o retorno
            Monta uma lista, um  jsonArray com o retorno da query, utilizando o TStream
            j� que � uma midia foto, e devolve para o usu�rio.

            }

            Res.Send<TStream>(DmGlobal.ListarFoto(cod_produto)).Status(200); // se a imagem  foiencontrado devolvo o objeto JSON

        except on ex:exception do
            Res.Send(ex.Message).Status(500); //devolve o status 500 caso de erro no servidor
        end;
   finally
        //Destruo e tiro da memoria o dmglobal
            FreeAndNil(DmGlobal);
   end;
end;


procedure EditarFoto(Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
 cod_produto : Integer;
 Foto : TBitmap;
 LUploadConfig: TUploadConfig;
 DmGlobal : TDmGLobal;

begin
       {
       procuro dentro da requisi��o o c�digo do produto
       }
       try
          cod_produto := Req.Params.Items['cod_produto'].ToInteger;
       except
          Cod_produto := 0;
       end;

      {
       Inicializa a classe Upload, que espera como parametro o local onde
       a imagem ser� salva temporariamente at� ser salva no banco de dados

       Com extraio o local onde a aplica��o est� sendo executada com o comando
       ExtractfilePath(ParamStr(0))
       e concateco com a pasta que deve est�r no mesmo local do execut�vel,

       ExtractFilePath(ParamStr(0)) + Pasta )

      }
      LUploadConfig := TUploadConfig.Create(ExtractFilePath(ParamStr(0)) + 'Fotos');
      {
       O ForceDir, caso a pasta n�o exista no diret�rio, ele o criar�
      }
      LUploadConfig.ForceDir := True;
      {
      O OverrideFiles, sobrescrever� arquivos com o mesmo nome
      }
      LUploadConfig.OverrideFiles := True;

      {
      quando se trada de arquivos de imagem, primeiro envio
      a resposta com o status do recebimento da imagem
      e ap�s � que entro no calback para executar as rotinas necess�rias.
      }
      Res.Send<TUploadConfig>(LUploadConfig);

      {
       Esse treho abaixo � executado assim que o arquivo � recebido
       E acessa as propriedades do arquivo
      }
      //Optional: Callback for each file received
        LUploadConfig.UploadFileCallBack :=
        procedure(Sender: TObject; AFile: TUploadFileInfo)
        begin
          try
            DmGlobal :=  TDmGlobal.Create(nil);

            //Cria um btimap com base em um arquivo
            {
             para isso, utiliza-se aclasse TBitmap
             intancia ela
             acessa a fun��o createfromfile
             que espera comoparametro, o aquivo
             aqui, com o upload, a imagem recebida est�ra no parametro AFIle
             que tem a fun��o fullpath,
             que j� carrega o local onde est� o arquivo e o nome do arquivo
            }
            Foto := TBitmap.CreateFromFile(AFile.fullpath);

            DmGlobal.EditarFoto(Cod_produto, Foto);

            FreeAndNil(Foto);
          finally
             FreeAndNil(DmGlobal);
          end;
        end;

      //Optional: Callback on end of all files
    {  LUploadConfig.UploadsFishCallBack :=
        procedure(Sender: TObject; AFiles: TUploadFiles)
        begin
          Writeln('');
          Writeln('Finish ' + AFiles.Count.ToString + ' files.');
        end; }


end;


end.
