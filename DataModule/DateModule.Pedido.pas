unit DateModule.Pedido;

interface

uses
  uFuncoes,
  uFunctions,
  uMD5,

  Data.DB,
  Data.SqlExpr,

  DataSet.Serialize,
  DataSet.Serialize.Config,

  DateModule.BloqueioPedido,
  DateModule.Global,

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
  TExecuteOnPass = procedure of object;

  TDmPedido = class(TDataModule)
   private

    FCod_Cliente: Integer;
    Ftipo_pedido: String;
 //   FCod_pedido_local: Int64;
    FUsa_Palta: string;
    Fisn_forma_pagamento: Integer;
    Fdata_pedido: TDateTime;
    Fvalor_total: Double;
    Fisn_usuario_negocius: Integer;
    Fisn_empresa: integer;
    Fcod_usuario: integer;
    Fpedfg_palm: string;
    Fisn_bloqueio: Integer;
    Fcod_pedido_oficial: integer;
//    Fisn_pedido: integer;
    Fpedfg_virtual: string;
    Fpeddt_implantado: TDateTime;
    Fpedfg_pauta: string;
    Fpedfg_implantado: string;
    Fpednr_carga_manifesto: integer;
    Fobs: string;
    Feddt_inclusao: TDateTime;
    FExecuteOnPass: TExecuteOnPass;
    function ListarItensPedido(cod_pedido: Integer; Qry: TFDQuery): TJSONArray;
    procedure InserirItensDoPedido(isn_pedido: Integer; itens: TJSONArray;
                                         tipo_pedido: string ; cod_cliente,
                                         cod_usuario: Integer; desconto : double = 0.0);

  Public

       property Cod_Cliente: Integer read FCod_Cliente write FCod_Cliente; //1: //ISN_CLIENTE
       property tipo_pedido: String read Ftipo_pedido write Ftipo_pedido;    //7: //ISN_TIPO_PEDIDO
   //    property Cod_pedido_local: Int64  read FCod_pedido_local write FCod_pedido_local; //9: //ISN_PEDIDO_PALM
       property Usa_Palta: string read FUsa_Palta write FUsa_Palta;
       property isn_forma_pagamento: Integer read Fisn_forma_pagamento write Fisn_forma_pagamento; //2: //ISN_FORMA_PAGAMENTO    //15: //ISN_PRAZO
       property data_pedido: TDateTime read Fdata_pedido write Fdata_pedido; //3: //PEDDT_PEDIDO
       property valor_total : Double read Fvalor_total  write Fvalor_total ; //4: //PEDVL_TOTAL
       property isn_bloqueio: Integer read Fisn_bloqueio write Fisn_bloqueio; //5: //ISN_BLOQUEIO
      // property isn_pedido: integer read Fisn_pedido write Fisn_pedido;   //8: //ISN_PEDIDO
       property cod_pedido_oficial: integer read Fcod_pedido_oficial write Fcod_pedido_oficial;       //0: //PEDCN_PEDIDO
       property cod_usuario: integer read Fcod_usuario write Fcod_usuario;  //10: //ISN_REPRESENTANTE
       property pedfg_implantado: string read Fpedfg_implantado write Fpedfg_implantado;  //11: //PEDFG_IMPLANTANDO  //Colocar "S" apenas no final da importa��o para s� ent�o conseguir imprimir Chamado 23201 (Graves e Agudos)
       property peddt_inclusao: TDateTime read Feddt_inclusao write Feddt_inclusao;  //12: //PEDDT_INCLUSAO   QuotedStr(FormatDateTime('MM/DD/YYYY HH:MM:00', Now));
       property isn_usuario_negocius: Integer read Fisn_usuario_negocius write Fisn_usuario_negocius; //14: //ISN_USUARIO
      // property pedfg_palm : string read Fpedfg_palm  write pedfg_palm ;  //16: //PEDFG_PALM
       property pedfg_virtual: string read Fpedfg_virtual write Fpedfg_virtual;  //17: //PEDFG_VIRTUAL
       property isn_empresa: integer read Fisn_empresa write Fisn_empresa; //18: //ISN_EMPRESA
       property  pedfg_pauta: string read Fpedfg_pauta write Fpedfg_pauta;
       property  pednr_carga_manifesto: integer read Fpednr_carga_manifesto write Fpednr_carga_manifesto; //20: //PEDNR_CARGA_MANIFESTO
       property  obs: string read Fobs write Fobs;  //6: //PEDDS_OBSERVACAO

       property ExecuteOnPass: TExecuteOnPass read FExecuteOnPass write FExecuteOnPass;

       function InserirEditarPedido(cod_usuario: Integer; cod_pedido_local: Int64; cod_cliente ,
                                        cod_cond_pagto, forma_pagamento : integer; out cod_pedido_oficial: int64;
                                        tipo_pedido, data_pedido, contato, obs,
                                        prazo_entrega, data_entrega  : string;
                                        dt_ult_sincronizacao : string;
                                        valor_total : Double;
                                        itens: TJSONArray ) : TJSonObject;
       function ListarTipoPedido: TJsonArray;
       function ListarPedidos(dt_ultima_sincronizacao: String; cod_usuario,
                              pagina: Integer): TJSONArray;
       function ListarTipoDePedidoPrazo(pagina: Integer): TJSONArray;
  end;

