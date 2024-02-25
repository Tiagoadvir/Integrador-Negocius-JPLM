unit UProdutoNegocius;

interface

  Uses System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, System.Variants,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,DateModule.Global,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.FMXUI.Wait,Biblioteca,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.DApt,
  FMX.Dialogs;

  type TProduto = class

  private
    lngIsnProduto : Integer;
    qryRegistro   : TFDQuery;
    bEstoqueFiscalLido, bEstoqueRealLido : Boolean;
    vEstoqueFiscal, vEstoqueReal : Double;
    Procedure Entrada_Estoque(rlQtd:real;parEstoque:string;parTipo:string='C';parFatorEntrada:double=0);
    function ExecSQL(parSQL: string; parTrans: boolean = false): Boolean;
    function fEstoqueFiscal : Double;
    function fEstoqueReal : Double;
  public
    constructor create(  conJPLMVar : TFDConnection  );
    Procedure Instancia_Produto(strCodPro:string);
    Procedure Baixa_Estoque(rlQtd:real;parEstoque:string;parTipo:string='V';strDev:string='N');
    Procedure Reserva_Estoque(rlQtd:real;parTipo:string = 'V';parFat:string = 'S');
    property EstoqueFiscal : Double read fEstoqueFiscal;
    property EstoqueReal : Double read fEstoqueReal;
  end;

implementation


var
  conJPLM : TFDConnection;


function TProduto.ExecSQL(parSQL: string; parTrans: boolean = false): Boolean;
var strSQL: string;
  ret: Boolean;
  DmGlobal : TDmGlobal;
begin
  strSQL := parSQL;
  ret := False;
  if parTrans then
    begin
      if not conJPLM.InTransaction then
        begin

          conJPLM.StartTransaction;
          try
            conJPLM.ExecSQL(strSQL);
            conJPLM.Commit;
            ret := true;
          except
           on E:Exception do
           begin
            conJPLM.Rollback;
            ret := False;
            Raise Exception.CreateFmt('ERRO: Transação inválida.(#:'+E.Message+')',[]);
           end;
          end;
        end;
    end
  else
    begin
      try
        conJPLM.ExecSQL(strSQL);
        ret := true;
      except
        on E:Exception do
        begin
        ret := False;
        Raise Exception.CreateFmt(E.Message,[]);
        end;
      end;
    end;
  ExecSQL := ret;
end;

