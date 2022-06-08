unit d4net.Exported;

interface

uses
  d4net.Types, d4net.Dispatcher, System.SysUtils, d4net.Logging;

procedure Execute(AServiceName, AMethodName, AContextInfo, ARequestData: WideString; ASuccessProc,
   AErrorProc: TResultProc); stdcall; export;

procedure SetLogProc(AProc: TLogProc); stdcall; export;

implementation

procedure SetLogProc(AProc: TLogProc); stdcall; export;
begin
   TLog.LogProc := AProc;
end;

procedure Execute(AServiceName, AMethodName, AContextInfo, ARequestData: WideString; ASuccessProc,
   AErrorProc: TResultProc);
var
   LDispatcher: IDispatcher;
begin
   LDispatcher := OnCreateDispatcher();
   LDispatcher.DispatchRequest(AServiceName, AMethodName, AContextInfo, ARequestData, ASuccessProc, AErrorProc);
end;

end.