var
   DmPedido: TDmPedido;
   IsnPedido : Integer;
implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}
//Insere ou edita o pedido
function TDmPedido.InserirEditarPedido (cod_usuario: Integer; cod_pedido_local: Int64; cod_cliente ,
                                        cod_cond_pagto, forma_pagamento : integer; out cod_pedido_oficial: int64;
                                        tipo_pedido, data_pedido, contato, obs,
                                        prazo_entrega, data_entrega  : string;
                                        dt_ult_sincronizacao : string;
                                        valor_total : Double;
                                        itens: TJSONArray ) : TJSonObject;
 var
 qry : TFDQuery; // se fosse utilizar sem compnente em tempo de execu��o
 cod_ped_local : integer;
 cod_pedido_oficial_isn : Integer;
 i,seq_item : Integer;
 Funcao : TFuncoes;
 DmGlobal : TDmGlobal;
 desconto : Double;
begin

    try
     DmGlobal := TDmGlobal.Create(nil);
     qry := TFDQuery.Create(nil);
     qry.Connection := DmGlobal.Conn;

      qry.Active := False;
      qry.SQL.Clear;
      try
       DmGlobal.Conn.StartTransaction;

       qry.SQL.Add(' INSERT INTO T_PEDIDO ( PEDCN_PEDIDO, ISN_CLIENTE, ISN_FORMA_PAGAMENTO, PEDDT_PEDIDO, PEDVL_TOTAL, ISN_BLOQUEIO,');
       qry.SQL.Add(' PEDDS_OBSERVACAO, ISN_TIPO_PEDIDO, ISN_PEDIDO, ISN_PEDIDO_FASTPED, ISN_REPRESENTANTE,' );
       qry.SQL.Add(' PEDFG_IMPLANTADO, PEDDT_INCLUSAO, ISN_CFOP, ISN_USUARIO, ISN_PRAZO, PEDFG_PALM, PEDFG_VIRTUAL, ') ;
       qry.SQL.Add(' ISN_EMPRESA, PEDFG_PAUTA, PEDNR_CARGA_MANIFESTO, PEDPR_DESC, PEDVL_TAXA_CLIENTE) ') ;


       qry.SQL.Add(' VALUES ( :PEDCN_PEDIDO, :ISN_CLIENTE, :ISN_FORMA_PAGAMENTO, :PEDDT_PEDIDO, :PEDVL_TOTAL, :ISN_BLOQUEIO,');
       qry.SQL.Add(' :PEDDS_OBSERVACAO, :ISN_TIPO_PEDIDO, :ISN_PEDIDO, :ISN_PEDIDO_FASTPED, :ISN_REPRESENTANTE,' );
       qry.SQL.Add(' :PEDFG_IMPLANTADO,:PEDDT_INCLUSAO,  :ISN_CFOP, :ISN_USUARIO, :ISN_PRAZO, :PEDFG_PALM, :PEDFG_VIRTUAL, ') ;
       qry.SQL.Add(' :ISN_EMPRESA, :PEDFG_PAUTA, :PEDNR_CARGA_MANIFESTO, :PEDPR_DESC, :PEDVL_TAXA_CLIENTE) ') ;
       qry.SQL.Add('RETURNING PEDCN_PEDIDO');    //n�o aceita alias

       qry.ParamByName('PEDCN_PEDIDO').Value := Funcao.NovoISN('T_PEDIDO',true);   //Gera numero pedido oficial

       qry.ParamByName('ISN_PEDIDO').Value := Funcao.NovoISN('T_PEDIDO').ToInteger;

       IsnPedido :=  qry.ParamByName('ISN_PEDIDO').Value;

       qry.ParamByName('ISN_CLIENTE').Value := cod_cliente;    //ISN_CLIENTE

       qry.ParamByName('ISN_FORMA_PAGAMENTO').Value := forma_pagamento; //

       qry.ParamByName('PEDDT_PEDIDO').AsDateTime := convertedata(data_pedido);      //data pedido

       if  DmBloqueioPedido.PedidoBloqueado(cod_cliente,tipo_pedido, valor_total ) = 0 then
        qry.ParamByName('ISN_BLOQUEIO').Value := Null
       else
       qry.ParamByName('ISN_BLOQUEIO').Value := DmBloqueioPedido.PedidoBloqueado(cod_cliente,tipo_pedido, valor_total );

       qry.ParamByName('PEDDS_OBSERVACAO').Value := obs;  //Observa��o do pedido

       qry.ParamByName('ISN_TIPO_PEDIDO').Value := tipo_pedido;  //Tipo do pedido deve ser numero, para buscar o cfop

       qry.ParamByName('ISN_PEDIDO_FASTPED').Value := cod_pedido_local; //cod pedido local  fastped

       qry.ParamByName('ISN_REPRESENTANTE').Value := cod_usuario; //REPRESENTANTE

       qry.ParamByName('PEDFG_IMPLANTADO').Value := 'S';   //IMPLANTADO QUANDO � DO PALM

       qry.ParamByName('PEDDT_INCLUSAO').AsDateTime := converteData(DateTimeToStr(now));  //DATA DE ENTRADA NO SISTEMA

       qry.ParamByName('ISN_CFOP').Value := Funcao.ConsultaCFOP(tipo_pedido); //Isn_cfop

       qry.ParamByName('ISN_USUARIO').Value := 99999; //codigo do usuario ser� o mesmo do representante.

       qry.ParamByName('ISN_PRAZO').Value := cod_cond_pagto; //  � O ISN PRAZO da T_PRAZO

       qry.ParamByName('PEDFG_PALM').Value := 'S'; // IDENTIFICA SE O PEDIDO FOI DO PALM

       qry.ParamByName('PEDFG_VIRTUAL').Value := 'N';  //NO BANCO � NULL

       qry.ParamByName('ISN_EMPRESA').Value := 1;

       qry.ParamByName('PEDFG_PAUTA').Value := Funcao.Cli_Usa_Palta(cod_cliente);//Identifica se o cliente Usa Pauta

       qry.ParamByName('PEDNR_CARGA_MANIFESTO').clear; //NO BANCO � NULL

       qry.ParamByName('PEDPR_DESC').Value := Funcao.PercentualDescPrazo(cod_cond_pagto);

       if qry.ParamByName('PEDPR_DESC').AsInteger > 0 then
        begin
          qry.ParamByName('PEDVL_TOTAL').Value := valor_total * ( 1 - (qry.ParamByName('PEDPR_DESC').Value / 100));
          desconto := qry.ParamByName('PEDPR_DESC').AsInteger;
        end
       else
       begin
         desconto := 0;
         qry.ParamByName('PEDVL_TOTAL').Value := valor_total;      //valor total pedido
       end;

       qry.ParamByName('PEDVL_TAXA_CLIENTE').clear;


         qry.Active := True;
         DmGlobal.Conn.Commit;

        InserirItensDoPedido(IsnPedido, itens, tipo_pedido, cod_cliente, cod_usuario, desconto);
       except on ex:Exception do
       begin
         DmGlobal.Conn.Rollback;
         raise Exception.Create(ex.Message);
       end;
      end;

          //  Monta um objeto json com o resultado da query
          {"cod_usuario":123}

      Result := qry.ToJSONObject;
      cod_ped_local := qry.FieldByName('PEDCN_PEDIDO').AsInteger;
      cod_pedido_oficial := cod_ped_local;

    finally
         FreeAndNil(qry);
         FreeAndNil(DmGlobal);
    end;
