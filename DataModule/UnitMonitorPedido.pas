unit UnitMonitorPedido;

interface

uses
 uFuncoes,
  uMD5,

  Data.DB,

  DataSet.Serialize,
  DataSet.Serialize.Config,
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

  system.IniFiles, FMX.Dialogs;

  Type

    TMonitorPedido = class

    private
      strSQL : string;
      qryRegistro   : TFDQuery;

      // Emite Nota Fiscal
      strGerarNotaFiscal : string;
      // Código do tipo
      strCodigoTipo : string;
      // Descrição do tipo
      strDescricaoTipo : string;
      // Tipo de Pedido Troca
      strTipoPedidoTroca : string;
      // Tipo de Pedido Cupom Fiscal
      strTipoPedidoCupom : string;
      // Código do CFOP
      strCFOPCodigo : string;
      // Descrição do CFOP
      strCFOPDescricao : string;
      // CFOP de Venda
      strCFOPVenda : string;
      // CFOP de Devolucao de Cliente
      strCFOPDevolucao : string;
      // CFOP de Devolução de Fornecedor
      strCFOPTipoDevolucao : string;
      // CFOP Dentro do Estado
      strCFOPDentroEstado : string;
      // CFOP Negociar
      strCFOPNegociar : string;
      // CFOP ISN
      intCFOPISN : integer;
      // Estoque Loja
      strEstoqueLoja : string;
      // CFOP de Bonificação
      strCFOPBonificacao : string;
      // CFOP outras Opercações
      strCFOPOutraOperacao: string;
      // C/C Gerente
      strCCGerente : string;
      // Pedido Ordem
      strNFeFutura : string;

      (*FORMA DE PAGAMENTO*)
      // Código da Forma de Pagamento
      strFormaPagtoDS : string;
      // Forma Pagamento ISN
      intFormaPagtoISN : integer;
      // Forma Pagamento Prazo
      strFormaPagtoPrazo: string;
      // Forma Pagamento Tipo
      strFormaPagtoTipo: string;

      // Estoque RCA usado na TETECLARO
      strTipoPedEstoqueRCA : string;
      strConferirPedido: string;

      (*PRAZO*)
      intPrazoISN: integer;
      strPrazoCN: string;
      strPrazoDS: string;
      intPrazoDiasEntrada: integer;
      intPrazoParcela: integer;
      strPrazoInativo: string;
      dblPrazoMaxDesconto : double;
      intPrazoIntervalo: integer;
      intPrazoMAX: integer;
      intPrazoMedio: integer;
      dblPrazoAcrescimo: double;

      (*Pedido*)
      strRepCN, strRepISN : string;
      strRepISNRegiao : string;
      strCliCN, strCliISN : String;
      strIsnPedido: string;

      (*ITENS DO PEDIDO*)
      // Status do Produto
      strProdutoStatus: string;
      // Tipo Fração do Produto
      strProdutoTipoFracao: string;
      // Descrição do Produto
      strProdutoDescricao: string;
      // Produto Multi Venda
      intProdutoMultVenda: integer;
      // Produto Multi Venda do Grupo
      intProdutoGrupoMultVenda: integer;
      // Produto Multiplo de Venda Fracionado
      dblProdutoMultVendaFrac: double;
      // Produto SubGrupo Grade
      strProdutoSubGrade: string;
      // Produto Custo Médio
      fltProdutoCustoMedio: double;
      // Produto Custo Final
      fltProdutoCustoFinal: double;
      // Produto Desconto Máximo
      fltProdutoDescontoMaximo: double;
      // Produto Acrescimo Máximo
      fltProdutoAcrescimoMaximo: double;
      // Produto Valor Acrescimo Máximo
      fltProdutoVLAcrMax: double;
      // Produto Valor Desconto Máximo
      fltProdutoVLDscMax: double;
      // Produto ISN
      intProdutoISN: integer;
      // Produto ISN da Unidade
      intProdutoIsnUnidade: integer;
      // Produto ISN da Unidade de Venda
      intProdutoIsnUniVenda: integer;
      // Produto Qtde da Unidade de Venda
      intProdutoQtdeUniVenda: integer;
      // Produto Verba
      fltProdutoVerba: double;
      // Produto Descrição da Unidade
      strProdutoDsUnidade: string;
      // CFOP do produto
      strProdutoCnCFOP: string;
      // CFOP do produto Isn
      intProdutoIsnCFOP: integer;
      // Produto Qtde. Caixa Fechada
      intProdutoQtdeCxaFechada: integer;
      // Bloco
      strBloco: string;
      // Percentual Lucro
      fltPerLucro : double;
      // Percentual Icms
      fltPerProdutoIcms : double;
      // Desconto Promocional
      fltPerProdutoDesconto: double;
      // Aplicar Custo
      fltPerAplicarCusto: double;


      // Venda Avulsa
      strVendaAvulsa:string;
      // Nota Importação
      strNFeImportacao:string;
      // Gera Financeiro
      strGeraFinanceiro:string;
      // Varejo
      strVarejo:string;
      // Libera Preço
      strLiberaPreco:string;
      // Avaria Acerto
      strAvariaAcerto:string;
      // Lojinha
      strEstoqueLojinha:string;
      //Verificar se utrapassou o limite do cliente
      blnUltrapassaLimite: Boolean;
      blnRestaura: boolean;


    public
      (*CAPA DO PEDIDO*)
      // Gera Nota Fiscal
      property GerarNotaFiscal: string Read strGerarNotaFiscal;
      // Código do CFOP
      property CodigoCFOP: string Read strCFOPCodigo;
      // Descrição do CFOP
      property DescricaoCFOP: string Read strCFOPDescricao;
      // Código do Tipo
      property CodigoTipo: string Read strCodigoTipo;
      // Descrição do Tipo
      property DescricaoTipo: string Read strDescricaoTipo;
      // Tipo de Pedido Troca
      property TipoPedidoTroca   : string Read strTipoPedidoTroca;
      // Tipo de Pedido Troca
      property TipoPedidoCupom   : string Read strTipoPedidoCupom;
      // Estoque RCA
      property TipoPedEstoqueRCA: string Read strTipoPedEstoqueRCA;
      // Conferir Pedido
      property ConferirPedido: string Read strConferirPedido;
      // Bloco de pedido
      property Bloco: string Read strBloco;

      // CFOP de Venda
      property CFOPVenda : string Read strCFOPVenda;
      // CFOP de Devolucao de Cliente
      property CFOPDevolucao : string Read strCFOPDevolucao;
      // CFOP de Devolucao de Cliente
      property CFOPTipoDevolucao : string Read strCFOPTipoDevolucao;
      // CFOP Dentro do Estado
      property CFOPDentroEstado  : string Read strCFOPDentroEstado;
      // CFOP Negociar
      property CFOPNegociar : string read strCFOPNegociar;
      // Estoque Loja
      property EstoqueLoja : string read strEstoqueLoja;
      // CFOP de Bonificação
      property CFOPBonificacao : string read strCFOPBonificacao;
      // CFOP Outra Operação
      property CFOPOutraOperacao : string read strCFOPOutraOperacao;
      // CFOP ISN
      property CFOPISN : integer read intCFOPISN;

      // Forma de Pagamento Descrição
      property FormaPagtoDS: string Read strFormaPagtoDS;
      // Forma de Pagamento ISN
      property FormaPagtoISN: integer Read intFormaPagtoISN;
      // Forma de Pagamento Prazo
      property FormaPagtoPrazo: string Read strFormaPagtoPrazo;
      // Forma de Pagamento Tipo
      property FormaPagtoTipo: string Read strFormaPagtoTipo;

      // Prazo ISN
      property PrazoISN: integer Read intPrazoISN;
      // Prazo CN
      property PrazoCN: string Read strPrazoCN;
      // Prazo DS
      property PrazoDS: string Read strPrazoDS;
      // Prazo Dias de Entrada
      property PrazoDiasEntrada: integer Read intPrazoDiasEntrada;
      // Prazo Médio
      property PrazoMedio: integer Read intPrazoMedio;
      // Prazo Parcela
      property PrazoParcela: integer Read intPrazoParcela;
      // Prazo Inativo
      property PrazoInativo: string Read strPrazoInativo;
      // Prazo Máximo de Desconto
      property PrazoMaxDesconto: double Read dblPrazoMaxDesconto;
      // Prazo Intervalo
      property PrazoIntervalo: integer Read intPrazoIntervalo;
      // Prazo Acréscimo
      property PrazoAcrescimo: double Read dblPrazoAcrescimo;
      // Percentual Lucro
      property PerLucro : double Read fltPerLucro;
      // Percentual Icms
      property PerProdutoIcms : double Read fltPerProdutoIcms;
      // Percentual desconto promocional
      property PerProdutoDesconto : double Read fltPerProdutoDesconto;
      // Percentual aplicar custo
      property PerAplicarCusto : double Read fltPerAplicarCusto;

      // Venda Avulsa
      property VendaAvulsa : string Read strVendaAvulsa;
      // Gera Financeiro
      property GeraFinanceiro : string Read strGeraFinanceiro;
      property NFeImportacao  : string Read strNFeImportacao;
      // Varejo
      property Varejo : string Read strVarejo;

      // Libera Preço
      property LiberaPreco : string Read strLiberaPreco;
      // Avaria Acerto
      property AvariaAcerto : string Read strAvariaAcerto;
      // Lojinha
      property EstoqueLojinha : string Read strEstoqueLojinha;
      // C/C Gerente
      property CCGerente : string Read strCCGerente;
      // Pedido Ordem
      property NFeFutura : string Read strNFeFutura;

      property RepCN: String Read strRepCN;
      property RepISN: String Read strRepISN;
      property RepISNRegiao: String Read strRepISNRegiao;
      property ClienteCN: String Read strCliCN;
      property ClienteISN: String Read strCliISN;


      (* ITENS DO PEDIDO*)

      // Produto Status
      property ProdutoStatus: string Read strProdutoStatus;
      // Produto Tipo Fração
      property ProdutoTipoFracao: string Read strProdutoTipoFracao;
      // Produto Descrição
      property ProdutoDescricao: string Read strProdutoDescricao;
      // Produto Multi Venda
      property ProdutoMultVenda: integer Read intProdutoMultVenda;
      // Produto Grupo Multi Venda
      property ProdutoGrupoMultVenda: integer Read intProdutoGrupoMultVenda;
      // Produto Multiplo de Venda Fracionado
      property ProdutoMultVendaFrac: double Read dblProdutoMultVendaFrac;


      // Produto Caixa Fechada
      property ProdutoQtdeCxaFechada: integer Read intProdutoQtdeCxaFechada;

      // Produto SubGrupo Grade
      property ProdutoSubGrade: string Read strProdutoSubGrade;
      // Produto Custo Médio
      property ProdutoCustoMedio: double Read fltProdutoCustoMedio;
      // Produto Custo Final
      property ProdutoCustoFinal: double Read fltProdutoCustoFinal;
      // Produto Desconto Máximo
      property ProdutoDescontoMaximo: double Read fltProdutoDescontoMaximo;
      // Produto Acrescimo Máximo
      property ProdutoAcrescimoMaximo: double Read fltProdutoAcrescimoMaximo;
      // Produto Acrescimo Máximo
      property ProdutoVLAcrMax: double Read fltProdutoVLAcrMax;
      // Produto Desonto Máximo
      property ProdutoVLDscMax: double Read fltProdutoVLDscMax;
      // Produto ISN
      property ProdutoISN: integer Read intProdutoISN;
      // Produto ISN de Unidade
      property ProdutoIsnUnidade: integer Read intProdutoIsnUnidade;
      // Produto ISN de Unidade de Venda
      property ProdutoIsnUniVenda: integer Read intProdutoIsnUniVenda;
      // Produto Qtde da Unidade de Venda
      property ProdutoQtdeUniVenda: integer Read intProdutoQtdeUniVenda;
      // Produto Verba
      property ProdutoVerba: double Read fltProdutoVerba;
      // Produto Descrição da Unidade
      property ProdutoDsUnidade: string Read strProdutoDsUnidade;
      // Produto Código CFOP
      property ProdutoCnCFOP: string Read strProdutoCnCFOP;
      // Produto Isn CFOP
      property ProdutoIsnCFOP: integer Read intProdutoIsnCFOP;


      (* =================================================== Functions =================================================== *)
      function ArrayCampos(strArrayCampos:string;intQtdeCampos:integer): Variant;
      // Aceita Prazo pelo tipo de pedido
      function Prazo_Atende_TipoPed(strCodPZ:string;strIsnTipoPedido:string) : boolean;
      function getCargaTipoPedidoGrupo(strIsnTipoPedido:string):TFDQuery;

   {   function CriticaValores(strCodigoProduto, strLiberarVenda: string;
      dblPrecoBase, dblDesconto, dblAcrescimo, dblPrecoDig, dblQuantidade, dblTotIt, dblTotItAnt, dblValorPedido, fltLimiteTotal: double;
      blnCustoMedio: Boolean): boolean;  }

      function UltrapassaLimite(strOp : string;fltValor, dblValorPedido, fltLimiteTotal, fltDesconto : double) : boolean;
      function TotalCusto: double;
      (* =================================================== Functions =================================================== *)

      (* =================================================== procedure =================================================== *)
      procedure CalculaPedido(blnCliLiberado: Boolean; dblLimiteCliente, dblDesconto: Double);
      (*CAPA DO PEDIDO*)
      procedure CargaDados(strTipoPedido,strCodigoCFOP:string);
      procedure FormaPagamento(strFormaPagto:string);
      procedure Prazo(strPrazoCodigo: string);

      (*Pedido*)
      procedure CargaPedido(strCnPedido:string);
      (*ITENS DO PEDIDO*)
      procedure CargaDadosItens(strCodProduto: string);
      (* =================================================== procedure =================================================== *)
  end;

