unit d4net.Logging;

interface

uses
  System.SysUtils;
  
type
   TLogLevel = (Error, Warn, Info, Debug);
   TLogProc = procedure(ALevel: Word; AMessage: WideString); stdcall;

   ILogger = interface
      ['{85CA8D6A-A74A-4934-8B3A-301944A03B7C}']
      procedure Error(AMessage: string); overload;
      procedure Error(AException: Exception); overload;
      procedure Warn(AMessage: string);
      procedure Info(AMessage: string);
      procedure Debug(AMessage: string);
   end;

   TLogger = class(TInterfacedObject, ILogger)
   strict private
      class procedure Log(ALevel: TLogLevel; AMessage: string);
   public
      procedure Error(AMessage: string); overload;
      procedure Error(AException: Exception); overload;
      procedure Warn(AMessage: string);
      procedure Info(AMessage: string);
      procedure Debug(AMessage: string);
   end;

var
   LogProc: TLogProc;
   Logger: ILogger;

implementation

uses
  Winapi.Windows;

function GetDllPath: String;
var
  mNam: array[0..MAX_PATH] of char;
  aNam: Integer;
begin
  FillChar(mNam, sizeof(mNam), #0);
  aNam := GetModuleFileName(hInstance, mNam, sizeof(mNam));
  Result := Copy(mNam, 0, aNam);
end;

function GetDllName: string;
begin
   Result := ExtractFileName(GetDllPath);
end;

{ TLogger }

procedure TLogger.Debug(AMessage: string);
begin
   Log(TLogLevel.Debug, AMessage);
end;

procedure TLogger.Error(AException: Exception);
begin
   Log(TLogLevel.Error, AException.Message + sLineBreak + AException.StackTrace);
end;

procedure TLogger.Error(AMessage: string);
begin
   Log(TLogLevel.Error, AMessage);
end;

procedure TLogger.Info(AMessage: string);
begin
   Log(TLogLevel.Info, AMessage);
end;

class procedure TLogger.Log(ALevel: TLogLevel; AMessage: string);
begin
   if Assigned(LogProc) then
   try
      LogProc(Ord(ALevel), '[' + GetDllName + '] ' + AMessage);
   except
   end;
end;

procedure TLogger.Warn(AMessage: string);
begin
   Log(TLogLevel.Warn, AMessage);
end;

initialization
   Logger := TLogger.Create;

end.
