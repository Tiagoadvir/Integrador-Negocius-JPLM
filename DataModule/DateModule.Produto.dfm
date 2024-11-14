object DmProduto: TDmProduto
  OnCreate = DataModuleCreate
  Height = 150
  Width = 215
  object qryProduto: TFDQuery
    Connection = DmGlobal.Conn
    Left = 32
    Top = 24
  end
  object EventAlerter: TFDEventAlerter
    Connection = DmGlobal.Conn
    Names.Strings = (
      'estoque_fiscal_disponivel_alterado')
    Options.AutoRegister = True
    OnAlert = EventAlerterAlert
    Left = 136
    Top = 16
  end
end
