unit d4net.Logging.Fake;

interface

uses
  d4net.Logging, System.SysUtils, System.Classes;

type
   TFakeLogger = class(TInterfacedPersistent, ILogger)
   strict private
      procedure Debug(AMessage: string);
      procedure Error(AMessage: string); overload;
      procedure Error(AException: Exception); overload;
      procedure Info(AMessage: string);
      procedure Warn(AMessage: string);
   public
      ErrorCallCount: Integer;
      constructor Create;
   end;

implementation

constructor TFakeLogger.Create;
begin
   inherited;
   ErrorCallCount := 0;
end;

procedure TFakeLogger.Debug(AMessage: string);
begin
   //TODO
end;

procedure TFakeLogger.Error(AMessage: string);
begin
   Inc(ErrorCallCount);
end;

procedure TFakeLogger.Error(AException: Exception);
begin
   Inc(ErrorCallCount);
end;

procedure TFakeLogger.Info(AMessage: string);
begin
   //TODO
end;

procedure TFakeLogger.Warn(AMessage: string);
begin
   //TODO
end;

end.