implementation

{ TMonitorPedido }

function TMonitorPedido.ArrayCampos(strArrayCampos: string;
  intQtdeCampos: integer): Variant;
Var arrTemp: array of string;
    strNomeCampo : string;
    intI,intPosTab:integer;
begin
   SetLength(arrTemp, 0);
   for intI := 0 to intQtdeCampos-1 do
     begin
       SetLength(arrTemp, intI + 1);
       intPosTab := Pos('|',strArrayCampos);
       strNomeCampo := copy(strArrayCampos,1,intPosTab-1);
       strArrayCampos := copy(strArrayCampos,intPosTab+1,length(strArrayCampos));
       arrTemp[intI] := strNomeCampo;
     end;
  ArrayCampos := arrTemp;
end;

procedure TMonitorPedido.CargaDados(strTipoPedido,strCodigoCFOP:string);
begin
  strSQL := 'SELECT TPED.TIPFG_NOTA_FISCAL,TPED.ISN_TIPO_PEDIDO,TPED.TIPDS_TIPO,CFOP.CFOCN_CFOP,CFOP.CFOFG_VENDA,CFOP.CFODS_CFOP,CFOP.CFOFG_DEVOLUCAO, ' +
            'CFOP.CFOFG_TIPO_DEVOLUCAO,TPED.TIPFG_TROCA,CFOP.CFOFG_DENTRO_UF,CFOP.CFOFG_NEGOCIAR,CFOP.ISN_CFOP,CFOP.CFOFG_BONIFICACAO, ' +
            'TPED.TIPFG_ESTOQUE_LOJA,TPED.TIPFG_CUPOM_FISCAL,CFOP.CFOFG_OUTRAS_OPERACOES,TPED.TIPFG_ESTOQUE_RCA,TIPFG_JACONFERIR_PEDIDO,TIPFG_BLOCO, ' +
            'TPED.TIPFG_VENDA_AVULSA,TPED.TIPFG_GERA_FINANCEIRO, TPED.TIPFG_NFE_IMPORTADA,TPED.TIPFG_VAREJO,TPED.TIPFG_LIBERA_PRECO,TPED.TIPFG_AVARIA_ACERTO, ' +
            'TPED.TIPFG_GERA_CCGERENTE,TPED.TIPFG_ENTREGA_FUTURA,TPED.TIPFG_LOJINHA ' +
            'FROM T_TIPO_PEDIDO TPED,T_CFOP CFOP  ' +
            'WHERE TPED.TIPFG_ATIVO = ''S'' AND TPED.ISN_CFOP = CFOP.ISN_CFOP ';
  if Trim(strCodigoCFOP) <> '' Then
    strSQL := strSQL + 'AND CFOP.CFOCN_CFOP = ' + strCodigoCFOP;
  if Trim(strTipoPedido) <> '' Then
    strSQL := strSQL + 'AND TPED.ISN_TIPO_PEDIDO = ' + strTipoPedido;

  qryRegistro := TFDQuery.Create(Nil);
  qryRegistro.Connection := DmGlobal.Conn;
  qryRegistro.SQL.Add(strSQL);
  qryRegistro.Open;
  if not qryRegistro.Eof then
    begin
      strGerarNotaFiscal := qryRegistro.FieldByName('TIPFG_NOTA_FISCAL').AsString;
      strCodigoTipo      := qryRegistro.FieldByName('ISN_TIPO_PEDIDO').AsString;
      strDescricaoTipo   := qryRegistro.FieldByName('TIPDS_TIPO').AsString;
      strCFOPCodigo      := qryRegistro.FieldByName('CFOCN_CFOP').AsString;
      strCFOPDescricao   := qryRegistro.FieldByName('CFODS_CFOP').AsString;
      strCFOPVenda       := qryRegistro.FieldByName('CFOFG_VENDA').AsString;
      strCFOPDevolucao   := qryRegistro.FieldByName('CFOFG_DEVOLUCAO').AsString;
      strCFOPTipoDevolucao := qryRegistro.FieldByName('CFOFG_TIPO_DEVOLUCAO').AsString;
      strTipoPedidoTroca   := qryRegistro.FieldByName('TIPFG_TROCA').AsString;
      strCFOPDentroEstado  := qryRegistro.FieldByName('CFOFG_DENTRO_UF').AsString;
      strCFOPNegociar      := qryRegistro.FieldByName('CFOFG_NEGOCIAR').AsString;
      strEstoqueLoja       := qryRegistro.FieldByName('TIPFG_ESTOQUE_LOJA').AsString;
      intCFOPISN           := qryRegistro.FieldByName('ISN_CFOP').AsInteger;
      strCFOPBonificacao   := qryRegistro.FieldByName('CFOFG_BONIFICACAO').AsString;
      strTipoPedidoCupom   := qryRegistro.FieldByName('TIPFG_CUPOM_FISCAL').AsString;
      strCFOPOutraOperacao := qryRegistro.FieldByName('CFOFG_OUTRAS_OPERACOES').AsString;
      strTipoPedEstoqueRCA := qryRegistro.FieldByName('TIPFG_ESTOQUE_RCA').AsString;
      strConferirPedido    := qryRegistro.FieldByName('TIPFG_JACONFERIR_PEDIDO').AsString;
      strBloco             := qryRegistro.FieldByName('TIPFG_BLOCO').AsString;
      strVendaAvulsa       := qryRegistro.FieldByName('TIPFG_VENDA_AVULSA').AsString;
      strGeraFinanceiro    := qryRegistro.FieldByName('TIPFG_GERA_FINANCEIRO').AsString;
      strNFeImportacao     := qryRegistro.FieldByName('TIPFG_NFE_IMPORTADA').AsString;
      strVarejo            := qryRegistro.FieldByName('TIPFG_VAREJO').AsString;
      strLiberaPreco       := qryRegistro.FieldByName('TIPFG_LIBERA_PRECO').AsString;
      strAvariaAcerto      := qryRegistro.FieldByName('TIPFG_AVARIA_ACERTO').AsString;
      strEstoqueLojinha    := qryRegistro.FieldByName('TIPFG_LOJINHA').AsString;
      strCCGerente         := qryRegistro.FieldByName('TIPFG_GERA_CCGERENTE').AsString;
      strNFeFutura         := qryRegistro.FieldByName('TIPFG_ENTREGA_FUTURA').AsString;
    end
  Else
    begin
      strGerarNotaFiscal := '';strCodigoTipo := '';strDescricaoTipo := '';strCFOPCodigo := '';strCFOPDescricao := '';
      strCFOPVenda := '';strCFOPDevolucao := '';strCFOPTipoDevolucao := '';strTipoPedidoTroca := ''; strCFOPDentroEstado := '';
      strCFOPNegociar := '';strEstoqueLoja:=''; strCFOPBonificacao:= ''; strTipoPedidoCupom:=''; strTipoPedEstoqueRCA := '';
      strConferirPedido := '';strBloco:='';strVendaAvulsa:='';strGeraFinanceiro:='';strVarejo:='';strLiberaPreco:='';strAvariaAcerto := '';
      strCCGerente := '';strNFeFutura := '';strEstoqueLojinha:='';
    end;
  qryRegistro.Close;