end;

procedure TDmPedido.InserirItensDoPedido(isn_pedido: Integer; itens: TJSONArray;
                                         tipo_pedido: string ; cod_cliente,
                                         cod_usuario: Integer; desconto : double = 0.0);

 {Leia essa instru��o abaixo}
///  Essa estrutura de c�digo � um loop que executa enquanto
///  o tamanho do array "Itens" for diferente de zero. Dentro desse
///  loop, um loop for � executado para iterar sobre cada elemento do array.
///  Dentro do loop for, h� um conjunto de
///  instru��es que s�o executadas em cada itera��o,
///  mas o c�digo real n�o est� presente no exemplo.
///  Ap�s o loop for, o primeiro item do array "Itens"
///  � removido usando o m�todo "Remove" com um �ndice de 0, o que
///  significa que o primeiro elemento � removido.
///  Depois de remover o primeiro item do array,
///  o loop while continua e o processo se repete at� que todos os itens tenham
///  sido removidos do array "Itens". Esse tipo de loop �
///  comum em situa��es em que um conjunto de instru��es precisa ser
///  executado para cada item de uma lista ou array,
///  e o processamento deve continuar
///  at� que todos os itens tenham sido processados.
///
///  O erro no c�digo � o LOOP WHILE NOT ITENS.SIZE = 0 DO
///   n�o tem um comando  para remover um item do array Itens.
///  Isso faz com que o loop fique em um loop infinito,
///  j� que Itens.Size nunca muda e, portanto,
///  a condi��o de sa�da do loop nunca � atendida.
///
///  Para que funcione de forma correta
///  � necess�rio adicionar um comando dentro do loop para remover o
///  item atual do array Itens. Uma poss�vel solu��o
///  � utilizar o m�todo REMOVE do
///  TJSONArray, como mostrado abaixo:
///
///  while not Itens.Size = 0 do
///  begin
///  for I := 0 to  Itens.Size - 1 do
///   begin
///       Instrun��es
///   end;
///   Itens.Remove(0);  Remove o primeiro item do array Itens dando fim ao loop
///  end;
 var
 qry: TFDQuery; // se fosse utilizar sem compnente em tempo de execu��o
 cod_pedido_oficial_isn : Integer;
 i,seq_item : Integer;
 Funcao : TFuncoes;
 lDmGlobal : TDmGlobal;
 Transacao : TFDTransaction;
 Cod_pedido : Integer;
 ITENSSTRING : STRING;
