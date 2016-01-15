object mainForm: TmainForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'RadiaLog'
  ClientHeight = 562
  ClientWidth = 784
  Color = clBtnFace
  Constraints.MaxHeight = 600
  Constraints.MaxWidth = 800
  Constraints.MinHeight = 600
  Constraints.MinWidth = 800
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object fPageControl: TPageControl
    Left = 0
    Top = 0
    Width = 784
    Height = 543
    ActivePage = tabMain
    Align = alClient
    TabOrder = 0
    object tabMain: TTabSheet
      Caption = 'Main'
      object ScrollBox1: TScrollBox
        Left = 0
        Top = 0
        Width = 776
        Height = 515
        Align = alClient
        TabOrder = 0
        object fStatusLed: TcyLed
          Left = 346
          Top = 455
          Width = 33
          Height = 33
          Hint = 'Start/Stop counter'
          ShowHint = True
          OnClick = fStatusLedClick
          LedValue = False
          Bevels = <
            item
              HighlightColor = clBlack
              ShadowColor = clBlack
            end
            item
              Width = 3
            end
            item
              Style = bcLowered
            end
            item
              HighlightColor = clBlack
              ShadowColor = clBlack
            end>
          LedColorOn = clLime
          LedColorOff = clGreen
          LedColorDisabled = 22963
          ShapeLedColorOn = clGreen
          ShapeLedColorOff = 16384
          ShapeLedColorDisabled = 13416
        end
        object fCPMBar: TcySimpleGauge
          Left = 15
          Top = 394
          Width = 363
          Height = 33
          DegradeBalance = 50
          ItemOffBrush.Color = clGray
          ItemOnBrush.Color = clLime
          ItemOnPen.Color = clGreen
          ItemsCount = 32
          ItemsHeight = 21
          Max = 200.000000000000000000
          Smooth = True
          Bevels = <
            item
              HighlightColor = clBlack
              ShadowColor = clBlack
            end
            item
              Width = 3
            end
            item
              Style = bcLowered
            end
            item
              HighlightColor = clBlack
              ShadowColor = clBlack
            end>
          Step = 1.000000000000000000
        end
        object Label4: TLabel
          Left = 264
          Top = 460
          Width = 76
          Height = 19
          Caption = 'Counter: '
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Label12: TLabel
          Left = 15
          Top = 369
          Width = 47
          Height = 19
          Caption = 'CPM: '
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblCPM: TLabel
          Left = 68
          Top = 369
          Width = 10
          Height = 19
          Caption = '0'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblSvR: TLabel
          Left = 15
          Top = 460
          Width = 118
          Height = 19
          Caption = '0.00000 '#181'Sv/h'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object fLogoImage: TImage
          Left = 400
          Top = 13
          Width = 361
          Height = 166
          Hint = 'Show information about this application.'
          ParentShowHint = False
          ShowHint = True
          OnClick = fBtnAboutClick
        end
        object GroupBox1: TGroupBox
          Left = 15
          Top = 13
          Width = 364
          Height = 108
          Margins.Left = 5
          Margins.Top = 5
          Margins.Right = 5
          Margins.Bottom = 5
          Caption = 'Serial Settings'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          object Label1: TLabel
            Left = 10
            Top = 23
            Width = 72
            Height = 14
            Margins.Left = 10
            Margins.Top = 5
            Caption = 'Serial port: '
          end
          object Label5: TLabel
            Left = 10
            Top = 51
            Width = 72
            Height = 14
            Caption = 'Baud Rate: '
          end
          object Label6: TLabel
            Left = 10
            Top = 79
            Width = 44
            Height = 14
            Caption = 'Parity: '
          end
          object Label7: TLabel
            Left = 202
            Top = 23
            Width = 64
            Height = 14
            Caption = 'Data bits: '
          end
          object Label8: TLabel
            Left = 201
            Top = 51
            Width = 65
            Height = 14
            Caption = 'Stop bits: '
          end
          object comPortBox: TComboBox
            Left = 88
            Top = 20
            Width = 99
            Height = 22
            Margins.Top = 20
            Style = csDropDownList
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 0
            OnChange = edtChange
          end
          object comBaudBox: TComboBox
            Left = 88
            Top = 48
            Width = 99
            Height = 22
            Style = csDropDownList
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = []
            ItemIndex = 2
            ParentFont = False
            TabOrder = 1
            Text = '2400'
            OnChange = edtChange
            Items.Strings = (
              '300'
              '1200'
              '2400'
              '4800'
              '9600'
              '14400'
              '19200'
              '28800'
              '38400'
              '57600'
              '115200'
              '230400')
          end
          object comParityBox: TComboBox
            Left = 88
            Top = 76
            Width = 99
            Height = 22
            Style = csDropDownList
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = []
            ItemIndex = 0
            ParentFont = False
            TabOrder = 2
            Text = 'None'
            OnChange = edtChange
            Items.Strings = (
              'None'
              'Odd'
              'Even'
              'Mark'
              'Space')
          end
          object comDataBitsBox: TComboBox
            Left = 272
            Top = 20
            Width = 81
            Height = 22
            Style = csDropDownList
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = []
            ItemIndex = 3
            ParentFont = False
            TabOrder = 3
            Text = '8'
            OnChange = edtChange
            Items.Strings = (
              '5'
              '6'
              '7'
              '8'
              '9')
          end
          object comStopBitsBox: TComboBox
            Left = 272
            Top = 48
            Width = 81
            Height = 22
            Style = csDropDownList
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = []
            ItemIndex = 0
            ParentFont = False
            TabOrder = 4
            Text = '1'
            OnChange = edtChange
            Items.Strings = (
              '1'
              '1.5'
              '2')
          end
        end
        object GroupBox2: TGroupBox
          Left = 15
          Top = 137
          Width = 364
          Height = 108
          Caption = 'User Settings'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 1
          object Label9: TLabel
            Left = 10
            Top = 23
            Width = 67
            Height = 14
            Margins.Left = 10
            Margins.Top = 5
            Caption = 'Username: '
          end
          object Label10: TLabel
            Left = 10
            Top = 51
            Width = 67
            Height = 14
            Margins.Left = 10
            Margins.Top = 5
            Caption = 'Password: '
          end
          object Label11: TLabel
            Left = 10
            Top = 78
            Width = 105
            Height = 14
            Margins.Left = 10
            Margins.Top = 5
            Caption = 'Radmon Upload: '
          end
          object edtUsername: TEdit
            Left = 121
            Top = 20
            Width = 232
            Height = 22
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 0
            OnChange = edtChange
          end
          object edtPassword: TEdit
            Left = 121
            Top = 48
            Width = 232
            Height = 22
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            PasswordChar = #8226
            TabOrder = 1
            OnChange = edtChange
          end
          object chkBoxRadmon: TCheckBox
            Left = 121
            Top = 77
            Width = 97
            Height = 17
            Caption = 'Enabled'
            Checked = True
            State = cbChecked
            TabOrder = 2
            OnClick = chkBoxClick
          end
        end
        object GroupBox3: TGroupBox
          Left = 15
          Top = 261
          Width = 364
          Height = 81
          Caption = 'Conversation'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 2
          object Label13: TLabel
            Left = 10
            Top = 24
            Width = 46
            Height = 14
            Caption = 'Factor: '
          end
          object Label15: TLabel
            Left = 10
            Top = 50
            Width = 65
            Height = 14
            Margins.Left = 10
            Margins.Top = 5
            Caption = 'Unit type: '
          end
          object chkBoxUnitType: TCheckBox
            Left = 81
            Top = 49
            Width = 72
            Height = 17
            Hint = 'Hint hint'
            Caption = #181'R/h'
            ParentShowHint = False
            ShowHint = True
            TabOrder = 0
            OnClick = chkBoxClick
          end
          object edtFactor: TThimoFloatEdit
            Left = 81
            Top = 21
            Width = 72
            Height = 22
            DecimalSeparator = ','
            Value = 0.005700000000000000
            TabOrder = 1
            Text = '0,0057'
            OnChange = edtChange
          end
        end
        object GroupBox4: TGroupBox
          Left = 472
          Top = 229
          Width = 217
          Height = 268
          Caption = 'Common conversion factors'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 3
          object lblTubes: TLabel
            Left = 16
            Top = 24
            Width = 49
            Height = 16
            Caption = 'SBM-20'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblFactors: TLabel
            Left = 160
            Top = 24
            Width = 44
            Height = 16
            Caption = '0.0057'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
          end
        end
      end
    end
    object tabLog: TTabSheet
      Caption = 'Log'
      ImageIndex = 1
      object ScrollBox3: TScrollBox
        Left = 0
        Top = 0
        Width = 776
        Height = 515
        Align = alClient
        TabOrder = 0
        DesignSize = (
          772
          511)
        object Label2: TLabel
          Left = 10
          Top = 10
          Width = 45
          Height = 13
          Margins.Left = 10
          Margins.Top = 10
          Caption = 'CPM Log:'
        end
        object Label3: TLabel
          Left = 10
          Top = 255
          Width = 52
          Height = 13
          Margins.Left = 10
          Margins.Top = 10
          Caption = 'Event Log:'
        end
        object fCPMEdit: TRichEdit
          Left = 10
          Top = 29
          Width = 632
          Height = 210
          Margins.Left = 10
          Margins.Right = 10
          Anchors = [akLeft, akTop, akRight]
          Font.Charset = ANSI_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          HideScrollBars = False
          Constraints.MinHeight = 120
          Constraints.MinWidth = 400
          ParentFont = False
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 0
          Zoom = 100
        end
        object fErrorEdit: TRichEdit
          Left = 10
          Top = 274
          Width = 632
          Height = 227
          Margins.Left = 10
          Margins.Right = 10
          Margins.Bottom = 10
          Anchors = [akLeft, akTop, akRight]
          Font.Charset = ANSI_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          HideScrollBars = False
          Constraints.MinHeight = 120
          Constraints.MinWidth = 400
          ParentFont = False
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 1
          Zoom = 100
        end
      end
    end
    object tabGraph: TTabSheet
      Caption = 'Graph'
      ImageIndex = 2
      object ScrollBox2: TScrollBox
        Left = 0
        Top = 0
        Width = 776
        Height = 515
        Align = alClient
        TabOrder = 0
        object fCPMChart: TChart
          Left = 0
          Top = 0
          Width = 772
          Height = 511
          Legend.TextStyle = ltsRightValue
          Legend.Title.Text.Strings = (
            'CPM')
          Title.Font.Color = clGreen
          Title.Font.Style = [fsBold]
          Title.Text.Strings = (
            'CPM Chart')
          BottomAxis.Automatic = False
          BottomAxis.AutomaticMaximum = False
          BottomAxis.AutomaticMinimum = False
          BottomAxis.LabelsAngle = 270
          BottomAxis.LabelsFormat.ShapeStyle = fosRoundRectangle
          BottomAxis.LabelsFormat.Margins.Left = 0
          BottomAxis.LabelsFormat.Margins.Top = 0
          BottomAxis.LabelsFormat.Margins.Right = 0
          BottomAxis.LabelsFormat.Margins.Bottom = 0
          BottomAxis.LabelsFormat.Margins.Units = maPercentSize
          BottomAxis.LabelsSize = 50
          BottomAxis.Maximum = 100.000000000000000000
          BottomAxis.Title.Caption = 'Periods'
          BottomAxis.Title.Font.Style = [fsBold]
          BottomAxis.Title.Position = tpStart
          Chart3DPercent = 14
          LeftAxis.Automatic = False
          LeftAxis.AutomaticMaximum = False
          LeftAxis.AutomaticMinimum = False
          LeftAxis.Maximum = 200.000000000000000000
          LeftAxis.Title.Caption = 'CPM'
          LeftAxis.Title.Font.Style = [fsBold]
          Panning.MouseWheel = pmwNone
          Zoom.MouseWheel = pmwNormal
          Align = alClient
          TabOrder = 0
          DefaultCanvas = 'TTeeCanvas3D'
          PrintMargins = (
            15
            17
            15
            17)
          ColorPaletteIndex = 17
          object Series1: TFastLineSeries
            Title = 'CPM Chart'
            LinePen.Color = 16711842
            LinePen.Width = 3
            XValues.Name = 'X'
            XValues.Order = loAscending
            YValues.Name = 'Y'
            YValues.Order = loNone
            Data = {
              02650000000000000000000000000000200000000000000000FFFFFF1F000000
              0000000000FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF
              1F0000000000000000FFFFFF1F0000000000000000FFFFFF1F00000000000000
              00FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF1F000000
              0000000000FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF
              1F0000000000000000FFFFFF1F0000000000000000FFFFFF1F00000000000000
              00FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF1F000000
              0000000000FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF
              1F0000000000000000FFFFFF1F0000000000000000FFFFFF1F00000000000000
              00FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF1F000000
              0000000000FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF
              1F0000000000000000FFFFFF1F0000000000000000FFFFFF1F00000000000000
              00FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF1F000000
              0000000000FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF
              1F0000000000000000FFFFFF1F0000000000000000FFFFFF1F00000000000000
              00FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF1F000000
              0000000000FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF
              1F0000000000000000FFFFFF1F0000000000000000FFFFFF1F00000000000000
              00FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF1F000000
              0000000000FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF
              1F0000000000000000FFFFFF1F0000000000000000FFFFFF1F00000000000000
              00FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF1F000000
              0000000000FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF
              1F0000000000000000FFFFFF1F0000000000000000FFFFFF1F00000000000000
              00FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF1F000000
              0000000000FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF
              1F0000000000000000FFFFFF1F0000000000000000FFFFFF1F00000000000000
              00FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF1F000000
              0000000000FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF
              1F0000000000000000FFFFFF1F0000000000000000FFFFFF1F00000000000000
              00FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF1F000000
              0000000000FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF
              1F0000000000000000FFFFFF1F0000000000000000FFFFFF1F00000000000000
              00FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF1F000000
              0000000000FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF
              1F0000000000000000FFFFFF1F0000000000000000FFFFFF1F00000000000000
              00FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF1F000000
              0000000000FFFFFF1F0000000000000000FFFFFF1F0000000000000000FFFFFF
              1F}
          end
        end
      end
    end
  end
  object fStatusBar: TStatusBar
    Left = 0
    Top = 543
    Width = 784
    Height = 19
    Panels = <
      item
        Text = 'Last uploaded: 0'
        Width = 150
      end>
  end
  object fMainTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = fMainTimerTimer
    Left = 760
  end
  object fComPort: TApdComPort
    Baud = 2400
    AutoOpen = False
    TraceName = 'APRO.TRC'
    LogName = 'APRO.LOG'
    Left = 704
  end
  object fNetTimer: TTimer
    Enabled = False
    Interval = 60000
    OnTimer = fNetTimerTimer
    Left = 732
  end
end