end;
procedure TMonitorPedido.CargaPedido(strCnPedido:string);
begin
  qryRegistro := TFDQuery.Create(Nil);
  qryRegistro.Connection := DmGlobal.Conn;

  strSQL := 'SELECT PED.ISN_PEDIDO, PED.PEDCN_PEDIDO, CLI.ISN_CLIENTE, CLI.CLICN_CLIENTE, CLI.CLINM_CLIENTE, '+
            'REP.ISN_REPRESENTANTE, REP.REPCN_REPRESENTANTE, REP.ISN_REGIAO, '+
            'TP.TIPFG_ESTOQUE_LOJA, TP.TIPFG_NOTA_FISCAL '+
            'FROM T_PEDIDO PED '+
            'JOIN T_CLIENTE CLI ON (CLI.ISN_CLIENTE = PED.ISN_CLIENTE) '+
            'JOIN T_REPRESENTANTE REP ON (REP.ISN_REPRESENTANTE = PED.ISN_REPRESENTANTE) '+
            'JOIN T_TIPO_PEDIDO TP ON (TP.ISN_TIPO_PEDIDO = PED.ISN_TIPO_PEDIDO) '+
            'JOIN T_CFOP CFOP ON (CFOP.ISN_CFOP = PED.ISN_CFOP)' +
            'JOIN T_PRAZO PRA ON (PRA.ISN_PRAZO = PED.ISN_PRAZO) '+
            'JOIN T_FORMA_PAGAMENTO FP ON (FP.ISN_FORMA_PAGAMENTO = PED.ISN_FORMA_PAGAMENTO) '+
            'WHERE PED.PEDCN_PEDIDO = '+strCnPedido;

  qryRegistro.SQL.Add(strSQL);
  qryRegistro.Open;

  strIsnPedido := qryRegistro.FieldByName('ISN_PEDIDO').AsString;
  strRepCN    := qryRegistro.FieldByName('REPCN_REPRESENTANTE').AsString;
  strRepISN   := qryRegistro.FieldByName('ISN_REPRESENTANTE').AsString;
  strRepISNRegiao:= qryRegistro.FieldByName('ISN_REGIAO').AsString;
  strCliCN    := qryRegistro.FieldByName('CLICN_CLIENTE').AsString;
  strCliISN   := qryRegistro.FieldByName('ISN_CLIENTE').AsString;
  strEstoqueLoja := qryRegistro.FieldByName('TIPFG_ESTOQUE_LOJA').AsString;
  strGerarNotaFiscal := qryRegistro.FieldByName('TIPFG_NOTA_FISCAL').AsString;

  qryRegistro.Close;