begin
       lDmGlobal := TDmGlobal.Create(nil);
       qry := TFDQuery.Create(nil);
       qry.Connection := lDmGlobal.Conn;
       cod_pedido_oficial_isn := IsnPedido;

    try

       Transacao := TFDTransaction.Create(nil);
       Transacao.Connection := lDmGlobal.Conn;

       ITENSSTRING := itens.ToString;

       try
        Transacao.StartTransaction;

         //Itens do pedido------------------------------------------------

           for I := 0 to itens.Size - 1 do
           begin
               Cod_pedido := cod_pedido_oficial_isn;

               qry.Active := False;
               qry.sql.Clear;

                qry.SQL.Add('INSERT INTO T_ITEM_PEDIDO (ISN_PEDIDO, ISN_PRODUTO,');
                qry.SQL.Add('IPEQT_QUANTIDADE, IPEQT_QUANTIDADE_PALM, IPEVL_UNITARIO, ');
                qry.SQL.Add('IPEVL_UNITARIO_PALM, ISN_ITEM_PEDIDO, IPENR_SEQUENCIAL, IPEPR_DESCPED, ');
                qry.SQL.Add('IPEVL_DESCONTO, IPEVL_ACRESCIMO, IPEVL_PRE_DIG, ISN_UNIDADE_VENDA, ');
                qry.SQL.Add('IPEVL_CUSTO_FINAL, IPEQT_UNIDADE_VENDA, ISN_CFOP, IPEVL_ULT_PRE, ');
                qry.SQL.Add('IPEVL_PRECO_TABELA, IPEFG_FATURA, IPEPR_DESCONTO, IPENR_PRECO, ISN_EMPRESA)');

                qry.SQL.Add('VALUES (:ISN_PEDIDO, :ISN_PRODUTO,');
                qry.SQL.Add(':IPEQT_QUANTIDADE, :IPEQT_QUANTIDADE_PALM, :IPEVL_UNITARIO, ');
                qry.SQL.Add(':IPEVL_UNITARIO_PALM, :ISN_ITEM_PEDIDO, :IPENR_SEQUENCIAL, :IPEPR_DESCPED, ');
                qry.SQL.Add(':IPEVL_DESCONTO, :IPEVL_ACRESCIMO, :IPEVL_PRE_DIG, :ISN_UNIDADE_VENDA, ');
                qry.SQL.Add(':IPEVL_CUSTO_FINAL, :IPEQT_UNIDADE_VENDA, :ISN_CFOP, :IPEVL_ULT_PRE, ');
                qry.SQL.Add(':IPEVL_PRECO_TABELA, :IPEFG_FATURA, :IPEPR_DESCONTO, :IPENR_PRECO, :ISN_EMPRESA)');

                qry.ParamByName('ISN_PEDIDO').Value  := cod_pedido;

                qry.ParamByName('ISN_PRODUTO').Value  :=  Itens[i].GetValue<Integer>('cod_produto', 0);

                qry.ParamByName('IPEQT_QUANTIDADE').Value  :=    Itens[i].GetValue<Double>('quantidade', 0);    //

                qry.ParamByName('IPEQT_QUANTIDADE_PALM').Value  :=  Itens[i].GetValue<Double>('quantidade', 0);

                if (desconto > 0) and (Itens[i].GetValue<Double>('prec_digitado') = 0) then
                 qry.ParamByName('IPEVL_PRE_DIG').Value  := Itens[i].GetValue<Double>('valor_unitario', 0) * (1 - (desconto / 100))
                else
                begin
                 qry.ParamByName('IPEVL_PRE_DIG').Value  :=  Itens[i].GetValue<Double>('prec_digitado', 0);
                end;

                qry.ParamByName('IPEVL_UNITARIO').Value  := Itens[i].GetValue<Double>('valor_unitario', 0);

                qry.ParamByName('IPEVL_UNITARIO_PALM').Value  :=  Itens[i].GetValue<Double>('valor_unitario', 0);

                qry.ParamByName('ISN_ITEM_PEDIDO').Value  :=  Funcao.NovoISN('T_ITEM_PEDIDO');

                qry.ParamByName('IPENR_SEQUENCIAL').Value  :=   Itens[i].GetValue<integer>('seq_item');//Funcao.ProxSeq(IsnPedido);//; //SEQUENCIAL DO PEDO ITEM NO PEDIDO

                qry.ParamByName('IPEVL_DESCONTO').Value  := Funcao.Desconto(Itens[i].GetValue<Double>('valor_unitario', 0),
                                                                        Itens[i].GetValue<Double>('prec_digitado', 0));   //VALOR DO DESCONTO

                qry.ParamByName('IPEPR_DESCPED').Value  := qry.ParamByName('IPEVL_DESCONTO').Value; // ( Itens[i].GetValue<Double>('prec_digitado', 0) / ( 1 - 1.10));

                qry.ParamByName('IPEVL_ACRESCIMO').Value  :=  Funcao.Acrescimo(Itens[i].GetValue<Double>('prec_digitado', 0),
                                                                           Itens[i].GetValue<Double>('valor_unitario', 0));  //VALOR ACR�SCIMO

                qry.ParamByName('ISN_UNIDADE_VENDA').Value  :=  Funcao.isn_und_vend_prod(Itens[i].GetValue<Integer>('cod_produto', 0));

                qry.ParamByName('IPEVL_CUSTO_FINAL').Value  :=  Funcao.custo_final_produto(Itens[i].GetValue<Integer>('cod_produto', 0));

                qry.ParamByName('IPEQT_UNIDADE_VENDA').Value  :=  Funcao.unidade_venda_produto(Itens[i].GetValue<Integer>('cod_produto', 0));

                qry.ParamByName('ISN_CFOP').Value  :=  Funcao.ConsultaCFOP(tipo_pedido); //Isn_cfop;

                qry.ParamByName('IPEVL_ULT_PRE').Value  :=  0; // Est� zerado no codigo da SB

                qry.ParamByName('IPEVL_PRECO_TABELA').Value  :=   qry.ParamByName('IPEVL_UNITARIO').Value; // VERIFICAR SE REALMENTE O PRECO � O PRECO DE TABELA

                qry.ParamByName('IPEFG_FATURA').Value  :=  'S'; // EST� S NO CODIGO FONT SOBBUILDER

                qry.ParamByName('IPEPR_DESCONTO').Value  :=  Null;

                qry.ParamByName('IPENR_PRECO').Value  :=  Funcao.ConsultaNumeroPreco(cod_cliente, cod_usuario);  //NUMERO DO PRECO

                qry.ParamByName('ISN_EMPRESA').Value  :=  1;

                Funcao.Reserva_Estoque(Itens[i].GetValue<Integer>('cod_produto', 0),
                                       Itens[i].GetValue<Double>('quantidade', 0)
                                       );

        //   Itens.Remove(0); // Remove o primeiro item do array Itens, para evitar o looping infinito    -- > SOMENTE PARA INSTRUN��ES WHILE
           qry.ExecSQL;
          end;

          Transacao.Commit;
       except
          Transacao.Rollback;
       end;

    finally
      Transacao.Free;
      FreeAndNil(qry);
      FreeAndNil(lDmGlobal);
    end;
