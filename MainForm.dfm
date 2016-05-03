object FrmMain: TFrmMain
  Left = 455
  Top = 413
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'WinGate Authenticate'
  ClientHeight = 323
  ClientWidth = 246
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  ShowHint = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    246
    323)
  PixelsPerInch = 96
  TextHeight = 13
  object lblUser: TLabel
    Left = 32
    Top = 53
    Width = 51
    Height = 13
    Alignment = taRightJustify
    Caption = 'User name'
  end
  object lbl1: TLabel
    Left = 37
    Top = 81
    Width = 46
    Height = 13
    Alignment = taRightJustify
    Caption = 'Password'
  end
  object lbl2: TLabel
    Left = 31
    Top = 22
    Width = 52
    Height = 13
    Alignment = taRightJustify
    Caption = 'Proxy:Port'
  end
  object bvl2: TBevel
    Left = 0
    Top = 113
    Width = 254
    Height = 4
    Anchors = [akLeft, akTop, akRight]
    Shape = bsBottomLine
  end
  object lblAdvance: TButton
    Left = 16
    Top = 128
    Width = 33
    Height = 24
    Hint = 'Advanced options'
    Caption = '6'
    Font.Charset = SYMBOL_CHARSET
    Font.Color = clBlack
    Font.Height = -21
    Font.Name = 'Webdings'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    OnClick = lblAdvanceClick
  end
  object btnLogon: TButton
    Left = 111
    Top = 128
    Width = 56
    Height = 24
    Anchors = [akTop, akRight]
    Caption = '&Logon'
    Default = True
    TabOrder = 4
    OnClick = btnLogonClick
  end
  object btnLogout: TButton
    Left = 173
    Top = 128
    Width = 56
    Height = 24
    Anchors = [akTop, akRight]
    Caption = '&Logout'
    Enabled = False
    TabOrder = 5
    OnClick = btnLogoutClick
  end
  object edtUser: TEdit
    Left = 89
    Top = 49
    Width = 140
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
  end
  object edtPassword: TEdit
    Left = 89
    Top = 78
    Width = 140
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    PasswordChar = '@'
    TabOrder = 2
  end
  object edtHost: TEdit
    Left = 89
    Top = 19
    Width = 140
    Height = 21
    Hint = 'Proxy server information, Format = Host:Port'
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    Text = 'Proxy:808'
  end
  object grp1: TGroupBox
    Left = 16
    Top = 158
    Width = 213
    Height = 155
    Caption = 'Options:'
    TabOrder = 6
    DesignSize = (
      213
      155)
    object lblKey: TLabel
      Left = 15
      Top = 126
      Width = 44
      Height = 13
      Caption = 'Hot key :'
    end
    object lblCmd: TLabel
      Left = 16
      Top = 77
      Width = 127
      Height = 13
      Caption = 'Run command after logon:'
    end
    object chkAuto: TCheckBox
      Left = 15
      Top = 22
      Width = 186
      Height = 14
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Auto logon when load'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object chkAutoStart: TCheckBox
      Left = 15
      Top = 41
      Width = 186
      Height = 15
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Start when logon Windows'
      TabOrder = 1
    end
    object hkKey: THotKey
      Left = 62
      Top = 123
      Width = 96
      Height = 19
      Hint = 'Hot Key for logon/logoff'
      HotKey = 122
      Modifiers = []
      TabOrder = 3
    end
    object chkMin: TCheckBox
      Left = 15
      Top = 60
      Width = 186
      Height = 15
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Minimize when load'
      TabOrder = 2
    end
    object btnKey: TButton
      Left = 164
      Top = 123
      Width = 34
      Height = 20
      Caption = '@'
      Font.Charset = SYMBOL_CHARSET
      Font.Color = clWindowText
      Font.Height = -14
      Font.Name = 'Webdings'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      OnClick = btnKeyClick
    end
    object edtCmd: TEdit
      Left = 15
      Top = 96
      Width = 182
      Height = 21
      TabOrder = 5
      Text = 'edtCmd'
    end
  end
  object tmr1: TTimer
    Enabled = False
    Interval = 500
    OnTimer = tmr1Timer
    Left = 16
    Top = 13
  end
  object pm1: TPopupMenu
    Left = 112
    Top = 77
    object About1: TMenuItem
      Caption = 'About...'
      OnClick = About1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object ShowMainForm1: TMenuItem
      Caption = 'Show window'
      OnClick = ShowMainForm1Click
    end
    object LogonLogoff1: TMenuItem
      Caption = 'Logon / Logoff'
      Default = True
      OnClick = LogonLogoff1Click
    end
    object Exit1: TMenuItem
      Caption = 'Exit'
      OnClick = Exit1Click
    end
  end
end