End;
procedure TMonitorPedido.CargaDadosItens(strCodProduto:string);
var strSQL : string;
begin
  strSQL := 'SELECT PROD.PROFG_STATUS FG_STATUS,PROD.PROFG_TIPO_FRACAO TIPO_FRACAO,PROD.PRODS_PRODUTO DS_PRODUTO,COALESCE(PROD.PROQT_MULT_VENDA,0) MULT_VENDA,' +
            'COALESCE(GRP.GRUQT_MULT_VENDA,0) GP_MULT_VENDA,SUBGRP.SUBFG_GRADE SUB_GRADE,EST.ESTVL_PRECO_MEDIO_CUSTO CUSTO_MEDIO,EST.ESTVL_PRECO_CUSTO_FINAL CUSTO_FINAL, ' +
            'COALESCE(PRODI.PROPR_DESCONTO_MAXIMO,0) PRO_DESC_MAX,COALESCE(PRODI.PROPR_ACRESCIMO_MAXIMO,0) PRO_ACRES_MAX, ' +
            'PROD.ISN_PRODUTO,PROD.ISN_UNIDADE,PROD.ISN_UNIDADE_VENDA,COALESCE(PROD.PROQT_UNIDADE_VENDA,1) QT_UNIDADE_VENDA,PROVL_VERBA VL_VERBA, ' +
            'UNIDS_UNIDADE,CFOP.CFOCN_CFOP CN_CFOP,CFOP.ISN_CFOP, PROD.PROQT_CAIXA_FECHADA, PROD.PROQT_MULT_FRACIONADO,PRODI.PROPR_LUCRO LUCRO, ' +
            'PRODI.PROPR_ICMS,PROPR_DESCONTO PR_DESCONTO, ' +
            'COALESCE(PRODI.PROVL_ACRESCIMO_MAXIMO,0) PROVL_ACR_MAX, ' +
            'COALESCE(PRODI.PROVL_DESCONTO_MAXIMO,0) PROVL_DSC_MAX, ' +
            'COALESCE(PRODI.PROPR_APLICAR_CUSTO,0) PROPR_APLICAR_CUSTO ' +
            'FROM T_PRODUTO PROD ' +
            'INNER JOIN T_GRUPO GRP ON (GRP.ISN_GRUPO = PROD.ISN_GRUPO) ' +
            'INNER JOIN T_SUBGRUPO SUBGRP ON (SUBGRP.ISN_SUBGRUPO = PROD.ISN_SUBGRUPO) ' +
            'INNER JOIN T_ESTOQUE EST ON (EST.ISN_PRODUTO = PROD.ISN_PRODUTO) ' +
            'INNER JOIN T_UNIDADE UND ON (UND.ISN_UNIDADE = PROD.ISN_UNIDADE) ' +
            'INNER JOIN T_CFOP CFOP ON (CFOP.ISN_CFOP = PROD.ISN_CFOP) ' +
            'INNER JOIN T_PRODUTO_IMPOSTO PRODI ON (PRODI.ISN_PRODUTO = PROD.ISN_PRODUTO) ' +
            'WHERE PROD.PROCC_PRODUTO = ' + QuotedStr(strCodProduto) +
            ' AND PRODI.ISN_EMPRESA = ' + intToStr(1) +       //isn empresa
            ' AND EST.ISN_EMPRESA = ' + intToStr(1);         //isn empresa

  qryRegistro := TFDQuery.Create(Nil);
  qryRegistro.Connection := DmGlobal.Conn;
  qryRegistro.SQL.Add(strSQL);
  qryRegistro.Open;
  if not qryRegistro.Eof then
    begin
      strProdutoStatus := qryRegistro.FieldByName('FG_STATUS').AsString;
      strProdutoTipoFracao := qryRegistro.FieldByName('TIPO_FRACAO').AsString;
      strProdutoDescricao := qryRegistro.FieldByName('DS_PRODUTO').AsString;
      intProdutoMultVenda := qryRegistro.FieldByName('MULT_VENDA').AsInteger;
      intProdutoGrupoMultVenda := qryRegistro.FieldByName('GP_MULT_VENDA').AsInteger;
      dblProdutoMultVendaFrac := qryRegistro.FieldByName('PROQT_MULT_FRACIONADO').AsFloat;
      strProdutoSubGrade := qryRegistro.FieldByName('SUB_GRADE').AsString;
      fltProdutoCustoMedio := qryRegistro.FieldByName('CUSTO_MEDIO').AsFloat;
      fltProdutoCustoFinal := qryRegistro.FieldByName('CUSTO_FINAL').AsFloat;
      fltProdutoAcrescimoMaximo := qryRegistro.FieldByName('PRO_ACRES_MAX').AsFloat;
      fltProdutoDescontoMaximo := qryRegistro.FieldByName('PRO_DESC_MAX').AsFloat;
      fltProdutoVLAcrMax := qryRegistro.FieldByName('PROVL_ACR_MAX').AsFloat;
      fltProdutoVLDscMax := qryRegistro.FieldByName('PROVL_DSC_MAX').AsFloat;
      intProdutoISN := qryRegistro.FieldByName('ISN_PRODUTO').AsInteger;
      intProdutoIsnUnidade := qryRegistro.FieldByName('ISN_UNIDADE').AsInteger;
      intProdutoIsnUniVenda := qryRegistro.FieldByName('ISN_UNIDADE_VENDA').AsInteger;
      intProdutoQtdeUniVenda := qryRegistro.FieldByName('QT_UNIDADE_VENDA').AsInteger;
      fltProdutoVerba := qryRegistro.FieldByName('VL_VERBA').AsFloat;
      strProdutoDsUnidade := qryRegistro.FieldByName('UNIDS_UNIDADE').AsString;
      intProdutoIsnCFOP := qryRegistro.FieldByName('ISN_CFOP').AsInteger;
      strProdutoCnCFOP := qryRegistro.FieldByName('CN_CFOP').AsString;
      intProdutoQtdeCxaFechada := qryRegistro.FieldByName('PROQT_CAIXA_FECHADA').AsInteger;
      fltPerLucro := qryRegistro.FieldByName('LUCRO').AsFloat;
      fltPerProdutoIcms := qryRegistro.FieldByName('PROPR_ICMS').AsFloat;
      fltPerProdutoDesconto := qryRegistro.FieldByName('PR_DESCONTO').AsFloat;
      fltPerAplicarCusto := qryRegistro.FieldByName('PROPR_APLICAR_CUSTO').AsFloat;

    end
  else
    begin
      strProdutoStatus:='';strProdutoTipoFracao:='';strProdutoDescricao:='';
      intProdutoMultVenda:=0;intProdutoGrupoMultVenda:=0;strProdutoSubGrade:='';
      fltProdutoCustoMedio:=0;fltProdutoCustoFinal:=0;fltProdutoAcrescimoMaximo:=0;
      fltProdutoDescontoMaximo:=0;intProdutoISN:=0;intProdutoIsnUnidade:=0;intProdutoIsnUniVenda:=0;
      intProdutoQtdeUniVenda:=0;fltProdutoVerba:=0;strProdutoDsUnidade:='';strProdutoCnCFOP:='';
      intProdutoIsnCFOP:=0;dblProdutoMultVendaFrac:=0;fltPerLucro:=0;fltPerProdutoIcms:=0;fltPerProdutoDesconto:=0;
      fltProdutoVLAcrMax:=0;fltProdutoVLDscMax:=0;fltPerAplicarCusto:=0;
    end;

 qryRegistro.Close;