end;


function TDmPedido.ListarTipoPedido : TJsonArray;
var
 qry : TFDQuery;
 lDmGlobal : TDmGlobal;

begin
    try
         try
           lDmGlobal := TDmGlobal.Create(nil);
           qry := TFDQuery.Create(nil);
           qry.Connection := lDmGlobal.Conn;

           qry.Active := False;
           qry.SQL.Clear;
           qry.SQL.Add('SELECT');
           qry.SQL.Add('ISN_TIPO_PEDIDO COD_TIPO,');
           qry.SQL.Add('TIPDS_TIPO DESCRICAO,');
           qry.SQL.Add('IND_SINC');
           qry.SQL.Add('FROM T_TIPO_PEDIDO');
           qry.SQL.Add('WHERE TIPFG_EXPORTA_PALM = ''S''');
           qry.Active := True;

         except on ex: Exception do
            raise Exception.Create(ex.Message);
         end;

         Result := qry.ToJSONArray();
    finally
       FreeAndNil(qry);
       FreeAndNil(lDmGlobal);
    end;


end;

//Lista os itens do pedido
//passo como parametro a qry do listar pedidos
function TDmPedido.ListarItensPedido(cod_pedido : Integer;
                                     Qry: TFDQuery) : TJSONArray;
 begin
      with qry do
      begin

        //  Fazo select na tabela, e lista os itens

            Active := False;
            sql.Clear;
            SQL.Add('SELECT COD_ITEM, COD_PRODUTO, QTD, VALOR_UNITARIO, VALOR_TOTAL '); //PARA TRATAR A PAGINA��O
            SQL.Add('FROM TAB_PEDIDO_ITEM');
            SQL.Add('WHERE COD_PEDIDO = :COD_PEDIDO');
            SQL.Add('ORDER BY COD_ITEM');

            ParamByName('COD_PEDIDO').Value := cod_pedido;

           Active := True;

      end;

      //Converte o resultado do sql para um array json.
      Result := qry.ToJSONArray;  //Devolver� para a fun��o Listar pedidos para o Paradicionado ( item )
 end;

