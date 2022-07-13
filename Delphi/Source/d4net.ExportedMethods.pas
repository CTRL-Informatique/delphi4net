unit d4net.ExportedMethods;

interface

uses
  d4net.Dispatcher, System.SysUtils, d4net.Logging;

procedure Execute(AServiceName, AMethodName, AContextInfo, ARequestData: WideString; ASuccessProc,
   AErrorProc: TResultProc); stdcall; export;

procedure SetLogProc(AProc: TLogProc); stdcall; export;

implementation

procedure SetLogProc(AProc: TLogProc); stdcall; export;
begin
   LogProc := AProc;
end;

procedure Execute(AServiceName, AMethodName, AContextInfo, ARequestData: WideString; ASuccessProc,
   AErrorProc: TResultProc);
begin
   Dispatcher.DispatchRequest(AServiceName, AMethodName, AContextInfo, ARequestData, ASuccessProc, AErrorProc);
end;

end.
