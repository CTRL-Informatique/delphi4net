unit d4net.Dispatcher.Tests;

interface

uses
  DUnitX.TestFramework, d4net.Dispatcher, System.SysUtils, d4net.ServiceBase, d4net.Logging.Fake;

type
   TMyContext = class
   strict private
      FMyValue: string;
   public
      property MyValue: string read FMyValue write FMyValue;
   end;

   TMyRequestData = class
   strict private
      FMyValue: string;
   public
      property MyValue: string read FMyValue write FMyValue;
   end;

   TMyResultData = class
   strict private
      FMyValue: string;
   public
      property MyValue: string read FMyValue write FMyValue;
   end;

   [RegisterService]
   TMyService = class(TServiceBase<TMyContext>)
   public
      procedure MethodWithTwoParameters(AParam1, AParam2: TObject);
      procedure MethodWithParameterNotOfInstanceType(AParam: string);
      function MethodWithResultNotOfInstanceType: string;
      procedure ValidMethodWithNoResultType(ARequest: TMyRequestData);
      function ValidMethodWithResultType: TMyResultData;
      procedure ValidMethod;
   end;

   TMyDispatcher = class(TDispatcher<TMyContext>)
   strict protected
      procedure BeforeRequest(AContext: TMyContext); override;
      procedure AfterRequest; override;
   end;

   [TestFixture]
   TDispatcherTests = class
   public
      [SetUp]
      procedure SetUp;
      [TearDown]
      procedure TearDown;
      [Test]
      procedure RaisesServiceNotFoundWhenServiceIsNotRegistered;
      [Test]
      procedure RaisesMethodNotFoundWhenMethodDoesntExist;
      [Test]
      procedure RaisesInvalidMethodSignatureWhenMethodHasMoreThanOneParameter;
      [Test]
      procedure RaisesInvalidMethodSignatureWhenMethodHasParameterNotOfInstanceType;
      [Test]
      procedure RaisesInvalidMethodSignatureWhenResultIsNotInstanceType;
      [Test]
      procedure ValidMethodCalledWithCorrectRequestData;
      [Test]
      procedure ContextDataIsAvailable;
      [Test]
      procedure ValidMethodWithResultTypeReturnsResultData;
      [Test]
      procedure MethodNotCalledWhenBeforeRequestRaises;
      [Test]
      procedure MethodCalledWhenAfterRequestRaises;
      [Test]
      procedure ErrorLoggedWhenAfterRequestRaises;
      [Test]
      procedure ConsideredSuccessWhenAfterRequestRaises;
      [Test]
      procedure ErrorLoggedWhenSuccessProcInvocationFails;
      [Test]
      procedure ErrorLoggedWhenErrorProcInvocationFails;
      [Test]
      procedure ErrorNotLoggedWhenMethodRaises;
      [Test]
      procedure ErrorNotLoggedWhenBeforeRequestRaises;
      [Test]
      procedure FailureProcCalledWhenBeforeRequestRaises;
      [Test]
      procedure FailureProcNotCalledWhenAfterRequestRaises;
   end;

procedure HandleSuccess(AData: WideString); stdcall;
procedure HandleFailure(AData: WideString); stdcall;

var
   ErrorInfo: TErrorInfo;
   ResultData: TMyResultData;
   RequestValue: string;
   ContextValue: string;
   FakeLogger: TFakeLogger;
   AfterRequestRaises: Boolean;
   BeforeRequestRaises: Boolean;
   ValidMethodCalled: Boolean;
   ValidMethodRaises: Boolean;
   SuccessProcRaises: Boolean;
   FailureProcRaises: Boolean;

const
   ServiceName = 'My';
   ResultValue = 'Hello';

implementation

uses
  d4net.Json, d4net.Logging;

procedure HandleSuccess(AData: WideString);
begin
   if SuccessProcRaises then
      raise Exception.Create('Error Message');

   if AData <> '' then
   begin
      ResultData := TMyResultData.Create;
      JsonSerializer.Deserialize(AData, ResultData);
   end;
end;

procedure HandleFailure(AData: WideString);
begin
   if FailureProcRaises then
      raise Exception.Create('Error Message');

   FreeAndNil(ErrorInfo);
   FreeAndNil(ResultData);
   ErrorInfo := TErrorInfo.Create;
   JsonSerializer.Deserialize(AData, ErrorInfo);