//Lista pedidos
function TDmPedido.ListarPedidos(dt_ultima_sincronizacao : String;
                                 cod_usuario, pagina: Integer) : TJSONArray;
 var
 pedidos : TJSONArray;
 cod_pedido : Integer;
 i : Integer;
 qry : TFDQuery;
 DmGlobal : TDmGlobal;
begin
    if dt_ultima_sincronizacao.IsEmpty then
    raise Exception.Create('O par�metro dt_ultima_sincronizacao, n�o foi informado.');


    try
     DmGlobal := TDmGlobal.Create(nil);
     qry := TFDQuery.Create(nil);
     qry.Connection := DmGlobal.conn;

     with qry do
     begin
          {
          Fazo select na tabela, e lista os produtos
          }
            Active := False;
            sql.Clear;
            SQL.Add('SELECT FIRST :FIRST SKIP :SKIP * '); //PARA TRATAR A PAGINA��O
            SQL.Add('FROM TAB_PEDIDO');
            SQL.Add('WHERE DATA_ULT_ALTERACAO > :DATA_ULT_ALTERACAO');
            SQL.Add('AND COD_USUARIO = :COD_USUARIO');
            SQL.Add('ORDER BY COD_PEDIDO');

            ParamByName('DATA_ULT_ALTERACAO').Value := dt_ultima_sincronizacao;
            ParamByName('COD_USUARIO').Value := cod_usuario;

            //BANCO DE DADOS NEGOCIUS
         {   Active := False;
            sql.Clear;
            SQL.Add('SELECT FIRST :FIRST SKIP :SKIP * '); //TRATAR A PAGINA��O
            SQL.Add('FROM T_PEDIDO ');
            SQL.Add('WHERE ISN_REPRESENTANTE = :ISN_REPRESENTANTE ');
     //       SQL.Add('AND PEDDT_PEDIDO = :PEDDT_PEDIDO ');
           // SQL.Add('PROD.PRODT_ALTERACAO > :PRODT_ALTERACAO');

            SQL.Add('ORDER BY PEDCN_PEDIDO');

            ParamByName('ISN_REPRESENTANTE').Value := cod_usuario;
      //      ParamByName('PEDDT_PEDIDO').Value := dt_ultima_sincronizacao;   }


            //TRATAR A PAGINA��O
            ParamByName('FIRST').Value := QTD_DE_REG_PAGINA_PEDIDO; //Quantos registro quero trazer
            ParamByName('SKIP').Value := (pagina * QTD_DE_REG_PAGINA_PEDIDO) - QTD_DE_REG_PAGINA_PEDIDO;  //Quantos tenho que pular...
            {
            o calculo do salto de registro acima � a p�gina atual x quantidade de registro que quero,
              menos a quanditade de registro que j� possui
            }
           Active := True;
     end;

            {
            Looping para pegar cada um dos objetos do json
            pega o objeto de indice recebido ,com o pedidos[i]
            convertendo para um Objeto Json (as TJsonObject)
            ex:
            pedidos[i] as TJsonObject

            Adicionar um novo par no objeto recebido pelo �ndice,
            coloca-se a estrutura entre parenteses, e conseguir� acessar apropriedade
            AddPair.
            ex:

            (pedidos[i] as TjsonObject).AddPair

             Para adicionar um par basta colocar o par entre parenteses
             Ex:
             (pedidos[i]. as TJsonObjec).AddPair ('chave':'valor');

             Assim estar� adicionado um novo par json ao objeto de indice capturado

            Como ser� inserido um novo array com os itens,
            farei uma fun��o que como valor do par, ser� devolvido a fun��o contendo o
            array com os itens do pedido.

            Exe:
            (pedidos[i] as TJsonbject).AddPair('item', fun��o que devolver� o array com os itens);
           }
            pedidos := qry.ToJSONArray;

           for I := 0 to pedidos.Size - 1 do
           begin
                cod_pedido := pedidos[i].GetValue<integer>('cod_pedido', 0);
               // cod_pedido := pedidos[i].GetValue<integer>('isn_pedido', 0);  //negocius

               (pedidos[i] as TJsonObject).AddPair('item', ListarItensPedido(cod_pedido, qry)); //insere um par chamado itens
           end;

               //Essa qry, servir� para montar um array com os dados do pedido e os itens do pedido, ex:

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


        // Ap�s, devolve  array objeto json com o resultado da query

           Result := pedidos;

    finally
         FreeAndNil(qry);
         FreeAndNil(DmGlobal);
    end;
end;

function TDmPedido.ListarTipoDePedidoPrazo(pagina : Integer): TJSONArray;
var
 qry : TFDQuery; // se fosse utilizar sem compnente em tempo de execu��o
 cod_ped_local : integer;
 i,seq_item : Integer;
 Funcao : TFuncoes;
 DmGlobal : TDmGlobal;
    teste : string;  //apagar
begin
  try
      DmGlobal := TDmGlobal.Create(nil);
      qry := TFDQuery.Create(nil);
      qry.Connection := DmGlobal.Conn;

      qry.Active := False;
      qry.SQL.Clear;
      qry.SQL.Add(' SELECT  FIRST :FIRST SKIP :SKIP * FROM ( ');
      qry.SQL.Add(' SELECT TPP.ISN_TIPO_PEDIDO COD_TIPO_PEDIDO, TPP.ISN_PRAZO COD_PRAZO');
      qry.SQL.Add(' FROM T_TIPO_PEDIDO_PRAZO TPP ');
      qry.SQL.Add(' JOIN T_TIPO_PEDIDO TP ON (TP.ISN_TIPO_PEDIDO = TPP.ISN_TIPO_PEDIDO) ');
      qry.SQL.Add(' JOIN T_PRAZO TPZ ON (TPZ.ISN_PRAZO = TPP.ISN_PRAZO) ');
      qry.SQL.Add(' WHERE TP.TIPFG_EXPORTA_PALM = ''S'' ');
      qry.SQL.Add(' AND TPZ.PRAFG_EXP_PALM = ''S'' ');
      qry.SQL.Add(' AND TPZ.PRAFG_INATIVO = ''N''  )');

       //TRATAR A PAGINA��O
      qry.ParamByName('FIRST').Value := QTD_DE_REG_PAGINA_PED_FORMA_PAGTO ; //Quantos registro quero trazer
      qry.ParamByName('SKIP').Value := (pagina * QTD_DE_REG_PAGINA_PED_FORMA_PAGTO) - QTD_DE_REG_PAGINA_PED_FORMA_PAGTO;  //Quantos tenho que pular...
       {
            o calculo do salto de registro acima � a p�gina atual x quantidade de registro que quero,
              menos a quanditade de registro que j� possui
       }
      qry.Active := True;

      Result := qry.ToJSONArray();

  finally
     FreeAndNil(qry);
     FreeAndNil(DmGlobal);
  end;

end;
end.
