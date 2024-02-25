unit DateModule.Global;
 {
  O DmGlobal, foi retirardo do auto criate, pois quando a requisição chegar, ele será criado
  executará a rotina, devolverá os dados e será destruído, e recriado sempre que for requisitado
  Utilizarei o conceito de statless
 }
interface

uses
  uMD5,

  Data.DB,

  DataSet.Serialize,
  DataSet.Serialize.Config,

  FMX.Graphics,

  FireDAC.Comp.Client,
  FireDAC.DApt,
  FireDAC.FMXUI.Wait,
  FireDAC.Phys,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,
  FireDAC.Phys.IBBase,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Async,
  FireDAC.Stan.Def,
  FireDAC.Stan.Error,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Pool,
  FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait,

  System.Classes,
  System.JSON,
  System.SysUtils,
  System.Variants,

  system.IniFiles;

type
  TDmGlobal = class(TDataModule)
    Conn: TFDConnection;
    FDPhysFBDriverLink: TFDPhysFBDriverLink;
    Transacoes: TFDTransaction;
    procedure DataModuleCreate(Sender: TObject);
    procedure ConnBeforeConnect(Sender: TObject);
  private
    procedure CarregarConfigDB(Connection: TFDConnection);
    function  ListarItensPedido(cod_pedido : Integer; Qry: TFDQuery) : TJSONArray;
    { Private declarations }
  public
    function Login(email, senha: string): TJSonObject;
    function InserirUsuario(Nome, Email, Senha : string) : TJSonObject;
    function Push(cod_usuario: Integer; token_push: string): TJSonObject;
    function EditarUsuario(cod_usuario : Integer; nome, email : string) : TJSonObject;
    function EditarSenha(cod_usuario: Integer; senha: string): TJSonObject;
    function ListarNotificacoes(cod_usuario : Integer) : TJSONArray;
    function ListarClientes(dt_ultima_sincronizacao : String; pagina: Integer) : TJSONArray;
    function InserirEditarCliente (cod_usuario, cod_cliente_local: Integer;
                                               cnpj_cpf, nome, fone, email, endereco, numero,
                                               complemento, bairro, cidade, uf, cep: string;
                                               latitude, longitude, limite_disponivel: Double;
                                               cod_cliente_oficial: Integer;
                                               dt_ult_sincronizacao: string ) : TJSonObject;
    function ListarProdutos(dt_ultima_sincronizacao: String; pagina: Integer): TJSONArray;
    function InserirEditarProduto(cod_usuario, cod_produto_local,cod_produto_oficial: Integer;
                                               valor,qtd_estoque : Double;
                                               descricao,dt_ult_sincronizacao : string ) : TJSonObject;
    function ListarFoto(cod_produto : Integer) : TMemoryStream;
    procedure EditarFoto(cod_produto: Integer; Foto: TBitmap);
    function ListarPedidos(dt_ultima_sincronizacao : String; cod_usuario, pagina: Integer) : TJSONArray;
    function InserirEditarPedido (cod_usuario, cod_pedido_local, cod_cliente ,
                                           cod_cond_pagto, cod_pedido_oficial: Integer;
                                           tipo_pedido, data_pedido, contato, obs,
                                           prazo_entrega, data_entrega  : string;
                                           dt_ult_sincronizacao : string;
                                           valor_total : Double;
                                           Itens: TJSONArray ) : TJSonObject;
   function ListarCondPagto: TJSONArray;

  end;

var
  DmGlobal: TDmGlobal;

 Const
   QTD_DE_REG_PAGINA_CLIENTE  = 30;
   QTD_DE_REG_PAGINA_CLI_X_FORMA_PAGTO  = 300;
   QTD_DE_REG_PAGINA_PRODUTO  = 1000;
   QTD_DE_REG_PAGINA_ESTOQUE  = 1000;
   QTD_DE_REG_PAGINA_PEDIDO   = 30;
   QTD_DE_REG_PAGINA_PED_FORMA_PAGTO   = 100;