end;

procedure TMonitorPedido.FormaPagamento(strFormaPagto: string);
var strSQL : string;
begin

  strSQL := 'SELECT ISN_FORMA_PAGAMENTO,FPADS_FORMA,FPATP_PAGAMENTO,FPAFG_PRAZO FROM T_FORMA_PAGAMENTO WHERE FPACN_FORMA = ' + QuotedStr(strFormaPagto);

  qryRegistro := TFDQuery.Create(Nil);
  qryRegistro.Connection := DmGlobal.Conn;
  qryRegistro.SQL.Add(strSQL);
  qryRegistro.Open;
  if not qryRegistro.Eof then
    begin
      strFormaPagtoDS := qryRegistro.FieldByName('FPADS_FORMA').AsString;
      intFormaPagtoISN:= qryRegistro.FieldByName('ISN_FORMA_PAGAMENTO').AsInteger;
      strFormaPagtoPrazo:= qryRegistro.FieldByName('FPAFG_PRAZO').AsString;
      strFormaPagtoTipo:= qryRegistro.FieldByName('FPATP_PAGAMENTO').AsString;
    end
  else
    begin
      strFormaPagtoDS:='';intFormaPagtoISN:=0;strFormaPagtoPrazo:='';strFormaPagtoTipo:='';
    end;

