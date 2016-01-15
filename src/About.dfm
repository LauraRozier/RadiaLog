object aboutForm: TaboutForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'About'
  ClientHeight = 265
  ClientWidth = 313
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 297
    Height = 113
    Caption = 'RadiaLog'
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 24
      Width = 42
      Height = 13
      Caption = 'Version: '
    end
    object Label2: TLabel
      Left = 16
      Top = 43
      Width = 44
      Height = 13
      Caption = 'Creator: '
    end
    object Label3: TLabel
      Left = 16
      Top = 62
      Width = 46
      Height = 13
      Caption = 'Website: '
    end
    object Label4: TLabel
      Left = 16
      Top = 81
      Width = 35
      Height = 13
      Caption = 'E-mail: '
    end
    object Label5: TLabel
      Left = 68
      Top = 43
      Width = 62
      Height = 13
      Caption = 'Thimo Braker'
    end
    object Label6: TLabel
      Left = 68
      Top = 62
      Width = 164
      Height = 13
      Cursor = crHandPoint
      Caption = 'http://www.thibmoprograms.com/'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHighlight
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsUnderline]
      ParentFont = False
      OnClick = websiteLinkClick
    end
    object Label7: TLabel
      Left = 68
      Top = 81
      Width = 116
      Height = 13
      Cursor = crHandPoint
      Caption = 'thibmorozier@gmail.com'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHighlight
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsUnderline]
      ParentFont = False
      OnClick = Label7Click
    end
    object lblVersion: TLabel
      Left = 68
      Top = 24
      Width = 26
      Height = 13
      Caption = '0.0.1'
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 136
    Width = 297
    Height = 121
    Caption = 'Credits'
    TabOrder = 1
    object Label10: TLabel
      Left = 16
      Top = 24
      Width = 130
      Height = 13
      Caption = 'TurboPack AsyncPro - 4.06'
    end
    object Label11: TLabel
      Left = 40
      Top = 43
      Width = 99
      Height = 13
      Caption = 'Serial communication'
    end
    object Label12: TLabel
      Left = 16
      Top = 72
      Width = 120
      Height = 13
      Caption = 'Cindy components - 7.05'
    end
    object Label13: TLabel
      Left = 40
      Top = 91
      Width = 139
      Height = 13
      Caption = 'Led button and Simple gauge'
    end
  end
end
