unit uPedido;

{
  O DmGlobal, foi retirardo do auto criate, pois quando a requisição chegar, ele será criado
  executará a rotina, devolverá os dados e será destruído, e recriado sempre que for requisitado
  Utilizarei o conceito de statless
 }

interface
  uses
  System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, System.SysUtils,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.DApt,
  FireDAC.Phys.IBBase, system.IniFiles,DataSet.Serialize,DataSet.Serialize.Config,
  System.JSON, uMD5, FMX.Graphics, System.Variants, FireDAC.VCLUI.Wait, uFuncoes, DateModule.Global;

type
  TExecuteOnPass = procedure of object;

  TPedidoNegocius = class

  private

    FCod_Cliente: Integer;
    Ftipo_pedido: String;
    FCod_pedido_local: Int64;
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



  Public

       property Cod_Cliente: Integer read FCod_Cliente write FCod_Cliente; //1: //ISN_CLIENTE
       property tipo_pedido: String read Ftipo_pedido write Ftipo_pedido;    //7: //ISN_TIPO_PEDIDO
       property Cod_pedido_local: Int64  read FCod_pedido_local write FCod_pedido_local; //9: //ISN_PEDIDO_PALM
       property Usa_Palta: string read FUsa_Palta write FUsa_Palta;
       property isn_forma_pagamento: Integer read Fisn_forma_pagamento write Fisn_forma_pagamento; //2: //ISN_FORMA_PAGAMENTO    //15: //ISN_PRAZO
       property data_pedido: TDateTime read Fdata_pedido write Fdata_pedido; //3: //PEDDT_PEDIDO
       property valor_total : Double read Fvalor_total  write Fvalor_total ; //4: //PEDVL_TOTAL
       property isn_bloqueio: Integer read Fisn_bloqueio write Fisn_bloqueio; //5: //ISN_BLOQUEIO
      // property isn_pedido: integer read Fisn_pedido write Fisn_pedido;   //8: //ISN_PEDIDO
       property cod_pedido_oficial: integer read Fcod_pedido_oficial write Fcod_pedido_oficial;       //0: //PEDCN_PEDIDO
       property cod_usuario: integer read Fcod_usuario write Fcod_usuario;  //10: //ISN_REPRESENTANTE
       property pedfg_implantado: string read Fpedfg_implantado write Fpedfg_implantado;  //11: //PEDFG_IMPLANTANDO  //Colocar "S" apenas no final da importação para só então conseguir imprimir Chamado 23201 (Graves e Agudos)
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
                                           cod_cond_pagto, forma_pagamento, cod_pedido_oficial: Integer;
                                           tipo_pedido, data_pedido, contato, obs,
                                           prazo_entrega, data_entrega  : string;
                                           dt_ult_sincronizacao : string;
                                           valor_total : Double;
                                           Itens: TJSONArray ) : TJSonObject;
  end;

 var
  PedidoNegocius: TPedidoNegocius;

  IsnPedido : Integer;
implementation