end;

procedure TMonitorPedido.Prazo(strPrazoCodigo: string);
var strSQL: string;
begin
  strSQL := 'SELECT ISN_PRAZO,PRACN_PRAZO,PRADS_PRAZO,PRAQT_DIAS_ENTRADA,PRANR_PARCELA,PRAFG_INATIVO,PRAPR_DESCONTO, '+
            'PRAQT_INTERVALO,PRANR_MEDIO, PRAPR_ACRESCIMO '+
            'FROM T_PRAZO WHERE PRACN_PRAZO = ' + strPrazoCodigo;

  qryRegistro := TFDQuery.Create(Nil);
  qryRegistro.Connection := DmGlobal.Conn;
  qryRegistro.SQL.Add(strSQL);
  qryRegistro.Open;
  if not qryRegistro.Eof then
    begin
      intPrazoISN := qryRegistro.FieldByName('ISN_PRAZO').AsInteger;
      strPrazoCN := qryRegistro.FieldByName('PRACN_PRAZO').AsString;
      strPrazoDS := qryRegistro.FieldByName('PRADS_PRAZO').AsString;
      intPrazoDiasEntrada := qryRegistro.FieldByName('PRAQT_DIAS_ENTRADA').AsInteger;
      intPrazoParcela := qryRegistro.FieldByName('PRANR_PARCELA').AsInteger;
      strPrazoInativo := qryRegistro.FieldByName('PRAFG_INATIVO').AsString;
      dblPrazoMaxDesconto := qryRegistro.FieldByName('PRAPR_DESCONTO').AsFloat;
      intPrazoIntervalo:= qryRegistro.FieldByName('PRAQT_INTERVALO').AsInteger;
      intPrazoMedio:= qryRegistro.FieldByName('PRANR_MEDIO').AsInteger;
      intPrazoMAX:= ((intPrazoParcela-1)*intPrazoIntervalo)+ intPrazoDiasEntrada;
      dblPrazoAcrescimo:= qryRegistro.FieldByName('PRAPR_ACRESCIMO').AsFloat;
    end
  else
    begin
      intPrazoISN:=0;strPrazoCN:='';
    end;