end;

{ TDispatcherTests }

procedure TDispatcherTests.ErrorLoggedWhenAfterRequestRaises;
begin
   AfterRequestRaises := True;
   Dispatcher.DispatchRequest(ServiceName, 'ValidMethod', '{}',
      '{}', HandleSuccess, HandleFailure);
   Assert.AreEqual(1, FakeLogger.ErrorCallCount);
end;

procedure TDispatcherTests.ErrorLoggedWhenErrorProcInvocationFails;
begin
   ValidMethodRaises := True;
   FailureProcRaises := True;
   Dispatcher.DispatchRequest(ServiceName, 'ValidMethod', '{}',
      '{}', HandleSuccess, HandleFailure);
   Assert.AreEqual(1, FakeLogger.ErrorCallCount);
end;

procedure TDispatcherTests.ErrorLoggedWhenSuccessProcInvocationFails;
begin
   SuccessProcRaises := True;
   Dispatcher.DispatchRequest(ServiceName, 'ValidMethod', '{}',
      '{}', HandleSuccess, HandleFailure);
   Assert.AreEqual(1, FakeLogger.ErrorCallCount);
end;

procedure TDispatcherTests.ErrorNotLoggedWhenBeforeRequestRaises;
begin
   BeforeRequestRaises := True;
   Dispatcher.DispatchRequest(ServiceName, 'ValidMethod', '{}',
      '{}', HandleSuccess, HandleFailure);
   Assert.AreEqual(0, FakeLogger.ErrorCallCount);
end;

procedure TDispatcherTests.ErrorNotLoggedWhenMethodRaises;
begin
   ValidMethodRaises := True;
   Dispatcher.DispatchRequest(ServiceName, 'ValidMethod', '{}',
      '{}', HandleSuccess, HandleFailure);
   Assert.AreEqual(0, FakeLogger.ErrorCallCount);
end;

procedure TDispatcherTests.FailureProcCalledWhenBeforeRequestRaises;
begin
   BeforeRequestRaises := True;
   Dispatcher.DispatchRequest(ServiceName, 'ValidMethod', '{}',
      '{}', HandleSuccess, HandleFailure);
   Assert.IsNotNull(ErrorInfo);
end;

procedure TDispatcherTests.FailureProcNotCalledWhenAfterRequestRaises;
begin
   AfterRequestRaises := True;
   Dispatcher.DispatchRequest(ServiceName, 'ValidMethod', '{}',
      '{}', HandleSuccess, HandleFailure);
   Assert.IsNull(ErrorInfo);
end;

procedure TDispatcherTests.MethodCalledWhenAfterRequestRaises;
begin
   AfterRequestRaises := True;
   Dispatcher.DispatchRequest(ServiceName, 'ValidMethod', '{}',
      '{}', HandleSuccess, HandleFailure);
   Assert.AreEqual(True, ValidMethodCalled);
end;

procedure TDispatcherTests.MethodNotCalledWhenBeforeRequestRaises;
begin
   BeforeRequestRaises := True;
   Dispatcher.DispatchRequest(ServiceName, 'ValidMethod', '{}',
      '{}', HandleSuccess, HandleFailure);
   Assert.AreEqual(False, ValidMethodCalled);
end;

procedure TDispatcherTests.ConsideredSuccessWhenAfterRequestRaises;
begin
   AfterRequestRaises := True;
   Dispatcher.DispatchRequest(ServiceName, 'ValidMethod', '{}',
      '{}', HandleSuccess, HandleFailure);
   Assert.IsNull(ErrorInfo);
end;

procedure TDispatcherTests.ContextDataIsAvailable;
begin
   Dispatcher.DispatchRequest(ServiceName, 'ValidMethodWithNoResultType', '{"MyValue":"Hello"}',
      '{}', HandleSuccess, HandleFailure);
   Assert.AreEqual('Hello', ContextValue);
end;