Procedure TProduto.Baixa_Estoque(rlQtd:real;parEstoque:string;parTipo:string='V';strDev:string='N');
var strSQL:string;
var rlUniVenda: real;
StrArquivo : TStringList;
begin
  Try
    If parTipo = 'V' then       // Baixa estoque de Venda
       begin
         // Fator da Unidade de Venda
         qryRegistro:= TFDQuery.Create(conJPLM);
         qryRegistro.Connection := conJPLM;
         strSQL := 'SELECT PROQT_UNIDADE_VENDA AS UNI_VENDA FROM T_PRODUTO WHERE ISN_PRODUTO=' + inttostr(lngIsnProduto);
         qryRegistro.SQL.Add(strSQL);
         qryRegistro.Open;
         rlUniVenda := qryRegistro.FieldByName('UNI_VENDA').Value;
         qryRegistro.Close;

         if strDev = 'N'  then
           begin
             // Baixa reserva de estoque
             strSQL := 'UPDATE T_ESTOQUE SET ESTQT_RESERVA = ESTQT_RESERVA - ' + PontoVirg(floattostr(rlQtd*rlUniVenda));

             // LW 17/06/2005 Emite nota fiscal, então baixa a reserva fiscal
             if parEstoque = 'F' then
               begin
                 strSQL := strSQL + ', ESTQT_RESERVA_FISCAL = ESTQT_RESERVA_FISCAL - ' + PontoVirg(floattostr(rlQtd*rlUniVenda));
               end;

             strSQL := strSQL + ' WHERE ISN_PRODUTO=' + inttostr(lngIsnProduto);

             If not ExecSQL(strSQL) then
                begin
                  ShowMessage('Erro ao tentar retirar reservar de estoque do produto, operação não efetuada. Entre em contato com o Administrador');
                end;
           end;

         // Baixa do Estoque
         strSQL := 'UPDATE T_ESTOQUE SET ESTQT_QUANTIDADE = ESTQT_QUANTIDADE - ' + PontoVirg(floattostr(rlQtd*rlUniVenda));
         If parEstoque = 'F' then     // Estoque Fiscal
            begin
              strSQL := strSQL + ' ,ESTQT_ESTOQUE = ESTQT_ESTOQUE - ' + PontoVirg(floattostr(rlQtd*rlUniVenda));
            end;
         strSQL := strSQL + ' WHERE ISN_PRODUTO=' + inttostr(lngIsnProduto);

       {      StrArquivo := TStringList.Create;
             StrArquivo.LoadFromFile('C:\estoque.sql');
             StrArquivo.Add(strSQL+';');
             StrArquivo.SaveToFile('C:\estoque.sql');
             StrArquivo.Free;       }

         If not ExecSQL(strSQL) then
            begin
               ShowMessage('Erro ao tentar baixar estoque do produto, operação não efetuada. Entre em contato com o Administrador');
            end;
       end
    else if parTipo = 'U' then  // Baixa estoque unitário
            begin

             if strDev = 'N'  then
               begin
                  // Baixa reserva de estoque
                  strSQL := 'UPDATE T_ESTOQUE SET ESTQT_RESERVA= ESTQT_RESERVA - ' + PontoVirg(floattostr(rlQtd));

                  // Emite nota fiscal
                  if parEstoque = 'F' then
                    begin
                      strSQL := strSQL + ', ESTQT_RESERVA_FISCAL = ESTQT_RESERVA_FISCAL - ' + PontoVirg(floattostr(rlQtd));
                    end;

                   strSQL := strSQL + ' WHERE ISN_PRODUTO=' + inttostr(lngIsnProduto);

                  If not ExecSQL(strSQL) then
                     begin
                       ShowMessage('Erro ao tentar retirar reservar de estoque do produto, operação não efetuada. Entre em contato com o Administrador');
                     end;
                end;

              // Baixa do Estoque
              strSQL := 'UPDATE T_ESTOQUE SET ESTQT_QUANTIDADE= ESTQT_QUANTIDADE - ' + PontoVirg(floattostr(rlQtd));

              If parEstoque = 'F' then     // Estoque Fiscal
                  begin
                    strSQL := strSQL + ' ,ESTQT_ESTOQUE = ESTQT_ESTOQUE - ' + PontoVirg(floattostr(rlQtd));
                  end;

              strSQL := strSQL + ' WHERE ISN_PRODUTO=' + inttostr(lngIsnProduto);

              If not ExecSQL(strSQL) then
                 begin
                   ShowMessage('Erro ao tentar baixar estoque do produto, operação não efetuada. ' +
                   ' Entre em contato com o Administrador');
                 end;
            end;
  Except
    On E: Exception do ShowMessage(E.Message);
  End
end;

constructor TProduto.create(  conJPLMVar : TFDConnection );
begin
  conJPLM := conJPLMVar;
end;