end;

function TMonitorPedido.Prazo_Atende_TipoPed(strCodPZ,
  strIsnTipoPedido: string): boolean;
var lngIsnPZ : longint;
  qryRegistro:TFDQuery;
begin
  result := false;
  // Verifica se o Tipo de Pedido pode ser atendido com O prazo
  strSQL := 'SELECT TTPZ.ISN_TIPO_PEDIDO_PRAZO FROM T_TIPO_PEDIDO_PRAZO TTPZ ' +
            'WHERE TTPZ.ISN_TIPO_PEDIDO = ' + strIsnTipoPedido +
            ' AND ISN_PRAZO = ' + strCodPZ;
  qryRegistro := TFDQuery.Create(Nil);
  qryRegistro.Connection := DmGlobal.Conn;
  qryRegistro.SQL.Add(strSQL);
  qryRegistro.Open;
  if not qryRegistro.eof then
    result := true;
  qryRegistro.Free;
  qryRegistro := nil;

end;

function TMonitorPedido.getCargaTipoPedidoGrupo(strIsnTipoPedido:string):TFDQuery;
var qryReg:TFDQuery;
begin

  try
    strSQL := 'SELECT TPGP.ISN_TIPO_PEDIDO_GRUPO,TPGP.ISN_TIPO_PEDIDO,TPGP.ISN_GRUPO FROM T_TIPO_PEDIDO_X_GRUPO TPGP WHERE TPGP.ISN_TIPO_PEDIDO = ' + strIsnTipoPedido +
              ' AND ISN_EMPRESA = ' + intToStr(1);  //isn empresa
    qryRegistro := TFDQuery.Create(Nil);
    qryRegistro.Connection := DmGlobal.Conn;
    qryReg.SQL.Add(strSQL);
    qryReg.Open;
    if not qryReg.eof then
      begin
        result := qryReg;
        qryReg.Free;
        qryReg := nil;
      end;
  except on e:exception do
    ShowMessage('Problema ao carregar os grupos de produtos do tipo de pedido.'+e.message);

  end;

end;


function TMonitorPedido.UltrapassaLimite(strOp: string;
  fltValor, dblValorPedido, fltLimiteTotal, fltDesconto: double): boolean;
var fltSub,fltLim : double;
begin
  if strOp = '+' then
    fltSub := dblValorPedido + fltValor;

  if strOp = '-' then
    fltSub := dblValorPedido - fltValor;

  try
    fltLim := fltLimiteTotal - fltSub * (1 - fltDesconto/dblValorPedido);
  except
    fltLim := fltLimiteTotal - fltSub;
  end;

  UltrapassaLimite := (fltLim < 0);