procedure TDispatcherTests.RaisesInvalidMethodSignatureWhenMethodHasMoreThanOneParameter;
begin
   Dispatcher.DispatchRequest(ServiceName, 'MethodWithTwoParameters', '{}', '', HandleSuccess, HandleFailure);
   Assert.AreEqual(EInvalidMethodSignature.QualifiedClassName, ErrorInfo.ErrorType);
end;

procedure TDispatcherTests.RaisesInvalidMethodSignatureWhenMethodHasParameterNotOfInstanceType;
begin
   Dispatcher.DispatchRequest(ServiceName, 'MethodWithParameterNotOfInstanceType', '{}', '', HandleSuccess, HandleFailure);
   Assert.AreEqual(EInvalidMethodSignature.QualifiedClassName, ErrorInfo.ErrorType);
end;

procedure TDispatcherTests.RaisesInvalidMethodSignatureWhenResultIsNotInstanceType;
begin
   Dispatcher.DispatchRequest(ServiceName, 'MethodWithResultNotOfInstanceType', '{}', '', HandleSuccess, HandleFailure);
   Assert.AreEqual(EInvalidMethodSignature.QualifiedClassName, ErrorInfo.ErrorType);
end;

procedure TDispatcherTests.RaisesMethodNotFoundWhenMethodDoesntExist;
begin
   Dispatcher.DispatchRequest(ServiceName, 'Unknown', '{}', '', HandleSuccess, HandleFailure);
   Assert.AreEqual(EMethodNotFound.QualifiedClassName, ErrorInfo.ErrorType);
end;

procedure TDispatcherTests.RaisesServiceNotFoundWhenServiceIsNotRegistered;
begin
   Dispatcher.DispatchRequest('Unregistered', '', '', '', HandleSuccess, HandleFailure);
   Assert.AreEqual(EServiceNotFound.QualifiedClassName, ErrorInfo.ErrorType);
end;

procedure TDispatcherTests.SetUp;
begin
   FakeLogger := TFakeLogger.Create;
   Logger := FakeLogger;
   Dispatcher := TMyDispatcher.Create;
   AfterRequestRaises := False;
   BeforeRequestRaises := False;
   RequestValue := '';
   ContextValue := '';
   ValidMethodCalled := False;
   ValidMethodRaises := False;
   SuccessProcRaises := False;
   FailureProcRaises := False;
end;

procedure TDispatcherTests.TearDown;
begin
   Dispatcher := nil;
   FreeAndNil(ErrorInfo);
   Logger := nil;
   FreeAndNil(FakeLogger);
end;

procedure TDispatcherTests.ValidMethodCalledWithCorrectRequestData;
begin
   Dispatcher.DispatchRequest(ServiceName, 'ValidMethodWithNoResultType', '{}',
      '{"MyValue":"Hello"}', HandleSuccess, HandleFailure);
   Assert.AreEqual('Hello', RequestValue);
end;

procedure TDispatcherTests.ValidMethodWithResultTypeReturnsResultData;
begin
   Dispatcher.DispatchRequest(ServiceName, 'ValidMethodWithResultType', '{}',
      '{}', HandleSuccess, HandleFailure);
   Assert.AreEqual(ResultValue, ResultData.MyValue);
end;

{ TMyService }

procedure TMyService.MethodWithParameterNotOfInstanceType(AParam: string);
begin

end;

function TMyService.MethodWithResultNotOfInstanceType: string;
begin

end;

procedure TMyService.MethodWithTwoParameters(AParam1, AParam2: TObject);
begin

end;

procedure TMyService.ValidMethod;
begin
   ValidMethodCalled := True;

   if ValidMethodRaises then
      raise Exception.Create('Error Message'); 
end;

procedure TMyService.ValidMethodWithNoResultType(ARequest: TMyRequestData);
begin
   RequestValue := ARequest.MyValue;
   ContextValue := Context.MyValue;
end;

function TMyService.ValidMethodWithResultType: TMyResultData;
begin
   Result := TMyResultData.Create;
   Result.MyValue := ResultValue;
end;

{ TMyDispatcher }

procedure TMyDispatcher.AfterRequest;
begin
   if AfterRequestRaises then
      raise Exception.Create('Error Message');
end;

procedure TMyDispatcher.BeforeRequest(AContext: TMyContext);
begin
   if BeforeRequestRaises then
      raise Exception.Create('Error Message');
end;

end.
