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

   TLog = class
   strict private
      class var FLogProc: TLogProc;
      class procedure Log(ALevel: TLogLevel; AMessage: string);
      class function Tag: string;
   public
      class procedure Error(AMessage: string); overload;
      class procedure Error(AException: Exception); overload;
      class procedure Warn(AMessage: string);
      class procedure Info(AMessage: string);
      class procedure Debug(AMessage: string);
      class property LogProc: TLogProc read FLogProc write FLogProc;
   end;

implementation

{ TLog }

class procedure TLog.Debug(AMessage: string);
begin
   Log(TLogLevel.Debug, AMessage);
end;

class procedure TLog.Error(AException: Exception);
begin
   Log(TLogLevel.Error, AException.Message + sLineBreak + AException.StackTrace);
end;

class procedure TLog.Error(AMessage: string);
begin
   Log(TLogLevel.Error, AMessage);
end;

class procedure TLog.Info(AMessage: string);
begin
   Log(TLogLevel.Info, AMessage);
end;

class procedure TLog.Log(ALevel: TLogLevel; AMessage: string);
begin
   if Assigned(FLogProc) then
   try
      FLogProc(Ord(ALevel), Tag + ' ' + AMessage);
   except
   end;
end;

class function TLog.Tag: string;
begin
  // TODO Pouvoir customiser le tag
  Result := '[' + 'TAG' + ']';
end;

class procedure TLog.Warn(AMessage: string);
begin
   Log(TLogLevel.Warn, AMessage);
end;

end.