end;

procedure TMonitorPedido.CalculaPedido(blnCliLiberado: Boolean; dblLimiteCliente, dblDesconto: Double);
var strSQL: string;
    Valor, Peso: Real;
    intIsnBloq: integer;
    qryTemp : TFDQuery;
    dblCustoPed: Double;
begin

    strSQL := 'SELECT SUM((IPEVL_UNITARIO + IPEVL_ACRESCIMO - IPEVL_DESCONTO) * IPEQT_QUANTIDADE) TOTAL ' +
              'FROM T_ITEM_PEDIDO '+
              'WHERE ISN_PEDIDO = ' + strIsnPedido;
    qryRegistro := TFDQuery.Create(Nil);
    qryRegistro.Connection := DmGlobal.Conn;
    qryTemp.SQL.Add(strSQL);
    qryTemp.Open;
    qryTemp.First;
    Valor := qryTemp.FieldByName('TOTAL').AsFloat;
    qryTemp.Free;

    //Calcula o novo peso do pedido
    strSQL:= 'SELECT SUM(IPEQT_QUANTIDADE*PRODIMP.PROVL_PESO) PESO ' +
             '  FROM T_PEDIDO PED,T_ITEM_PEDIDO IPED,T_PRODUTO PRO, T_PRODUTO_IMPOSTO PRODIMP ' +
             ' WHERE PED.ISN_PEDIDO = IPED.ISN_PEDIDO ' +
             '   AND PRO.ISN_PRODUTO = IPED.ISN_PRODUTO AND PRO.ISN_PRODUTO = PRODIMP.ISN_PRODUTO AND PED.ISN_PEDIDO = '+ strIsnPedido;

    qryRegistro := TFDQuery.Create(Nil);
    qryRegistro.Connection := DmGlobal.Conn;
    qryTemp.SQL.Add(strSQL);
    qryTemp.Open;
    qryTemp.First;
    Peso := qryTemp.FieldByName('PESO').AsFloat;
    qryTemp.Free;

    //if not objCliente.Liberado then
    if (not blnCliLiberado) then
      intIsnBloq := 1 ; // Cliente Bloqueado  - 1
    if dblLimiteCliente < 0 then
      intIsnBloq := 2; // Cliente Ultrapassou Limite de Crédito

  {  if (intIsnBloq > 0) and (TipoPedidoCupom = 'N') then
      begin
        ShowMessage('Pedido Bloqueado'+#10+#10+'Motivo: '
        + uFuncoes.Pesquisa('ISN_BLOQUEIO','BLODS_MOTIVO','T_BLOQUEIO_PEDIDO',IntToStr(intIsnBloq)));
      end;  }

    dblCustoPed := TotalCusto;

    try
      dblLimiteCliente := dblLimiteCliente -  Valor * (1 - dblDesconto/Valor);
    except
      dblLimiteCliente := dblLimiteCliente - Valor;
    end;

    //txtValor.Caption := formatfloat('##0.00', Valor);
    //txtLimite.Caption  := formatfloat('##0.00', dblLimiteCliente);


    try

      strSQL := 'UPDATE T_PEDIDO ' +
                '   SET PEDVL_TOTAL = ' + FloatToStr(strToFloat(formatfloat('##0.00', Valor))) + ',' +
                '       PEDVL_PESO = ' + FloatToStr(Peso);
      if TipoPedidoCupom = 'S' then
        strSQL := strSQL + ', ISN_BLOQUEIO = NULL'
      else if intIsnBloq > 0 then
        strSQL := strSQL + ', ISN_BLOQUEIO = '+ IntToStr(intIsnBloq);

        {
      If (dmPrinc.ObjParametro.SECKEY = 'DOZI') Then
        begin
          //txtMargem.Caption := Format('%11.2n',[((Valor - fltCustoPed) / Valor)*100]);
          strSql := strSQL + ' , PEDPR_MARGEM = '+ VirgPont(strToFloat(Format('%11.2n',[((Valor - fltCustoPed) / Valor)*100])));
        end;}

      strSQL := strSQL + ' WHERE ISN_PEDIDO = ' + strIsnPedido;

      DMGlobal.Conn.ExecSQL(strSQL);

      //limpaControles;
      FreeAndNil(DMGlobal);
    except
      raise;
    end;

end;


function TMonitorPedido.TotalCusto: double;
var dblCusto : double;
  qryTemp : TFDQuery;
begin
  dblCusto := 0;
    qryTemp := TFDQuery.Create(nil);
    qryTemp.Connection := DmGlobal.Conn;

  With qryTemp do
  begin
    if Active Then
      Close;

    strSQL := 'SELECT SUM(IPEQT_QUANTIDADE*CAST(CAST(EST.ESTVL_PRECO_CUSTO_FINAL*100 AS INTEGER) AS FLOAT)/100) FROM T_ITEM_PEDIDO IPED,T_ESTOQUE EST ' +
              ' WHERE IPED.ISN_PRODUTO = EST.ISN_PRODUTO AND ISN_PEDIDO = ' + strIsnPedido +
              ' AND EST.ISN_EMPRESA = ' + intToStr(1);  //isn_empresa

    Sql.Add(strSQL);
    Open;
    if not Fields[0].IsNull then
      dblCusto := Fields[0].AsFloat;

    Close;
  end;
  TotalCusto := dblCusto;
end;

end.