implementation
  Uses
   UFuncoes;
{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TDmGlobal.CarregarConfigDB(Connection: TFDConnection);
var
    ini : TIniFile;
    arq: string;
begin
    try
        // Caminho do INI...Pega o caminho exato de onde está o executável
        arq := ExtractFilePath(ParamStr(0)) + 'fastpedconfig.ini';

        // Validar arquivo INI...
        if NOT FileExists(arq) then
            raise Exception.Create('Arquivo INI não encontrado: ' + arq);

        // Instanciar arquivo INI...
        ini := TIniFile.Create(arq);
        Connection.DriverName := ini.ReadString('Banco de dados FastPed', 'DriverID', '');

        // Buscar dados do arquivo fisico...
        with Connection.Params do
        begin
            Clear;
            Add('DriverID=' + ini.ReadString('Banco de dados FastPed', 'DriverID', ''));
            Add('Database=' + ini.ReadString('Banco de dados FastPed', 'Database', ''));
            Add('User_Name=' + ini.ReadString('Banco de dados FastPed', 'User_name', ''));
            Add('Password=' + ini.ReadString('Banco de dados FastPed', 'Password', ''));
        //    Add('Protocol=' + ini.ReadString('Banco de dados FastPed', 'Protocol', ''));

            if ini.ReadString('Banco de dados FastPed', 'Port', '') <> '' then
                Add('Port=' + ini.ReadString('Banco de dados FastPed', 'Port', ''));

            if ini.ReadString('Banco de dados FastPed', 'Server', '') <> '' then
                Add('Server=' + ini.ReadString('Banco de dados FastPed', 'Server', ''));

//            if ini.ReadString('Banco de dados FastPed', 'Protocol', '') <> '' then
//                Add('Protocol=' + ini.ReadString('Banco de dados FastPed', 'Protocol', ''));

            if ini.ReadString('Banco de dados FastPed', 'Protocol', '') <> '' then
                Add('Protocol=' + ini.ReadString('Banco de dados FastPed', 'Protocol', ''));

            if ini.ReadString('Banco de dados FastPed', 'VendorLib', '') <> '' then
                FDPhysFBDriverLink.VendorLib := ini.ReadString('Banco de dados FastPed', 'VendorLib', '');
        end;

    finally
        if Assigned(ini) then
            ini.DisposeOf;
    end;
end;

// passando o parametro que é o componente de conexão (Conn)
procedure TDmGlobal.ConnBeforeConnect(Sender: TObject);
begin
    CarregarConfigDB(Conn);
end;

//chama a rotina que configura os parametros de configurações
//Abre a conexao com o banc de dados quando criado.
procedure TDmGlobal.DataModuleCreate(Sender: TObject);
begin
   //Configuro para que o datasetSeriaize não altere os nomes na hora de montar o Json
   //Apenas converta para minúsculo
     TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLower; // ---> Nome_usuario --> nome_usuario e não nomeusuario
   //Define o separador de milhar padrão com .
     TDatasetSerializeConfig.GetInstance.Import.DecimalSeparator := '.';  //--> R500,00 ---> 500.00


     Conn.Connected := True;
end;

 //Verifica os dados do usuario para o login
function TDmGlobal.Login(email, senha : string): TJSonObject;
 var
 qry : TFDQuery; // se fosse utilizar sem compnente em tempo de execução
begin
    //Valido os dados recebidos...
    if (email =' ') or (senha.IsEmpty) then
      raise Exception.Create('Informe o email e a senha');

   try
     qry := TFDQuery.Create(nil);
     qry.Connection := conn;

    with qry do
    begin
        Active := False;
        sql.Clear;
        SQL.Add('SELECT COD_USUARIO, NOME, EMAIL');
        SQL.Add('FROM TAB_USUARIO WHERE EMAIL = :EMAIL AND SENHA = :SENHA');

        ParamByName('EMAIL').Value := Email;
        ParamByName('SENHA').Value := SaltPassword(Senha); //saltpassowd, embaraçha a senha, uma especie de criptografia

        Active := True;
    end;

        //  Monta um objeto json com o resultado da query
          {"cod_usuario":123,"Nome":"Tiago","Email":"tiago"gmail.com"}
        Result := qry.ToJSONObject;
    finally
         FreeAndNil(qry);
    end;
end;


//insere novos usuarios no banco de dados
function TDmGlobal.InserirUsuario(Nome, Email, Senha : string) : TJSonObject;
 var
 qry : TFDQuery; // se fosse utilizar sem compnente em tempo de execução
begin
    //Valido os dados recebidos...
    if (nome.IsEmpty) or (email = '') or (senha.IsEmpty) then
      raise Exception.Create('Informe o nome, e-mail e senha');

    if (senha.Length < 6 ) then
    raise Exception.Create('O Tamanho minimo da senha deve conter o mínimo 6 caracteres alfanuméricos');

    try

     qry := TFDQuery.Create(nil);
     qry.Connection := conn;

    with qry do
    begin
         //Validação do email se já está em uso por outro usuario...
        Active := False;
        sql.Clear;
        SQL.Add('SELECT COD_USUARIO FROM TAB_USUARIO');
        SQL.Add('WHERE EMAIL = :EMAIL');
        ParamByName('EMAIL').Value := Email;
        Active := True;

        if RecordCount > 0 then
        raise Exception.Create('Este e-mail já está sendo utilizado por outra conta de usuário');


        Active := False;
        sql.Clear;
        SQL.Add('INSERT INTO TAB_USUARIO (NOME, EMAIL, SENHA)');
        SQL.Add('VALUES (:NOME, :EMAIL, :SENHA)');
        sql.Add('RETURNING COD_USUARIO');

        ParamByName('NOME').Value := NOME;
        ParamByName('EMAIL').Value := Email;
        ParamByName('SENHA').Value := SaltPassword(Senha);

        Active := True;

    end;

      //  Monta um objeto json com o resultado da query
      {"cod_usuario":123,"Nome":"Tiago","Email":"tiago"gmail.com"}
       Result := qry.ToJSONObject;
    finally
         FreeAndNil(qry);
    end;
end;


//Grava o token Push para o usuário específico
function TDmGlobal.Push(cod_usuario : Integer; token_push : string) : TJSonObject;
 var
 qry : TFDQuery; // se fosse utilizar sem compnente em tempo de execução
begin
    //Valido os dados recebidos...
    if (token_push.IsEmpty)  then
      raise Exception.Create('Informe o Token Push do Usuário');

    try

     qry := TFDQuery.Create(nil);
     qry.Connection := conn;

    with qry do
    begin
        Active := False;
        sql.Clear;
        SQL.Add('UPDATE TAB_USUARIO SET TOKEN_PUSH = :TOKEN_PUSH');
        SQL.Add('WHERE COD_USUARIO = :COD_USUARIO');
        sql.Add('RETURNING COD_USUARIO'); //RECUPERA O CÓDIGO DO USUARIO

        ParamByName('COD_USUARIO').Value := cod_usuario;
        ParamByName('TOKEN_PUSH').Value := token_push;

        Active := True;

    end;

      //  Monta um objeto json com o resultado da query
            {"cod_usuario":123}
       Result := qry.ToJSONObject;
    finally
         FreeAndNil(qry);
    end;
end;


//Edita dados do usuarios no banco de dados
function TDmGlobal.EditarUsuario(cod_usuario : Integer; nome, email : string) : TJSonObject;
 var
 qry : TFDQuery; // se fosse utilizar sem compnente em tempo de execução
begin
      //Valido os dados recebidos...
    if (nome = '' ) or (email.IsEmpty)  then
      raise Exception.Create('Informe o nome e o e-mail do Usuário');

    try

     qry := TFDQuery.Create(nil);
     qry.Connection := conn;

    with qry do
    begin

                 //Validação do email se já está em uso por outro usuario...
        Active := False;
        sql.Clear;
        SQL.Add('SELECT COD_USUARIO FROM TAB_USUARIO');
        SQL.Add('WHERE EMAIL = :EMAIL AND COD_USUARIO <> :COD_USUARIO');
        ParamByName('EMAIL').Value := Email;
        ParamByName('COD_USUARIO').value := cod_usuario;
        Active := True;

        if RecordCount > 0 then
        raise Exception.Create('Este e-mail já está sendo utilizado por outra conta de usuário');




        Active := False;
        sql.Clear;
        SQL.Add('UPDATE TAB_USUARIO SET NOME = :NOME, EMAIL = :EMAIL ');
        SQL.Add('WHERE COD_USUARIO = :COD_USUARIO');
        sql.Add('RETURNING COD_USUARIO'); //RECUPERA O CÓDIGO DO USUARIO

        ParamByName('COD_USUARIO').Value := cod_usuario;
        ParamByName('NOME').Value := nome;
        ParamByName('EMAIL').Value := email;

        Active := True;

    end;

      //  Monta um objeto json com o resultado da query
            {"cod_usuario":123}
       Result := qry.ToJSONObject;
    finally
         FreeAndNil(qry);
    end;
end;


//edita a senha do usuario
function TDmGlobal.EditarSenha(cod_usuario : Integer; senha : string) : TJSonObject;
 var
 qry : TFDQuery; // se fosse utilizar sem compnente em tempo de execução
begin
    //Valido os dados recebidos...
    if (senha = '' ) then
      raise Exception.Create('Informe a senha do usuário');

    if (senha.Length < 6 ) then
    raise Exception.Create('O Tamanho minimo da senha deve conter o mínimo 6 caracteres alfanuméricos');


    try

     qry := TFDQuery.Create(nil);
     qry.Connection := conn;

    with qry do
    begin
        Active := False;
        sql.Clear;
        SQL.Add('UPDATE TAB_USUARIO SET SENHA = :SENHA ');
        SQL.Add('WHERE COD_USUARIO = :COD_USUARIO');
        sql.Add('RETURNING COD_USUARIO'); //RECUPERA O CÓDIGO DO USUARIO

        ParamByName('COD_USUARIO').Value := cod_usuario;
        ParamByName('SENHA').Value := SaltPassword(Senha); // utilizo o SaltPassoword para criar  o rash da senha

        Active := True;

    end;

      //  Monta um objeto json com o resultado da query
            {"cod_usuario":123}
       Result := qry.ToJSONObject;
    finally
         FreeAndNil(qry);
    end;
end;

//Lista as Notificações
function TDmGlobal.ListarNotificacoes(cod_usuario : Integer) : TJSONArray;
 var
 qry : TFDQuery; // se fosse utilizar sem compnente em tempo de execução
begin

    try

     qry := TFDQuery.Create(nil);
     qry.Connection := conn;

        with qry do
        begin
          {
          Fazo select na tabela, e lista todas as mensagens nao lidas
          }
            Active := False;
            sql.Clear;
            SQL.Add('SELECT COD_NOTIFICACAO, DATA_NOTIFICACAO, TITULO, TEXTO');
            SQL.Add('FROM TAB_NOTIFICACAO WHERE COD_USUARIO = :COD_USUARIO');
            SQL.Add('AND IND_LIDO = :IND_LIDO');

            ParamByName('COD_USUARIO').Value := cod_usuario;
            ParamByName('IND_LIDO').Value := 'N';
            Active := True;
           // Após, Monta um  array objeto json com o resultado da query
           Result := qry.ToJSONArray;

           //Marcar mensagens como lidas...
            Active := False;
            sql.Clear;
            SQL.Add('UPDATE TAB_NOTIFICACAO SET IND_LIDO = ''S'' ');
            SQL.Add(' WHERE COD_USUARIO = :COD_USUARIO');
            SQL.Add('AND IND_LIDO = :IND_LIDO');
            ParamByName('COD_USUARIO').Value := cod_usuario;
            ParamByName('IND_LIDO').Value := 'N';
            ExecSQL;

        end;


    finally
         FreeAndNil(qry);
    end;
end;

//Lista os cientes
function TDmGlobal.ListarClientes(dt_ultima_sincronizacao : String;
                                  pagina: Integer) : TJSONArray;
 var
 qry : TFDQuery; // se fosse utilizar sem compnente em tempo de execução
begin
    if dt_ultima_sincronizacao.IsEmpty then
    raise Exception.Create('O parâmetro dt_ultima_sincronizacao, não foi informado.');

    try

     qry := TFDQuery.Create(nil);
     qry.Connection := conn;

        with qry do
        begin
          {
          Fazo select na tabela, e lista os clientes
          }
          {  Active := False;
            sql.Clear;
            SQL.Add('SELECT FIRST :FIRST SKIP :SKIP * '); //PARA TRATAR A PAGINAÇÃO
            SQL.Add('FROM TAB_CLIENTE_FASTPED');
            SQL.Add('WHERE DATA_ULT_ALTERACAO > :DATA_ULT_ALTERACAO');
            SQL.Add('ORDER BY COD_CLIENTE');

            ParamByName('DATA_ULT_ALTERACAO').Value := dt_ultima_sincronizacao;
            //TRATAR A PAGINAÇÃO
            ParamByName('FIRST').Value := QTD_DE_REG_PAGINA_CLIENTE; //Quantos registro quero trazer
            ParamByName('SKIP').Value := (pagina * QTD_DE_REG_PAGINA_CLIENTE) - QTD_DE_REG_PAGINA_CLIENTE;  //Quantos tenho que pular...
            {
            o calculo do salto de registro acima é a página atual x quantidade de registro que quero,
              menos a quanditade de registro que já possui

            Active := True;    }

            //BANCO DE DADOS NEGOCIUS
            Active := False;
            sql.Clear;
            SQL.Add('SELECT FIRST :FIRST SKIP :SKIP * '); //TRATAR A PAGINAÇÃO
            SQL.Add('FROM T_REPRESENTANTE_X_CLIENTE REPCLI');
            SQL.Add('JOIN T_REPRESENTANTE REP on( REP.ISN_REPRESENTANTE = REPCLI.ISN_REPRESENTANTE )');
            SQL.Add('join T_CLIENTE  CLI ON (CLI.ISN_CLIENTE = REPCLI.ISN_CLIENTE)');
            SQL.Add('WHERE CLI.CLIDT_ULTIMO_RECADASTRAMENTO > :DATA_ULT_ALTERACAO');
            SQL.Add('AND REP.REPCN_REPRESENTANTE = :COD_REPRESENTANTE ');
            SQL.Add('ORDER BY CLICN_CLIENTE');

            ParamByName('DATA_ULT_ALTERACAO').Value := dt_ultima_sincronizacao;

            //TRATAR A PAGINAÇÃO
            ParamByName('FIRST').Value := QTD_DE_REG_PAGINA_CLIENTE; //Quantos registro quero trazer
            ParamByName('SKIP').Value := (pagina * QTD_DE_REG_PAGINA_CLIENTE) - QTD_DE_REG_PAGINA_CLIENTE;  //Quantos tenho que pular...
            {
            o calculo do salto de registro acima é a página atual x quantidade de registro que quero,
              menos a quanditade de registro que já possui
            }

            Active := True;

        end;

        // Após, Monta um  array objeto json com o resultado da query
           Result := qry.ToJSONArray;

    finally
         FreeAndNil(qry);
    end;
end;

//Insere ou edita um cliente
function TDmGlobal.InserirEditarCliente (cod_usuario, cod_cliente_local: Integer;
                                               cnpj_cpf, nome, fone, email, endereco, numero,
                                               complemento, bairro, cidade, uf, cep: string;
                                               latitude, longitude, limite_disponivel: Double;
                                               cod_cliente_oficial: Integer;
                                               dt_ult_sincronizacao: string ) : TJSonObject;

 var
 qry : TFDQuery; // se fosse utilizar sem compnente em tempo de execução
begin
    try
     qry := TFDQuery.Create(nil);
     qry.Connection := conn;

      with qry do
      begin
          Active := False;
          sql.Clear;

          if cod_cliente_oficial = 0 then
          begin
            SQL.Add('INSERT INTO TAB_CLIENTE (COD_USUARIO, CNPJ_CPF, NOME, FONE, EMAIL,');
            SQL.Add('ENDERECO, NUMERO, COMPLEMENTO, BAIRRO, CIDADE, UF, ');
            SQL.Add('CEP, LATITUDE, LONGITUDE, LIMITE_DISPONIVEL, DATA_ULT_ALTERACAO)');

            SQL.Add('VALUES (:COD_USUARIO, :CNPJ_CPF, :NOME, :FONE, :EMAIL,');
            SQL.Add(':ENDERECO, :NUMERO, :COMPLEMENTO, :BAIRRO, :CIDADE, :UF, ');
            SQL.Add(':CEP, :LATITUDE, :LONGITUDE, :LIMITE_DISPONIVEL, :DATA_ULT_ALTERACAO)');
            SQL.Add('RETURNING COD_CLIENTE '); //não aceita alias

            ParamByName('COD_USUARIO').Value := cod_usuario;

          end
          else
          begin
            SQL.Add('UPDATE TAB_CLIENTE SET CNPJ_CPF = :CNPJ_CPF, NOME = :NOME, FONE = :FONE, EMAIL = :EMAIL,');
            SQL.Add('ENDERECO = :ENDERECO, NUMERO =:NUMERO, COMPLEMENTO =:COMPLEMENTO, BAIRRO = :BAIRRO, CIDADE = :CIDADE, UF = :UF, ');
            SQL.Add('CEP = :CEP, LATITUDE =:LATITUDE, LONGITUDE =:LONGITUDE, LIMITE_DISPONIVEL =:LIMITE_DISPONIVEL,');
            SQL.Add('DATA_ULT_ALTERACAO = :DATA_ULT_ALTERACAO');

            SQL.Add('WHERE COD_CLIENTE = :COD_CLIENTE');
            SQL.Add('RETURNING COD_CLIENTE');     //não aceita alias

            ParamByName('COD_CLIENTE').Value := cod_cliente_oficial;
          end;

            ParamByName('CNPJ_CPF').Value := cnpj_cpf;
            ParamByName('NOME').Value :=   nome;
            ParamByName('FONE').Value :=   fone;
            ParamByName('EMAIL').Value :=  email;
            ParamByName('ENDERECO').Value := endereco;
            ParamByName('NUMERO').Value :=   numero;
            ParamByName('COMPLEMENTO').Value :=   complemento;
            ParamByName('BAIRRO').Value :=   bairro;
            ParamByName('CIDADE').Value :=   cidade;
            ParamByName('UF').Value := uf;
            ParamByName('CEP').Value :=  cep;
            ParamByName('LATITUDE').Value :=  latitude;
            ParamByName('LONGITUDE').Value := longitude;
            ParamByName('LIMITE_DISPONIVEL').Value := limite_disponivel;
            ParamByName('DATA_ULT_ALTERACAO').Value :=  dt_ult_sincronizacao;


          Active := True;

      end;

      //  Monta um objeto json com o resultado da query
            {"cod_usuario":123}
       Result := qry.ToJSONObject;
    finally
         FreeAndNil(qry);
    end;
end;

//Lista produtos
function TDmGlobal.ListarProdutos(dt_ultima_sincronizacao : String;
                                  pagina: Integer) : TJSONArray;
 var
 qry : TFDQuery; // se fosse utilizar sem compnente em tempo de execução
begin
    if dt_ultima_sincronizacao.IsEmpty then
    raise Exception.Create('O parâmetro dt_ultima_sincronizacao, não foi informado.');

    try

     qry := TFDQuery.Create(nil);
     qry.Connection := conn;

        with qry do
        begin
          {
          Fazo select na tabela, e lista os produtos
          }
           Active := False;
            sql.Clear;
            SQL.Add('SELECT FIRST :FIRST SKIP :SKIP COD_PRODUTO, DESCRICAO, VALOR, QTD_ESTOQUE  '); //PARA TRATAR A PAGINAÇÃO
            SQL.Add('FROM TAB_PRODUTO');
            SQL.Add('WHERE DATA_ULT_ALTERACAO > :DATA_ULT_ALTERACAO');
            SQL.Add('ORDER BY COD_PRODUTO');

            ParamByName('DATA_ULT_ALTERACAO').Value := dt_ultima_sincronizacao;
            //TRATAR A PAGINAÇÃO
            ParamByName('FIRST').Value := QTD_DE_REG_PAGINA_CLIENTE; //Quantos registro quero trazer
            ParamByName('SKIP').Value := (pagina * QTD_DE_REG_PAGINA_PRODUTO) - QTD_DE_REG_PAGINA_PRODUTO;  //Quantos tenho que pular...
            {
            o calculo do salto de registro acima é a página atual x quantidade de registro que quero,
              menos a quanditade de registro que já possui
            }
           Active := True;

            //BANCO DE DADOS NEGOCIUS
          {  Active := False;
            sql.Clear;
            SQL.Add('SELECT FIRST :FIRST SKIP :SKIP  '); //TRATAR A PAGINAÇÃO
            SQL.Add('PROD.ISN_PRODUTO, PROD.PROCC_PRODUTO, PROD.PRODS_PRODUTO, ESTQ.ESTQT_ESTOQUE, ');
            SQL.Add('PREC.PREVL_UNITARIO FROM T_PRODUTO PROD ');
            SQL.Add('JOIN T_PRECO PREC ON (PREC.ISN_PRODUTO = PROD.ISN_PRODUTO) ');
            SQL.Add('JOIN T_ESTOQUE ESTQ ON (ESTQ.ISN_PRODUTO = PROD.ISN_PRODUTO) ');
            SQL.Add('JOIN T_TIPO_PRODUTO TPROD ON (TPROD.ISN_TIPO_PRODUTO = PROD.ISN_TIPO_PRODUTO) ');
            SQL.Add('WHERE TPROD.TPFG_TIPO_PRODUTO = ''V'' ');
            SQL.Add('AND PREC.PREFG_ULT_PRECO = ''S'' ');
           // SQL.Add('PROD.PRODT_ALTERACAO > :PRODT_ALTERACAO');

            SQL.Add('ORDER BY PRODS_PRODUTO');

          //  ParamByName('PRODT_ALTERACAO').Value := dt_ultima_sincronizacao;

            //TRATAR A PAGINAÇÃO
            ParamByName('FIRST').Value := QTD_DE_REG_PAGINA_CLIENTE; //Quantos registro quero trazer
            ParamByName('SKIP').Value := (pagina * QTD_DE_REG_PAGINA_CLIENTE) - QTD_DE_REG_PAGINA_CLIENTE;  //Quantos tenho que pular...
            {
            o calculo do salto de registro acima é a página atual x quantidade de registro que quero,
              menos a quanditade de registro que já possui
            }

         //   Active := True;

        end;

        // Após, Monta um  array objeto json com o resultado da query
           Result := qry.ToJSONArray;

    finally
         FreeAndNil(qry);
    end;
end;


//Insere ou edita um produto
function TDmGlobal.InserirEditarProduto (cod_usuario, cod_produto_local, cod_produto_oficial: Integer;
                                               valor,qtd_estoque : Double;
                                               descricao,dt_ult_sincronizacao : string ) : TJSonObject;
 var
 qry : TFDQuery; // se fosse utilizar sem compnente em tempo de execução
begin
    try
     qry := TFDQuery.Create(nil);
     qry.Connection := conn;

      with qry do
      begin
          Active := False;
          sql.Clear;

          if cod_produto_oficial = 0 then
          begin
            SQL.Add('INSERT INTO TAB_PRODUTO ( COD_USUARIO, DESCRICAO, VALOR, QTD_ESTOQUE, DATA_ULT_ALTERACAO )');
            SQL.Add('VALUES (:COD_USUARIO, :DESCRICAO, :VALOR, :QTD_ESTOQUE, :DATA_ULT_ALTERACAO)');
            SQL.Add('RETURNING COD_PRODUTO'); //não aceita alias

            ParamByName('COD_USUARIO').Value := cod_usuario;

          end
          else
          begin
            SQL.Add('UPDATE TAB_PRODUTO SET DESCRICAO = :DESCRICAO, VALOR = :VALOR, QTD_ESTOQUE = :QTD_ESTOQUE,');
            SQL.Add('DATA_ULT_ALTERACAO = :DATA_ULT_ALTERACAO');
            SQL.Add('WHERE COD_PRODUTO = :COD_PRODUTO');
            SQL.Add('RETURNING COD_PRODUTO');     //não aceita alias

            ParamByName('COD_PRODUTO').Value := cod_produto_oficial;
          end;

            ParamByName('DESCRICAO').Value := descricao;
            ParamByName('VALOR').Value :=   valor;
            ParamByName('QTD_ESTOQUE').Value :=  qtd_estoque;
            ParamByName('DATA_ULT_ALTERACAO').Value :=  dt_ult_sincronizacao;


          Active := True;

      end;

      //  Monta um objeto json com o resultado da query
            {"cod_usuario":123}
       Result := qry.ToJSONObject;
    finally
         FreeAndNil(qry);
    end;
end;


//Lista foto do produto
function TDmGlobal.ListarFoto(cod_produto : Integer) : TMemoryStream;
 var
 qry : TFDQuery; // se fosse utilizar sem compnente em tempo de execução
 Lstream : TStream;
begin
    if cod_produto <= 0 then
    raise Exception.Create('O parâmetro cod_produto, não foi informado.');

    try

     qry := TFDQuery.Create(nil);
     qry.Connection := conn;

        with qry do
        begin
          {
          Fazo select na tabela, e lista os produtos
          }

          {
            Active := False;
            sql.Clear;
            SQL.Add('SELECT FOTO '); //PARA TRATAR A PAGINAÇÃO
            SQL.Add('FROM TAB_PRODUTO');
            SQL.Add('WHERE COD_PRODUTO > :COD_PRODUTO');

            ParamByName('COD_PRODUTO').Value := cod_produto;

            Active := True;

             if qry.FieldByName('FOTO').AsString = '' then
                raise Exception.Create('O produto não possui uma foto cadastrada');   }

            //BANCO DE DADOS NEGOCIUS

            Active := False;
            sql.Clear;
            SQL.Add('SELECT PROBL_FOTO FROM  T_PRODUTO');
            SQL.Add('WHERE ISN_PRODUTO = :ISN_PRODUTO');
          //  SQL.Add('WHERE PROBL_FOTO IS NOT NULL ');

            ParamByName('ISN_PRODUTO').Value := cod_produto;

             Active := True;


         //    if qry.FieldByName('PROBL_FOTO').AsString = '' then
         //       raise Exception.Create('O produto não possui uma foto cadastrada');
        end;

       {
       Para devolver uma imagem do banco de dados, utilizo a propiedade CREATEBLOBSTREM do componente
       para converter o stream, esse modo espera dois parametros

       1º o campo que será convertido em blob,
          qry.Createstreamblob(Campo_queserá_convertido, )
       2º o modo como será enviado,
          qry.Createstreamblob(Campo_queserá_convertido, TBLOBSTREMMOD.BMREAD )

         Assim sera criado um blobstream com base no primeiro parametro passado
       }

       {
        Crio uma variável do Tipo TStream, para receber o stream do banco de dados,
        após isso,
       }


       Lstream := qry.CreateBlobStream(qry.FieldByName('PROBL_FOTO'), TBlobStreamMode.bmRead); //  BANCO NEGOCIUS

      //     Lstream := qry.CreateBlobStream(qry.FieldByName('FOTO'), TBlobStreamMode.bmRead);


       Result := TMemoryStream.Create;
       Result.LoadFromStream(Lstream);
       FreeAndNil(Lstream);
    finally
         FreeAndNil(qry);
    end;
end;

//Lista foto do produto
procedure TDmGlobal.EditarFoto(cod_produto : Integer; Foto : TBitmap);
 var
 qry : TFDQuery; // se fosse utilizar sem compnente em tempo de execução
begin
    if cod_produto <= 0 then
    raise Exception.Create('O parâmetro cod_produto, não foi informado.');

    if Foto.IsEmpty  then
    raise Exception.Create('O parâmetro foto, não foi informado.');

    try

     qry := TFDQuery.Create(nil);
     qry.Connection := conn;

        with qry do
        begin
            Active := False;
            sql.Clear;
            SQL.Add('UPDATE TAB_PRODUTO SET FOTO = :FOTO');
            SQL.Add('WHERE COD_PRODUTO > :COD_PRODUTO');

            ParamByName('COD_PRODUTO').Value := cod_produto;
            ParamByName('FOTO').Assign(foto); // Os tipos Blobs são passados dentro do assinged

            ExecSQL;

      //       if qry.FieldByName('FOTO').AsString = '' then
      //          raise Exception.Create('O produto não possui uma foto cadastrada');

            //BANCO DE DADOS NEGOCIUS

           { Active := False;
            sql.Clear;
            SQL.Add('UPDATE T_PRODUTO SET PROBL_FOTO = :PROBL_FOTO');
            SQL.Add('WHERE PROCC_PRODUTO = :PROCC_PRODUTO ');

            ParamByName('PROCC_PRODUTO').Value := cod_produto;
            ParamByName('PROBL_FOTO').Assign(Foto); // Os tipos blobs são passadas dentro de assing
            ExecSQL; }
        end;
    finally
         FreeAndNil(qry);
    end;
end;


//Lista os itens do pedido
//passo como parametro a qry do listar pedidos
function TDmGlobal.ListarItensPedido(cod_pedido : Integer;
                                     Qry: TFDQuery) : TJSONArray;
 begin
      with qry do
        begin

        //  Fazo select na tabela, e lista os itens

            Active := False;
            sql.Clear;
            SQL.Add('SELECT COD_ITEM, COD_PRODUTO, QTD, VALOR_UNITARIO, VALOR_TOTAL '); //PARA TRATAR A PAGINAÇÃO
            SQL.Add('FROM TAB_PEDIDO_ITEM');
            SQL.Add('WHERE COD_PEDIDO = :COD_PEDIDO');
            SQL.Add('ORDER BY COD_ITEM');

            ParamByName('COD_PEDIDO').Value := cod_pedido;

           Active := True;

      end;
       //Converte o resultado do sql para um array json.
      Result := qry.ToJSONArray;

      //ERP NEGOCIUS
     { with qry do
        begin
            Active := False;
            SQL.Clear;
            SQL.Add('SELECT IPED.IPENR_SEQUENCIAL, PROD.PROCC_PRODUTO,');
            SQL.Add('IPED.IPEQT_QUANTIDADE, IPED.IPEVL_UNITARIO, (IPED.IPEQT_QUANTIDADE * IPED.IPEVL_UNITARIO)');
            SQL.Add('AS VALOR_TOTAL ');
            SQL.Add('FROM T_ITEM_PEDIDO IPED');
            SQL.Add('JOIN T_PRODUTO PROD ON (PROD.ISN_PRODUTO = IPED.ISN_PRODUTO)');
            SQL.Add('WHERE IPED.ISN_PEDIDO = :ISN_PEDIDO');
            SQL.Add('ORDER BY PROCC_PRODUTO');

            ParamByName('ISN_PEDIDO').Value := cod_pedido;

           Active := True;
        end;   }

       Result := qry.ToJSONArray;  //Devolverá para a função Listar pedidos para o Paradicionado ( item )
 end;



//Lista pedidos
function TDmGlobal.ListarPedidos(dt_ultima_sincronizacao : String;
                                 cod_usuario, pagina: Integer) : TJSONArray;
 var
 pedidos : TJSONArray;
 cod_pedido : Integer;
 i : Integer;
 qry : TFDQuery; // se fosse utilizar sem compnente em tempo de execução
begin
    if dt_ultima_sincronizacao.IsEmpty then
    raise Exception.Create('O parâmetro dt_ultima_sincronizacao, não foi informado.');


    try

     qry := TFDQuery.Create(nil);
     qry.Connection := conn;

        with qry do
        begin
          {
          Fazo select na tabela, e lista os produtos
          }
            Active := False;
            sql.Clear;
            SQL.Add('SELECT FIRST :FIRST SKIP :SKIP * '); //PARA TRATAR A PAGINAÇÃO
            SQL.Add('FROM TAB_PEDIDO');
            SQL.Add('WHERE DATA_ULT_ALTERACAO > :DATA_ULT_ALTERACAO');
            SQL.Add('AND COD_USUARIO = :COD_USUARIO');
            SQL.Add('ORDER BY COD_PEDIDO');

            ParamByName('DATA_ULT_ALTERACAO').Value := dt_ultima_sincronizacao;
            ParamByName('COD_USUARIO').Value := cod_usuario;

            //BANCO DE DADOS NEGOCIUS
         {   Active := False;
            sql.Clear;
            SQL.Add('SELECT FIRST :FIRST SKIP :SKIP * '); //TRATAR A PAGINAÇÃO
            SQL.Add('FROM T_PEDIDO ');
            SQL.Add('WHERE ISN_REPRESENTANTE = :ISN_REPRESENTANTE ');
     //       SQL.Add('AND PEDDT_PEDIDO = :PEDDT_PEDIDO ');
           // SQL.Add('PROD.PRODT_ALTERACAO > :PRODT_ALTERACAO');

            SQL.Add('ORDER BY PEDCN_PEDIDO');

            ParamByName('ISN_REPRESENTANTE').Value := cod_usuario;
      //      ParamByName('PEDDT_PEDIDO').Value := dt_ultima_sincronizacao;   }


            //TRATAR A PAGINAÇÃO
            ParamByName('FIRST').Value := QTD_DE_REG_PAGINA_PEDIDO; //Quantos registro quero trazer
            ParamByName('SKIP').Value := (pagina * QTD_DE_REG_PAGINA_PEDIDO) - QTD_DE_REG_PAGINA_PEDIDO;  //Quantos tenho que pular...
            {
            o calculo do salto de registro acima é a página atual x quantidade de registro que quero,
              menos a quanditade de registro que já possui
            }
           Active := True;
     end;

            {
            Looping para pegar cada um dos objetos do json
            pega o objeto de indice recebido ,com o pedidos[i]
            convertendo para um Objeto Json (as TJsonObject)
            ex:
            pedidos[i] as TJsonObject

            Adicionar um novo par no objeto recebido pelo índice,
            coloca-se a estrutura entre parenteses, e conseguirá acessar apropriedade
            AddPair.
            ex:

            (pedidos[i] as TjsonObject).AddPair

             Para adicionar um par basta colocar o par entre parenteses
             Ex:
             (pedidos[i]. as TJsonObjec).AddPair ('chave':'valor');

             Assim estará adicionado um novo par json ao objeto de indice capturado

            Como será inserido um novo array com os itens,
            farei uma função que como valor do par, será devolvido a função contendo o
            array com os itens do pedido.

            Exe:
            (pedidos[i] as TJsonbject).AddPair('item', função que devolverá o array com os itens);
           }
            pedidos := qry.ToJSONArray;

           for I := 0 to pedidos.Size - 1 do
           begin
                cod_pedido := pedidos[i].GetValue<integer>('cod_pedido', 0);
               // cod_pedido := pedidos[i].GetValue<integer>('isn_pedido', 0);  //negocius

               (pedidos[i] as TJsonObject).AddPair('item', ListarItensPedido(cod_pedido, qry)); //insere um par chamado itens
           end;

               //Essa qry, servirá para montar um array com os dados do pedido e os itens do pedido, ex:

// [
//          {
//             "cod_pedido": 123,
//             "isn_tipo_pedido": 2,  //Para o negocius
//             "cod_cliente": 50,
//             "itens": [
//                        {"cod_item": 1, "cod_produto": 100},
//                        {"cod_item": 2, "cod_produto": 150},
//                      ]
//          },
//          {
//             "cod_pedido": 124,
//             "isn_tipo_pedido": 2,  //Para o negocius
//             "cod_cliente": 15,
//             "itens": [
//                        {"cod_item": 4, "cod_produto": 100},
//                        {"cod_item": 5, "cod_produto": 150},
//                      ]
//          }
//
//  ]


        // Após, devolve  array objeto json com o resultado da query

           Result := pedidos;

    finally
         FreeAndNil(qry);
    end;
end;


//Insere ou edita o pedido
function TDmGlobal.InserirEditarPedido (cod_usuario, cod_pedido_local, cod_cliente ,
                                           cod_cond_pagto, cod_pedido_oficial: Integer;
                                           tipo_pedido, data_pedido, contato, obs,
                                           prazo_entrega, data_entrega  : string;
                                           dt_ult_sincronizacao : string;
                                           valor_total : Double;
                                           Itens: TJSONArray ) : TJSonObject;
 var
 qry : TFDQuery; // se fosse utilizar sem compnente em tempo de execução
 cod_ped_local : integer;
 i : Integer;
 Funcao : TFuncoes;
begin
    try
     qry := TFDQuery.Create(nil);
     qry.Connection := conn;

       try
          Conn.StartTransaction;

                with qry do
                begin
                    Active := False;
                    sql.Clear;

                    if cod_pedido_oficial = 0 then
                    begin

                      SQL.Add('INSERT INTO TAB_PEDIDO (COD_CLIENTE, COD_USUARIO, TIPO_PEDIDO, DATA_PEDIDO, CONTATO, OBS,');
                      SQL.Add(' VALOR_TOTAL, COD_COND_PAGTO, PRAZO_ENTREGA, DATA_ENTREGA, COD_PEDIDO_LOCAL, DATA_ULT_ALTERACAO)');
                      SQL.Add('VALUES (:COD_CLIENTE, :COD_USUARIO, :TIPO_PEDIDO, :DATA_PEDIDO, :CONTATO, :OBS,');
                      SQL.Add(' :VALOR_TOTAL, :COD_COND_PAGTO, :PRAZO_ENTREGA, :DATA_ENTREGA, :COD_PEDIDO_LOCAL, :DATA_ULT_ALTERACAO)');
                      SQL.Add('RETURNING COD_PEDIDO'); //não aceita alias

                      ParamByName('COD_USUARIO').Value := cod_usuario;
                      ParamByName('COD_PEDIDO_LOCAL').Value := cod_pedido_local;

                    end
                    else
                    begin
                      SQL.Add('UPDATE TAB_PEDIDO SET COD_CLIENTE =:COD_CLIENTE, TIPO_PEDIDO =:TIPO_PEDIDO, DATA_PEDIDO =:DATA_PEDIDO,');
                      SQL.Add('CONTATO = :CONTATO, OBS =:OBS , VALOR_TOTAL = :VALOR_TOTAL, COD_COND_PAGTO =:COD_COND_PAGTO,');
                      SQL.Add('PRAZO_ENTREGA =:PRAZO_ENTREGA, DATA_ENTREGA = :DATA_ENTREGA,');
                      SQL.Add('DATA_ULT_ALTERACAO =:DATA_ULT_ALTERACAO');
                      SQL.Add('WHERE COD_PEDIDO = :COD_PEDIDO');

                      SQL.Add('RETURNING COD_PEDIDO'); //não aceita alias
                      ParamByName('COD_PEDIDO').Value := cod_pedido_oficial;

                      ParamByName('COD_CLIENTE').Value := cod_cliente;
                      ParamByName('TIPO_PEDIDO').Value := tipo_pedido;
                      ParamByName('DATA_PEDIDO').Value := data_pedido;
                      ParamByName('CONTATO').Value := contato;
                      ParamByName('OBS').Value := obs;
                      ParamByName('VALOR_TOTAL').Value := valor_total;
                      ParamByName('COD_COND_PAGTO').Value := cod_cond_pagto;
                      ParamByName('PRAZO_ENTREGA').Value := prazo_entrega;

                      if data_entrega <> '' then
                       ParamByName('DATA_ENTREGA').Value := data_entrega
                      else
                      begin
                         ParamByName('DATA_ENTREGA').DataType := ftstring;
                         ParamByName('DATA_ENTREGA').Value := Unassigned;    //requer a system.variants na uses
                      End;
                      ParamByName('DATA_ULT_ALTERACAO').Value := data_entrega;
                    end;

                    Active := True;

                end;

                //  Monta um objeto json com o resultado da query
                      {"cod_usuario":123}

                 Result := qry.ToJSONObject;
                 cod_ped_local := qry.FieldByName('COD_PEDIDO').AsInteger;

                 //Itens do pedido------------------------------------------------
                with qry do
                begin
                    Active := False;
                    sql.Clear;

                      SQL.Add('DELETE FROM TAB_PEDIDO_ITEM WHERE COD_PEDIDO = :COD_PEDIDO');
                      ParamByName('COD_PEDIDO').Value := cod_pedido_oficial;
                      ExecSQL;

                     //Looping no array dos itens do pedido recebido do mobile
                    for I := 0 to Itens.Size - 1 do
                    begin
                     Active := False;
                     sql.Clear;

                     SQL.Add('INSERT INTO TAB_PEDIDO_ITEM(COD_PEDIDO, COD_PRODUTO, QTD, VALOR_UNITARIO, VALOR_TOTAL)');
                     SQL.Add('VALUES(:COD_PEDIDO, :COD_PRODUTO, :QTD, :VALOR_UNITARIO, :VALOR_TOTAL)');
                     ParamByName('COD_PEDIDO').Value  :=  cod_pedido_oficial;
                     ParamByName('COD_PRODUTO').Value  :=  Itens[i].GetValue<Integer>('cod_produto', 0);
                     ParamByName('QTD').Value  :=    Itens[i].GetValue<Double>('qtd', 0);
                     ParamByName('VALOR_UNITARIO').Value  := Itens[i].GetValue<Double>('valor_untario', 0);
                     ParamByName('VALOR_TOTAL').Value  :=  Itens[i].GetValue<Double>('valor_total', 0);
                     ExecSQL;
                     Itens.Remove(0); //para nao dar erro ao gravar os itens no banco de dados
                    end;
                 end;
                 Conn.Commit;

       except on ex:Exception do
         begin
            Conn.Rollback;
            raise Exception.Create(ex.Message);
         end;
       end;
    finally
         FreeAndNil(qry);
    end;
end;

//Lista As condições de pagamento
function TDmGlobal.ListarCondPagto : TJSONArray;
 var
 qry : TFDQuery; // se fosse utilizar sem compnente em tempo de execução
begin

    try

     qry := TFDQuery.Create(nil);
     qry.Connection := conn;

        with qry do
        begin
          {
          Fazo select na tabela, e lista as condições de pagamento
          }
           Active := False;
            sql.Clear;
            SQL.Add('SELECT COD_COND_PAGTO, COND_PAGTO');
            SQL.Add('FROM TAB_COND_PAGTO ');
            SQL.Add('WHERE IND_EXCLUIDO = ''N'' ');
            SQL.Add('ORDER BY COD_COND_PAGTO');

           Active := True;
        end;

        // Após, Monta um  array objeto json com o resultado da query
           Result := qry.ToJSONArray;

    finally
         FreeAndNil(qry);
    end;
end;



end.