Procedure TProduto.Entrada_Estoque(rlQtd:real;parEstoque:string;parTipo:string='C';parFatorEntrada:double=0);
var strSQL:string;
var rlUniCompra: real;
begin

    If parTipo = 'C' then       // Entrada do estoque na unidade de compra
    begin
    try

         // Fator da Unidade de Compra
         if parFatorEntrada = 0 then
            begin
             qryRegistro:= TFDQuery.Create(conJPLM);
             qryRegistro.Connection := conJPLM;
             strSQL := 'SELECT PROQT_CAIXA_FECHADA AS UNI_COMPRA FROM T_PRODUTO WHERE ISN_PRODUTO=' + inttostr(lngIsnProduto);
             qryRegistro.SQL.Add(strSQL);
             qryRegistro.Open;
             rlUniCompra := qryRegistro.FieldByName('UNI_COMPRA').Value;
             qryRegistro.Close;
            end
         else
          rlUniCompra := parFatorEntrada;
         // Entrada de estoque na Unidade de Compra
         strSQL := 'UPDATE T_ESTOQUE SET ESTQT_QUANTIDADE= ESTQT_QUANTIDADE + ' + PontoVirg(floattostr(rlQtd*rlUniCompra));
         If parEstoque = 'F' then     // Estoque Fiscal
            begin
              strSQL := strSQL + ' ,ESTQT_ESTOQUE = ESTQT_ESTOQUE + ' + PontoVirg(floattostr(rlQtd*rlUniCompra));
            end;
         strSQL := strSQL + ' WHERE ISN_PRODUTO=' + inttostr(lngIsnProduto);
         If not ExecSQL(strSQL) then
            begin
               ShowMessage('Erro ao tentar dar entrada no estoque do produto, operação não efetuada. Entre em contato com o Administrador');
            end
         else if parTipo = 'U' then  // Entrada em estoque unitário
            begin
              // Entrada do Estoque Unitário
              strSQL := 'UPDATE T_ESTOQUE SET ESTQT_QUANTIDADE= ESTQT_QUANTIDADE + ' + PontoVirg(floattostr(rlQtd));
              If parEstoque = 'F' then     // Estoque Fiscal
                 begin
                   strSQL := strSQL + ' ,ESTQT_ESTOQUE = ESTQT_ESTOQUE + ' + PontoVirg(floattostr(rlQtd));
                 end;
              strSQL := strSQL + ' WHERE ISN_PRODUTO=' + inttostr(lngIsnProduto);
              If not ExecSQL(strSQL) then
                 begin
                   ShowMessage('Erro ao tentar baixar estoque do produto, operação não efetuada. Entre em contato com o Administrador');
                 end;
            end;
        Except
          On E: Exception do ShowMessage(E.Message);
        End

   End;

end;

procedure TProduto.Instancia_Produto(strCodPro: string);
begin
  lngIsnProduto := StrToInt(strCodPro);
end;

Procedure TProduto.Reserva_Estoque(rlQtd:real;parTipo:string = 'V';parFat:string = 'S');
var strSQL:string;
var rlUniVenda: real;
begin
  Try
    // Fator da Unidade de Venda
    If parTipo = 'V' then       // Estoque de Venda
       begin
         qryRegistro:= TFDQuery.Create(conJPLM);
         qryRegistro.Connection := conJPLM;
         strSQL := 'SELECT PROQT_UNIDADE_VENDA AS UNI_VENDA FROM T_PRODUTO WHERE ISN_PRODUTO=' + inttostr(lngIsnProduto);
         qryRegistro.SQL.Add(strSQL);
         qryRegistro.Open;
         rlUniVenda := qryRegistro.FieldByName('UNI_VENDA').AsFloat;
         qryRegistro.Close;

         If ParFat = 'S' Then
           // Reserva de estoque de venda
           strSQL := 'UPDATE T_ESTOQUE SET ESTQT_RESERVA= ESTQT_RESERVA + ' + PontoVirg(floattostr(rlQtd*rlUniVenda))  +
                     ',ESTQT_RESERVA_FISCAL = ESTQT_RESERVA_FISCAL + ' + PontoVirg(floattostr(rlQtd*rlUniVenda))  +
                     ' WHERE ISN_PRODUTO=' + inttostr(lngIsnProduto)
         Else
           strSQL := 'UPDATE T_ESTOQUE SET ESTQT_RESERVA= ESTQT_RESERVA + ' + PontoVirg(floattostr(rlQtd*rlUniVenda))  +
                     ' WHERE ISN_PRODUTO=' + inttostr(lngIsnProduto);
       end
    else if parTipo = 'U' then     // Estoque Unitário
       begin

         If ParFat = 'S' Then
           // Reserva de estoque unitário
           strSQL := 'UPDATE T_ESTOQUE SET ESTQT_RESERVA= ESTQT_RESERVA + ' + PontoVirg(floattostr(rlQtd))  +
                     ',ESTQT_RESERVA_FISCAL = ESTQT_RESERVA_FISCAL + ' + PontoVirg(floattostr(rlQtd))  +
                     ' WHERE ISN_PRODUTO=' + inttostr(lngIsnProduto)
         Else
           // Reserva de estoque unitário
           strSQL := 'UPDATE T_ESTOQUE SET ESTQT_RESERVA= ESTQT_RESERVA + ' + PontoVirg(floattostr(rlQtd))  +
                     ' WHERE ISN_PRODUTO=' + inttostr(lngIsnProduto);

       end;
       // Atualiza Reserva de estoque
       If not ExecSQL(strSQL) then
          ShowMessage('Erro ao reservar estoque do produto, operação não efetuada. Entre em contato com o Administrador');
  Except
    On E: Exception do ShowMessage(E.Message);
  End
