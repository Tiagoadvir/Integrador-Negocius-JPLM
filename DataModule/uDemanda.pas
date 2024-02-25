unit uDemanda;

interface

  Uses System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, System.Variants,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,DateModule.Global,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.FMXUI.Wait,Biblioteca, UFuncoes,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.DApt,
  FMX.Dialogs;

  type
    TDemanda = class
        private
        public
          IsnDemanda : String;
          IsnProduto : Integer;
          Quantidade : Double;
          Pedido : Integer;
          IsnUsuario : Integer;
          function GerarInsert : String;
        end;

implementation


{ TDemanda }

function TDemanda.GerarInsert : String;
var
  strSQL : String;
  Funcao : TFuncoes;

begin
    Funcao := TFuncoes.Create;

    IsnDemanda := Funcao.NovoISN('T_DEMANDA');
    IsnUsuario := 99999;
    IsnProduto := 1 ; //'colocar o isn do produto'


  strSQL := 'INSERT INTO T_DEMANDA (ISN_DEMANDA, ISN_PRODUTO, DEMDT_DEMANDA, DEMQT_DEMANDA, ISN_PEDIDO, ISN_USUARIO) '+
            'VALUES ('+ IsnDemanda +', '+ IntToStr(IsnProduto) +','+ QuotedStr(FormatDateTime('mm/dd/yyyy hh:mm:ss', Now)) +', '+
            StringReplace(FloatToStr(Quantidade), ',', '.', [rfReplaceAll])+', '+IntToStr(Pedido)+', '+IntToStr(IsnUsuario)+') ';
  Result := strSQL;
end;

end.

end.
