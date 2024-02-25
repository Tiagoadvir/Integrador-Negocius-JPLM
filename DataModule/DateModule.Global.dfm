object DmGlobal: TDmGlobal
  OnCreate = DataModuleCreate
  Height = 167
  Width = 338
  object Conn: TFDConnection
    Params.Strings = (
      'User_Name=sysdba'
      'Password=masterkey'
      'Protocol=TCPIP'
      'DriverID=FB')
    UpdateOptions.AssignedValues = [uvLockWait]
    UpdateOptions.LockWait = True
    LoginPrompt = False
    BeforeConnect = ConnBeforeConnect
    Left = 32
    Top = 24
  end
  object FDPhysFBDriverLink: TFDPhysFBDriverLink
    Left = 136
    Top = 24
  end
  object Transacoes: TFDTransaction
    Connection = Conn
    Left = 136
    Top = 80
  end
end