//Insere ou edita o pedido
function TPedidoNegocius.InserirEditarPedido (cod_usuario: Integer; cod_pedido_local: Int64; cod_cliente ,
                                             cod_cond_pagto, forma_pagamento, cod_pedido_oficial: Integer;
                                             tipo_pedido, data_pedido, contato, obs,
                                             prazo_entrega, data_entrega  : string;
                                             dt_ult_sincronizacao : string;
                                             valor_total : Double;
                                             itens: TJSONArray ) : TJSonObject;
 var
 qry : TFDQuery; // se fosse utilizar sem compnente em tempo de execução
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


       try
          DmGlobal.Conn.StartTransaction;

                with qry do
                begin
                    Active := False;
                    sql.Clear;

                    if cod_pedido_oficial = 0 then
                    begin

                     SQL.Add(' INSERT INTO T_PEDIDO ( PEDCN_PEDIDO, ISN_CLIENTE, ISN_FORMA_PAGAMENTO, PEDDT_PEDIDO, PEDVL_TOTAL, ISN_BLOQUEIO,');
                     SQL.Add(' PEDDS_OBSERVACAO, ISN_TIPO_PEDIDO, ISN_PEDIDO, ISN_PEDIDO_FASTPED, ISN_REPRESENTANTE,' );
                     SQL.Add(' PEDFG_IMPLANTADO, PEDDT_INCLUSAO, ISN_CFOP, ISN_USUARIO, ISN_PRAZO, PEDFG_PALM, PEDFG_VIRTUAL, ') ;
                     SQL.Add(' ISN_EMPRESA, PEDFG_PAUTA, PEDNR_CARGA_MANIFESTO, PEDPR_DESC, PEDVL_TAXA_CLIENTE) ') ;


                     SQL.Add(' VALUES ( :PEDCN_PEDIDO, :ISN_CLIENTE, :ISN_FORMA_PAGAMENTO, :PEDDT_PEDIDO, :PEDVL_TOTAL, :ISN_BLOQUEIO,');
                     SQL.Add(' :PEDDS_OBSERVACAO, :ISN_TIPO_PEDIDO, :ISN_PEDIDO, :ISN_PEDIDO_FASTPED, :ISN_REPRESENTANTE,' );
                     SQL.Add(' :PEDFG_IMPLANTADO,:PEDDT_INCLUSAO,  :ISN_CFOP, :ISN_USUARIO, :ISN_PRAZO, :PEDFG_PALM, :PEDFG_VIRTUAL, ') ;
                     SQL.Add(' :ISN_EMPRESA, :PEDFG_PAUTA, :PEDNR_CARGA_MANIFESTO, :PEDPR_DESC, :PEDVL_TAXA_CLIENTE) ') ;
                     SQL.Add('RETURNING PEDCN_PEDIDO');    //não aceita alias

                      ParamByName('PEDCN_PEDIDO').Value := Funcao.NovoISN('T_PEDIDO',true);   //Gera numero pedido oficial

                      ParamByName('ISN_PEDIDO').Value := Funcao.NovoISN('T_PEDIDO');

                      IsnPedido :=    ParamByName('ISN_PEDIDO').Value;

                      ParamByName('ISN_CLIENTE').Value := cod_cliente;    //ISN_CLIENTE

                      ParamByName('ISN_FORMA_PAGAMENTO').Value := forma_pagamento; //

                      ParamByName('PEDDT_PEDIDO').Value := data_pedido;      //data pedido

                      ParamByName('PEDVL_TOTAL').Value := valor_total;      //valor total pedido

                      ParamByName('ISN_BLOQUEIO').Value := NULL ;//Funcao.PedidoBloqueado(cod_cliente.ToString, tipo_pedido);

                      ParamByName('PEDDS_OBSERVACAO').Value := obs;  //Observação do pedido

                      ParamByName('ISN_TIPO_PEDIDO').Value := tipo_pedido;  //Tipo do pedido deve ser numero, para buscar o cfop

                      ParamByName('ISN_PEDIDO_FASTPED').Value := cod_pedido_local; //cod pedido local  fastped

                      ParamByName('ISN_REPRESENTANTE').Value := 306; //cod_usuario; //REPRESENTANTE

                      ParamByName('PEDFG_IMPLANTADO').Value := 'S';   //IMPLANTADO QUANDO É DO PALM

                      ParamByName('PEDDT_INCLUSAO').Value := '2022-12-14 10:00';//Formatdatetime('DD/MM/YYY HH:MM', Funcao.StringToDate(DateToStr(now)));// QuotedStr(FormatDateTime('YYYY/MM/DD ', Now));   //DATA DE ENTRADA NO SISTEMA

                      ParamByName('ISN_CFOP').Value := Funcao.ConsultaCFOP(tipo_pedido); //Isn_cfop

                      ParamByName('ISN_USUARIO').Value := 99999; //codigo do usuario será o mesmo do representante.

                      ParamByName('ISN_PRAZO').Value := cod_cond_pagto; //  É O ISN PRAZO da T_PRAZO

                      ParamByName('PEDFG_PALM').Value := 'S'; // IDENTIFICA SE O PEDIDO FOI DO PALM

                      ParamByName('PEDFG_VIRTUAL').Value := 'N';  //NO BANCO É NULL

                      ParamByName('ISN_EMPRESA').Value := 1;

                      ParamByName('PEDFG_PAUTA').Value := Funcao.Cli_Usa_Palta(cod_cliente);//Identifica se o cliente Usa Pauta

                      ParamByName('PEDNR_CARGA_MANIFESTO').Value := NULL;  //NO BANCO É NULL

                      ParamByName('PEDPR_DESC').Value := Funcao.PercentualDescPrazo(cod_cond_pagto); //10;

                      ParamByName('PEDVL_TAXA_CLIENTE').Value := NULL;

               //        Funcao.BloqueioPedValorMinimo(IsnPedido);

                      Active := true;

                    end  ;

                //  Monta um objeto json com o resultado da query
                      {"cod_usuario":123}

                 Result := qry.ToJSONObject;
                 cod_ped_local := qry.FieldByName('PEDCN_PEDIDO').AsInteger;

                 //Itens do pedido------------------------------------------------
                  with qry do
                  begin
                     Active := False;
                     sql.Clear;

                     //Looping no array dos itens do pedido recebido do mobile
                    for I := 0 to Itens.Size - 1 do
                    begin
                     Active := False;
                     sql.Clear;

                     seq_item := seq_item + 1;

                     SQL.Add('INSERT INTO T_ITEM_PEDIDO (ISN_PEDIDO, ISN_PRODUTO,');
                     SQL.Add('IPEQT_QUANTIDADE, IPEQT_QUANTIDADE_PALM, IPEVL_UNITARIO, ');
                     SQL.Add('IPEVL_UNITARIO_PALM, ISN_ITEM_PEDIDO, IPENR_SEQUENCIAL, IPEPR_DESCPED, ');
                     SQL.Add('IPEVL_DESCONTO, IPEVL_ACRESCIMO, IPEVL_PRE_DIG, ISN_UNIDADE_VENDA, ');
                     SQL.Add('IPEVL_CUSTO_FINAL, IPEQT_UNIDADE_VENDA, ISN_CFOP, IPEVL_ULT_PRE, ');
                     SQL.Add('IPEVL_PRECO_TABELA, IPEFG_FATURA, IPEPR_DESCONTO, IPENR_PRECO, ISN_EMPRESA)');

                     SQL.Add('VALUES (:ISN_PEDIDO, :ISN_PRODUTO,');
                     SQL.Add(':IPEQT_QUANTIDADE, :IPEQT_QUANTIDADE_PALM, :IPEVL_UNITARIO, ');
                     SQL.Add(':IPEVL_UNITARIO_PALM, :ISN_ITEM_PEDIDO, :IPENR_SEQUENCIAL, :IPEPR_DESCPED, ');
                     SQL.Add(':IPEVL_DESCONTO, :IPEVL_ACRESCIMO, :IPEVL_PRE_DIG, :ISN_UNIDADE_VENDA, ');
                     SQL.Add(':IPEVL_CUSTO_FINAL, :IPEQT_UNIDADE_VENDA, :ISN_CFOP, :IPEVL_ULT_PRE, ');
                     SQL.Add(':IPEVL_PRECO_TABELA, :IPEFG_FATURA, :IPEPR_DESCONTO, :IPENR_PRECO, :ISN_EMPRESA)');

                     ParamByName('ISN_PEDIDO').Value  := IsnPedido;

                     ParamByName('ISN_PRODUTO').Value  :=  Itens[i].GetValue<Integer>('cod_produto', 0);  //ISN_PRODUTO

                     ParamByName('IPEQT_QUANTIDADE').Value  :=    Itens[i].GetValue<Double>('quantidade', 0);    //

                     ParamByName('IPEQT_QUANTIDADE_PALM').Value  :=  Itens[i].GetValue<Double>('quantidade', 0);

                     ParamByName('IPEVL_UNITARIO').Value  :=  Itens[i].GetValue<Double>('valor_unitario', 0);

                     ParamByName('IPEVL_UNITARIO_PALM').Value  :=  Itens[i].GetValue<Double>('valor_unitario', 0);

                     ParamByName('ISN_ITEM_PEDIDO').Value  :=  Funcao.NovoISN('T_ITEM_PEDIDO');

                     ParamByName('IPENR_SEQUENCIAL').Value  := seq_item;   //SEQUENCIAL DO PEDO ITEM NO PEDIDO

                     ParamByName('IPEPR_DESCPED').Value  := 0 ;//( Itens[i].GetValue<Double>('IPEVL_PRE_DIG', 0) / ( 1 - 1.10));

                     ParamByName('IPEVL_DESCONTO').Value  := Funcao.Desconto(Itens[i].GetValue<Double>('valor_unitario', 0),
                                                                             Itens[i].GetValue<Double>('prec_digitado', 0));   //VALOR DO DESCONTO

                     ParamByName('IPEVL_ACRESCIMO').Value  :=  Funcao.Acrescimo(Itens[i].GetValue<Double>('prec_digitado', 0),
                                                                                Itens[i].GetValue<Double>('valor_unitario', 0));  //VALOR ACRÉSCIMO

                     ParamByName('IPEVL_PRE_DIG').Value  :=  Itens[i].GetValue<Double>('prec_digitado', 0);     //PREÇO DIGITADO

                     ParamByName('ISN_UNIDADE_VENDA').Value  :=  Funcao.isn_und_vend_prod(Itens[i].GetValue<Integer>('cod_produto', 0));

                     ParamByName('IPEVL_CUSTO_FINAL').Value  :=  Funcao.custo_final_produto(Itens[i].GetValue<Integer>('cod_produto', 0));

                     ParamByName('IPEQT_UNIDADE_VENDA').Value  :=  Funcao.unidade_venda_produto(Itens[i].GetValue<Integer>('cod_produto', 0));

                     ParamByName('ISN_CFOP').Value  :=  Funcao.ConsultaCFOP(tipo_pedido); //Isn_cfop;

                     ParamByName('IPEVL_ULT_PRE').Value  :=  0; // Está zerado no codigo da SB

                     ParamByName('IPEVL_PRECO_TABELA').Value  :=  0;

                     ParamByName('IPEFG_FATURA').Value  :=  'S'; // ESTÁ S NO CODIGO FONT SOBBUILDER

                     ParamByName('IPEPR_DESCONTO').Value  :=  Null;

                     ParamByName('IPENR_PRECO').Value  :=  Funcao.ConsultaNumeroPreco(cod_cliente, cod_usuario);  //NUMERO DO PRECO

                     ParamByName('ISN_EMPRESA').Value  :=  1;

                     ExecSQL;

                     Funcao.Reserva_Estoque(Itens[i].GetValue<Integer>('cod_produto', 0),
                                            Itens[i].GetValue<Double>('quantidade', 0)
                                            )
                    end;
                  end;
                         DmGlobal.Conn.Commit;
                 end;


       except on ex:Exception do
         begin
            DmGlobal.Conn.Rollback;
            raise Exception.Create(ex.Message);
         end;
       end;
    finally
         FreeAndNil(qry);
    end;
  end;

end.
