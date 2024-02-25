unit Controllers.CondPagto;

interface

uses
  Horse,
//  UFuncoes,
///
//  uPedido,

  Controllers.Auth,

  DateModule.CondPagto,
  DateModule.Global,

  Horse.JWT,

  System.Classes,
  System.JSON,
  System.SysUtils;

    Procedure RegistrarRotas;
    procedure ListarPrazo (Req : THorseRequest; Res : THorseResponse; Next : TProc);
    procedure ListarformaPagto (Req : THorseRequest; Res : THorseResponse; Next : TProc);
    procedure ListarClienteformaPagto (Req : THorseRequest; Res : THorseResponse; Next : TProc);

implementation


 {
  A assinatura das procedures horse, deve ter a assinatura exatramente igual a esta:
  procedure( Req : THorseRequest; Res : THorseResponse; Next : TProc
 }

 Procedure RegistrarRotas;
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
        .Get('cond-pagto/sincronizacao/prazo', ListarPrazo);

  THorse.AddCallback(HorseJWT(Controllers.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Get('cond-pagto/sincronizacao/forma-pagto', ListarFormapagto);

  THorse.AddCallback(HorseJWT(Controllers.Auth.SECRET, THorseJWTConfig.New.SessionClass(TMyClaims)))
        .Get('cond-pagto/sincronizacao/cli-x-forma', ListarClienteFormaPagto);

 end;

 procedure ListarPrazo (Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
 DmGlobal : TDmGLobal;
 DmCondicaoPagamento : TDmCondPagto;
 cod_usuario, pagina : Integer;
       {
       o Verbo GET, n�o vem no corpo da requisi��o, ele vem na pr�pria URL,
       precedido de uma interroga��o
        http://servidor : porta / rota ? nome do parametro = valor parametro & outro parametro = valor & parametro = valor
      ex:
       Http://localhost:9000/pedidos/sincronizacao?= 2022-11-02  08:00:00
       }
begin
   try
        try
            //Levanto o m�duo de dados(crio ele)
            DmGlobal := TDmGLobal.Create(nil);
            DmCondicaoPagamento := TDmCondPagto.Create(nil);
            //exrai o c�digo do usuario   do token pela classe Controllers.Auth
            cod_usuario := Get_Usuario_Request(Req);


            {
            Vai no DmGlobal, passa o parametro recebido, faz a query com o retorno
            Monta uma lista, um  jsonArray com o retorno da query, utilizando o TJsonArray
            e devolve para o usu�rio
            }

           // Res.Send<TJSONArray>(DmGlobal.ListarCondPagto).Status(200);

           //Negocius
            Res.Send<TJSONArray>(DmCondPagto.ListarCondPagto).Status(200);


        except on ex:exception do
            Res.Send(ex.Message).Status(500); //devolve o status 500 caso de erro no servidor
        end;
   finally
        //Destruo e tiro da memoria o dmglobal
            FreeAndNil(DmGlobal);
            FreeAndNil(DmCondicaoPagamento);
   end;
end;

procedure ListarFormapagto (Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
 DmGlobal : TDmGLobal;
 DmCondicaoPagamento : TDmCondPagto;
 cod_usuario, pagina : Integer;
       {
       o Verbo GET, n�o vem no corpo da requisi��o, ele vem na pr�pria URL,
       precedido de uma interroga��o
        http://servidor : porta / rota ? nome do parametro = valor parametro & outro parametro = valor & parametro = valor
      ex:
       Http://localhost:9000/pedidos/sincronizacao?= 2022-11-02  08:00:00
       }
begin
   try
        try
            //Levanto o m�duo de dados(crio ele)
            DmGlobal := TDmGLobal.Create(nil);
            DmCondicaoPagamento := TDmCondPagto.Create(nil);

            //exrai o c�digo do usuario   do token pela classe Controllers.Auth
            cod_usuario := Get_Usuario_Request(Req);


            {
            Vai no DmGlobal, passa o parametro recebido, faz a query com o retorno
            Monta uma lista, um  jsonArray com o retorno da query, utilizando o TJsonArray
            e devolve para o usu�rio
            }

           // Res.Send<TJSONArray>(DmGlobal.ListarCondPagto).Status(200);

           //Negocius
            Res.Send<TJSONArray>(DmCondPagto.ListarFormaPagto).Status(200);


        except on ex:exception do
            Res.Send(ex.Message).Status(500); //devolve o status 500 caso de erro no servidor
        end;
   finally
        //Destruo e tiro da memoria o dmglobal
            FreeAndNil(DmGlobal);
            FreeAndNil(DmCondicaoPagamento);
   end;
end;

procedure ListarClienteFormaPagto (Req : THorseRequest; Res : THorseResponse; Next : TProc);
var
 DmGlobal : TDmGLobal;
 DmCondicaoPagamento : TDmCondPagto;
 dt_ultima_sincronizacao: string;
 cod_usuario, pagina, cod_cliente : Integer;
       {
       o Verbo GET, n�o vem no corpo da requisi��o, ele vem na pr�pria URL,
       precedido de uma interroga��o
        http://servidor : porta / rota ? nome do parametro = valor parametro & outro parametro = valor & parametro = valor
      ex:
       Http://localhost:9000/pedidos/sincronizacao?= 2022-11-02  08:00:00
       }
begin
      try
            try
                //Levanto o m�duo de dados(crio ele)
                DmGlobal := TDmGLobal.Create(nil);
                DmCondicaoPagamento := TDmCondPagto.Create(nil);

                //recebe a data da ultima sincroniza��o do lado mobile
                try
                   dt_ultima_sincronizacao := Req.Query['dt_ultima_sincronizacao'];
                except
                   dt_ultima_sincronizacao := '';
                end;

                //pagina
                try
                  pagina := Req.Query['pagina'].ToInteger;
                except
                  pagina := 1;
                end;

                //recebe o c�digo do vendedor do lado mobile
                //e extrai do token pela classe Controllers.Auth
                try
                  cod_usuario := Get_Usuario_Request(Req);
                except
                  cod_usuario := 1;
                end;


               {quando � passado algum parametro, � itilizando o req.params.items['nome do parametro']
               que recupero}
               // cod_cliente := Req.Params.Items['cod_cliente'].ToInteger;

                {
                Vai no DmGlobal, passa o parametro recebido, faz a query com o retorno
                Monta uma lista, um  jsonArray com o retorno da query, utilizando o TJsonArray
                e devolve para o usu�rio
                }

               // Res.Send<TJSONArray>(DmGlobal.ListarCondPagto).Status(200);

               //Negocius
                Res.Send<TJSONArray>(DmCondPagto.ListarClienteFormaPagto(dt_ultima_sincronizacao,
                                    {pagina,} cod_usuario)).Status(200);


            except on ex:exception do
                Res.Send(ex.Message).Status(500);
                //devolve o status 500 caso de erro no servidor
           end;

      finally
            //Destruo e tiro da memoria o dmglobal
                FreeAndNil(DmGlobal);
                FreeAndNil(DmCondicaoPagamento);

      end;
end;

end.
