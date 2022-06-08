unit d4net.Execute;

interface

uses
  d4net.Types, d4net.Dispatcher, System.SysUtils;

type
   TDispatcher<T: class, constructor> = class(d4net.Dispatcher.TDispatcher<T>);

procedure Execute(AServiceName, AMethodName, AContextInfo, ARequestData: WideString; ASuccessProc, AErrorProc:
    TResultProc); stdcall;

var
   OnCreateDispatcher: TFunc<IDispatcher>;

implementation

threadvar
   Dispatcher: IDispatcher;

procedure Execute(AServiceName, AMethodName, AContextInfo, ARequestData: WideString; ASuccessProc,
   AErrorProc: TResultProc);
begin
   Dispatcher := OnCreateDispatcher();

   try
      Dispatcher.DispatchRequest(AServiceName, AMethodName, AContextInfo, ARequestData, ASuccessProc, AErrorProc);
   finally
      Dispatcher := nil;
   end;
end;

end.
