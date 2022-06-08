unit d4net.Logging.Default;

interface

uses
  d4net.Logging, System.SysUtils;

type
   TDefaultLogger = class(TInterfacedObject, ILogger)
   strict private const TAG = '[D4Net]';
   strict private
      procedure Debug(AMessage: string);
      procedure Error(AMessage: string); overload;
      procedure Error(AException: Exception); overload;
      procedure Info(AMessage: string);
      procedure Warn(AMessage: string);
      class procedure Log(ALevel: TLogLevel; AMessage: string);
   end;

implementation

class procedure TDefaultLogger.Log(ALevel: TLogLevel; AMessage: string);
begin
   if Assigned(TLog.LogProc) then
   try
      TLog.LogProc(Ord(ALevel), TAG + ' ' + AMessage);
   except
   end;
end;

procedure TDefaultLogger.Debug(AMessage: string);
begin
   Log(TLogLevel.Debug, AMessage);
end;

procedure TDefaultLogger.Error(AMessage: string);
begin
   Log(TLogLevel.Error, AMessage);
end;

procedure TDefaultLogger.Error(AException: Exception);
begin
   Error(AException.Message + sLineBreak + AException.StackTrace);
end;

procedure TDefaultLogger.Info(AMessage: string);
begin
   Log(TLogLevel.Info, AMessage);
end;

procedure TDefaultLogger.Warn(AMessage: string);
begin
   Log(TLogLevel.Warn, AMessage);
end;

end.