end;

function TProduto.fEstoqueFiscal: Double;
var
  strSQL : String;
  qryFiscal : TFDQuery;
begin
  //TODO: Ler estoque fiscal.
  try
    if(bEstoqueFiscalLido)then
    begin
      Result := vEstoqueFiscal;
    end
    else
    begin
      Result := 0;

      strSQL := 'SELECT ((EST.ESTQT_ESTOQUE/PRO.PROQT_UNIDADE_VENDA)-(EST.ESTQT_RESERVA_FISCAL/PRO.PROQT_UNIDADE_VENDA)) SALDOFISCAL '+
                'FROM T_ESTOQUE EST JOIN T_PRODUTO PRO ON PRO.ISN_PRODUTO = EST.ISN_PRODUTO '+
                'WHERE PRO.ISN_PRODUTO = ' + IntToStr(lngIsnProduto);
      qryFiscal := TFDQuery.Create(conJPLM);
      qryFiscal.Connection := conJPLM;
      qryFiscal.SQL.Add(strSQL);
      qryFiscal.Open;

      if(not qryFiscal.Eof)then
      begin
        vEstoqueFiscal := qryFiscal.Fields[0].AsFloat;
        bEstoqueFiscalLido := True;
      end;

      Result := vEstoqueFiscal;

      qryFiscal.Close;
    end;
  except
    On E:Exception do
    begin
      qryFiscal.Close;
      qryFiscal := nil;
    end;
  end;
end;

function TProduto.fEstoqueReal: Double;
var
  strSQL : String;
  qryReal : TFDQuery;
begin
  //TODO: Ler estoque real.
  try
    if(bEstoqueRealLido)then
    begin
      Result := vEstoqueReal;
    end
    else
    begin
      Result := 0;


      strSQL := 'SELECT ((EST.ESTQT_QUANTIDADE/PRO.PROQT_UNIDADE_VENDA)-(EST.ESTQT_RESERVA/PRO.PROQT_UNIDADE_VENDA)) SALDOREAL '+
                'FROM T_ESTOQUE EST JOIN T_PRODUTO PRO ON PRO.ISN_PRODUTO = EST.ISN_PRODUTO '+
                'WHERE PRO.ISN_PRODUTO = ' + IntToStr(lngIsnProduto);
      qryReal := TFDQuery.Create(conJPLM);
      qryReal.Connection := conJPLM;
      qryReal.SQL.Add(strSQL);
      qryReal.Open;

      if(not qryReal.Eof)then
      begin
        vEstoqueReal := qryReal.Fields[0].AsFloat;
        bEstoqueRealLido := True;
      end;

      Result := vEstoqueReal;

      qryReal.Close;
    end;
  except
    On E:Exception do
    begin
      qryReal.Close;
      qryReal := nil;
    end;
  end;
end;

end.


end.
