object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Alt'#305'n Fiyat Ar'#351'ivi  (Delphi 12)'
  ClientHeight = 348
  ClientWidth = 414
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object lbStartDate: TLabel
    Left = 24
    Top = 8
    Width = 183
    Height = 28
    Caption = 'Ba'#351'lang'#305#231' Zaman'#305' : '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lbEndDate: TLabel
    Left = 21
    Top = 96
    Width = 118
    Height = 28
    Caption = 'Biti'#351' Zaman'#305
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Button1: TButton
    Left = 21
    Top = 208
    Width = 379
    Height = 113
    Caption = 'Verileri Csv Dosyas'#305' Olarak Kaydet'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnClick = Button1Click
  end
  object dtpStartDate: TDateTimePicker
    Left = 24
    Top = 42
    Width = 186
    Height = 45
    Date = 45876.000000000000000000
    Time = 0.812609050924948000
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
  object dtpEndDate: TDateTimePicker
    Left = 21
    Top = 130
    Width = 186
    Height = 45
    Date = 45876.000000000000000000
    Time = 0.812609050924948000
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
  end
  object Memo1: TMemo
    Left = 216
    Top = 42
    Width = 185
    Height = 133
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = []
    Lines.Strings = (
      'CSV Dosyas'#305' '
      'uygulaman'#305'n '
      'bulundu'#287'u Data '
      'Klas'#246'r'#252'n'#252'n '
      'i'#231'erisine kaydedilecektir.')
    ParentFont = False
    TabOrder = 3
  end
  object LinkLabel1: TLinkLabel
    Left = 24
    Top = 183
    Width = 279
    Height = 21
    Caption = 'https://www.linkedin.com/in/mesutdemirci/'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    OnLinkClick = LinkLabel1LinkClick
  end
  object OpenDialog1: TOpenDialog
    Left = 640
    Top = 416
  end
end
