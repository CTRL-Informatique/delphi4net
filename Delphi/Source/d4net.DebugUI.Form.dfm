object DebugUIForm: TDebugUIForm
  Left = 0
  Top = 0
  Caption = 'Delphi4Net Debug UI'
  ClientHeight = 722
  ClientWidth = 1053
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    1053
    722)
  PixelsPerInch = 96
  TextHeight = 13
  object LabelRequest: TLabel
    Left = 8
    Top = 252
    Width = 40
    Height = 13
    Caption = 'Request'
  end
  object LabelResponse: TLabel
    Left = 536
    Top = 252
    Width = 48
    Height = 13
    Caption = 'Response'
  end
  object LabelService: TLabel
    Left = 6
    Top = 6
    Width = 36
    Height = 13
    Caption = 'Service'
  end
  object LabelMethod: TLabel
    Left = 272
    Top = 6
    Width = 36
    Height = 13
    Caption = 'Method'
  end
  object LabelContext: TLabel
    Left = 6
    Top = 62
    Width = 36
    Height = 13
    Caption = 'Context'
  end
  object MemoRequest: TMemo
    Left = 8
    Top = 268
    Width = 517
    Height = 440
    Anchors = [akLeft, akTop, akBottom]
    ScrollBars = ssBoth
    TabOrder = 0
    WantTabs = True
  end
  object MemoResponse: TMemo
    Left = 536
    Top = 268
    Width = 497
    Height = 440
    Anchors = [akLeft, akTop, akBottom]
    Lines.Strings = (
      '')
    ScrollBars = ssBoth
    TabOrder = 1
    WantTabs = True
  end
  object ComboService: TComboBox
    Left = 6
    Top = 22
    Width = 251
    Height = 21
    TabOrder = 2
    OnChange = ComboServiceChange
  end
  object ComboMethod: TComboBox
    Left = 272
    Top = 22
    Width = 409
    Height = 21
    TabOrder = 3
    OnChange = ComboMethodChange
  end
  object ButtonGo: TButton
    Left = 698
    Top = 18
    Width = 75
    Height = 25
    Caption = 'Go!'
    TabOrder = 4
    OnClick = ButtonGoClick
  end
  object MemoContext: TMemo
    Left = 6
    Top = 78
    Width = 519
    Height = 146
    Anchors = [akLeft, akTop, akBottom]
    ScrollBars = ssBoth
    TabOrder = 5
    WantTabs = True
  end
  object MainMenu: TMainMenu
    Left = 822
    Top = 16
    object MenuItemFile: TMenuItem
      Caption = 'File'
      object MenuItemSaveAs: TMenuItem
        Action = ActionSaveAs
      end
    end
  end
  object ActionList: TActionList
    Left = 902
    Top = 16
    object ActionSaveAs: TAction
      Caption = 'Save As...'
      OnExecute = ActionSaveAsExecute
    end
  end
end
