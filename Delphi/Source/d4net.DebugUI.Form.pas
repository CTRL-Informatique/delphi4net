unit d4net.DebugUI.Form;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, System.IniFiles, Vcl.Menus,
  System.Actions, Vcl.ActnList, d4net.Json;

type
   TRequestData = class
   strict private
      FContext: string;
      FMethod: string;
      FRequest: string;
      FService: string;
   public
      property Context: string read FContext write FContext;
      property Method: string read FMethod write FMethod;
      property Request: string read FRequest write FRequest;
      property Service: string read FService write FService;
   end;

  TDebugUIForm = class(TForm)
    MemoRequest: TMemo;
    MemoResponse: TMemo;
    LabelRequest: TLabel;
    LabelResponse: TLabel;
    ComboService: TComboBox;
    LabelService: TLabel;
    LabelMethod: TLabel;
    ComboMethod: TComboBox;
    ButtonGo: TButton;
    MemoContext: TMemo;
    LabelContext: TLabel;
    MainMenu: TMainMenu;
    MenuItemFile: TMenuItem;
    MenuItemSaveAs: TMenuItem;
    ActionList: TActionList;
    ActionSaveAs: TAction;
    procedure ButtonGoClick(Sender: TObject);
    procedure ComboMethodChange(Sender: TObject);
    procedure ComboServiceChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ActionSaveAsExecute(Sender: TObject);
  strict private const
   TAB_WIDTH = 8;
   VALUES = 'Values';
  strict private
    FData: TRequestData;
    procedure UpdateRequest;
    procedure UpdateMethods;
  strict protected
    function GetContextClass: TClass;
  public
    destructor Destroy; override;
  end;

procedure HandleResult(AResult: WideString); stdcall;

var
  DebugUIForm: TDebugUIForm;
  JsonSerializer: IJsonSerializer;
  ContextClass: TClass;

implementation

uses
  d4net.Dispatcher, System.Rtti, REST.Json, System.JSON, System.IOUtils, d4net.Exported;

{$R *.dfm}

function FormatJson(AJson: string): string;
var
   LJson: TJsonValue;
begin
   LJson := TJsonObject.ParseJSONValue(AJson);

   try
      Result := TJSON.Format(LJson);
   finally
      LJson.Free;
   end;
end;

procedure HandleResult(AResult: WideString);
begin
   if AResult <> '' then
      DebugUIForm.MemoResponse.Text := FormatJson(AResult)
   else
      DebugUIForm.MemoResponse.Clear;
end;

destructor TDebugUIForm.Destroy;
begin
   FreeAndNil(FData);
   inherited Destroy;
end;

procedure TDebugUIForm.ButtonGoClick(Sender: TObject);
var
   LJson: string;
begin
   FData.Context := MemoContext.Text;
   FData.Request := MemoRequest.Text;
   FData.Service := ComboService.Text;
   FData.Method := ComboMethod.Text;
   LJson := JsonSerializer.Serialize(FData);
   TFile.WriteAllText('LastRequest.json', LJson);
   Execute(ComboService.Text, ComboMethod.Text, MemoContext.Text, MemoRequest.Text, HandleResult, HandleResult);
end;

procedure TDebugUIForm.ComboMethodChange(Sender: TObject);
begin
   UpdateRequest;
end;

procedure TDebugUIForm.ComboServiceChange(Sender: TObject);
begin
   UpdateMethods;
   UpdateRequest;
end;

procedure TDebugUIForm.FormCreate(Sender: TObject);
var
   LTabWidth: Integer;
   LLastRequestJson: string;
   LContextInstance: TObject;
begin
   FData := TRequestData.Create;
   ComboService.Items.AddStrings(TDispatcher.ListServiceNames);

   if FileExists('LastRequest.json') then
   begin
      LLastRequestJson := TFile.ReadAllText('LastRequest.json');
      JsonSerializer.Deserialize(LLastRequestJson, FData);
      MemoContext.Text := FData.Context;
      MemoRequest.Text := FData.Request;
      ComboService.Text := FData.Service;
      UpdateMethods;
      ComboMethod.Text := FData.Method;
   end
   else
   begin
      LContextInstance := GetContextClass.Create;
      try
         MemoContext.Text := FormatJson(JsonSerializer.Serialize(LContextInstance));
      finally
         LContextInstance.Free;
      end;
   end;

   LTabWidth := TAB_WIDTH;
   SendMessage(MemoRequest.Handle, EM_SETTABSTOPS, 1, Longint(@LTabWidth));
   SendMessage(MemoContext.Handle, EM_SETTABSTOPS, 1, Longint(@LTabWidth));
end;

function TDebugUIForm.GetContextClass: TClass;
begin
   if Assigned(ContextClass) then
      Result := ContextClass
   else
      Result := TObject;
end;

procedure TDebugUIForm.ActionSaveAsExecute(Sender: TObject);
begin
   //
end;

procedure TDebugUIForm.UpdateMethods;
begin
   ComboMethod.Items.Clear;
   ComboMethod.Items.AddStrings(TDispatcher.ListMethodNames(ComboService.Text));
   ComboMethod.ItemIndex := 0;
end;

procedure TDebugUIForm.UpdateRequest;
var
   LClass: TClass;
   LInstance: TObject;
begin
   MemoRequest.Clear;
   LClass := TDispatcher.GetRequestDataClass(ComboService.Text, ComboMethod.Text);

   if LClass = nil then
      Exit;

   with TRttiContext.Create do
   try
      LInstance := GetType(LClass).GetMethod('Create').Invoke(LClass, []).AsObject;
   finally
      Free;
   end;

   try
      MemoRequest.Text := FormatJson(JsonSerializer.Serialize(LInstance));
   finally
      LInstance.Free;
   end;
end;

end.
