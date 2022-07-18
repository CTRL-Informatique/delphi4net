unit d4net.Dispatcher;

interface

uses
  System.SysUtils, System.Generics.Collections, System.Rtti,
  d4net.ServiceBase, d4net.Logging, d4net.Json;

type
   TResultProc = procedure(AResponse: WideString) stdcall;

   IDispatcher = interface
   ['{5F6F7525-3D84-4BCD-96CE-83F43EAD9410}']
      procedure DispatchRequest(AServiceName, AMethodName, AContextInfo, ARequestData: string; ASuccessProc,
          AErrorProc: TResultProc);
      function GetContextClass: TClass;
      property ContextClass: TClass read GetContextClass;
   end;

   TErrorInfo = class
   strict private
      FErrorType: string;
      FErrorMessage: string;
      FErrorStackTrace: string;
   public
      property ErrorType: string read FErrorType write FErrorType;
      property ErrorMessage: string read FErrorMessage write FErrorMessage;
      property ErrorStackTrace: string read FErrorStackTrace write FErrorStackTrace;
   end;

   TDispatcher = class abstract(TInterfacedObject)
   strict private
      class constructor CreateClass;
      class destructor DestroyClass;
   strict protected
      class var FServiceClasses: TDictionary<string, TServiceClass>;
      class function Instantiate(AClass: TClass; AArgs: TArray<TValue> = []): TObject;
      class procedure RegisterServiceClasses;
      class procedure ValidateSignature(AMethod: TRttiMethod);
      procedure HandleException(AException: Exception; out AResponseData: string);
      procedure Invoke(AServiceInstance: TServiceBase; AMethodName, ARequestData: string; out AResponseData: string);
   public
      class function GetRequestDataClass(AServiceName, AMethodName: string): TClass;
      class function ListMethodNames(AServiceName: string): TArray<string>;
      class function ListServiceNames: TArray<string>;
   end;

   TDispatcher<TContext: class, constructor> = class(TDispatcher, IDispatcher)
   strict private
      function GetContextClass: TClass;
   strict protected
      procedure AfterRequest; virtual;
      procedure BeforeRequest(AContext: TContext); virtual;
   public
      procedure DispatchRequest(AServiceName, AMethodName, AContextInfo, ARequestData: string; ASuccessProc,
          AErrorProc: TResultProc);
   end;

   EServiceNotFound = class(Exception)
   public
      constructor Create(AClassName: string); reintroduce;
   end;

   EMethodNotFound = class(Exception)
   public
      constructor Create(AMethodName: string); reintroduce;
   end;

   EInvalidMethodSignature = class(Exception)
   public
      constructor Create(AReason: string); reintroduce;
   end;

var
   Dispatcher: IDispatcher;

implementation

uses
  d4net.Rtti;

{ TDispatcher<TContext> }

procedure TDispatcher<TContext>.AfterRequest;
begin
end;

procedure TDispatcher<TContext>.BeforeRequest(AContext: TContext);
begin
end;

procedure TDispatcher<TContext>.DispatchRequest(AServiceName, AMethodName, AContextInfo, ARequestData: string;
    ASuccessProc, AErrorProc: TResultProc);
var
   LServiceClass: TServiceClass;
   LServiceInstance: TServiceBase;
   LContext: TContext;
   LResponseData: string;
begin
   LResponseData := '';

   Logger.Info('Processing request: ServiceName=' + AServiceName + ' MethodName=' + AMethodName +
      ' AContextInfo=' + AContextInfo);

   Logger.Debug('RequestData=' + ARequestData);

   try
      if not FServiceClasses.TryGetValue(AServiceName, LServiceClass) then
         raise EServiceNotFound.Create(AServiceName);

      LContext := TContext.Create;

      try
         JsonSerializer.Deserialize(AContextInfo, LContext);
      except
         LContext.Free;
         raise;
      end;

      LServiceInstance := TServiceBase(Instantiate(LServiceClass));

      with TRttiContext.Create do
      try
         GetType(LServiceInstance.ClassType).GetField('FContext').SetValue(LServiceInstance, LContext);
      finally
         Free;
      end;

      try
         BeforeRequest(LContext);

         try
            Invoke(LServiceInstance, AMethodName, ARequestData, LResponseData);
         finally
            try
               AfterRequest;
            except
               on E: Exception do
                  Logger.Error(E);
            end;
         end;
      finally
         LServiceInstance.Free;
      end;

      Logger.Debug('ResponseData=' + LResponseData);

      if Assigned(ASuccessProc) then
      try
         ASuccessProc(LResponseData);
      except
         on E: Exception do
            Logger.Error('Success proc invocation failed: ' + e.ToString);
      end;
   except
      on e: Exception do
      begin
         HandleException(e, LResponseData);

         if Assigned(AErrorProc) then
         try
            AErrorProc(LResponseData);
         except
            on e: Exception do
               Logger.Error('Error proc invocation failed: ' + e.ToString);
         end;
      end;
   end;
end;

function TDispatcher<TContext>.GetContextClass: TClass;
begin
   Result := TContext;
end;

class constructor TDispatcher.CreateClass;
begin
   FServiceClasses := TDictionary<string, TServiceClass>.Create;
   RegisterServiceClasses;
end;

class destructor TDispatcher.DestroyClass;
begin
   FreeAndNil(FServiceClasses);
end;

class function TDispatcher.GetRequestDataClass(AServiceName, AMethodName: string): TClass;
var
   LRttiCtx: TRttiContext;
   LMethod: TRttiMethod;
   LParams: TArray<TRttiParameter>;
begin
   Result := nil;
   LRttiCtx := TRttiContext.Create;

   try
      LMethod := LRttiCtx.GetType(FServiceClasses[AServiceName]).GetMethod(AMethodName);
      LParams := LMethod.GetParameters;

      if Length(LParams) > 0 then
         Result := TRttiInstanceType(LParams[0].ParamType).MetaClassType;
   finally
      LRttiCtx.Free;
   end;
end;

procedure TDispatcher.HandleException(AException: Exception; out AResponseData: string);
var
   LError: TErrorInfo;
begin
   LError := TErrorInfo.Create;

   try
      LError.ErrorType := AException.QualifiedClassName;
      LError.ErrorMessage := AException.Message;
      LError.ErrorStackTrace := AException.StackTrace;
      AResponseData := JsonSerializer.Serialize(LError);
   finally
      LError.Free;
   end;
end;

class function TDispatcher.Instantiate(AClass: TClass; AArgs: TArray<TValue> = []): TObject;
begin
  with TRttiContext.Create do
  try
      Result := GetType(AClass).GetMethod('Create').Invoke(AClass, AArgs).AsObject;
  finally
     Free;
  end;
end;

procedure TDispatcher.Invoke(AServiceInstance: TServiceBase; AMethodName, ARequestData: string; out
    AResponseData: string);
var
   LRttiCtx: TRttiContext;
   LMethod: TRttiMethod;
   LInvokeArgs: TArray<TValue>;
   LMethodParams: TArray<TRttiParameter>;
   LRequestData: TObject;
   LResponseData: TObject;
begin
   AResponseData := '';
   LRttiCtx := TRttiContext.Create;
   LInvokeArgs := [];
   LRequestData := nil;
   LResponseData := nil;

   try
      LMethod := LRttiCtx.GetType(AServiceInstance.ClassType).GetMethod(AMethodName);

      if LMethod = nil then
         raise EMethodNotFound.Create(AMethodName);

      ValidateSignature(LMethod);
      LMethodParams := LMethod.GetParameters;
      SetLength(LInvokeArgs, Length(LMethodParams));

      if Length(LMethodParams) > 0 then
      begin
         LRequestData := Instantiate(TRttiInstanceType(LMethodParams[0].ParamType).MetaClassType);
         JsonSerializer.Deserialize(ARequestData, LRequestData);
         LInvokeArgs[0] := LRequestData;
      end;

      if LMethod.ReturnType <> nil then
      begin
         LResponseData := LMethod.Invoke(AServiceInstance, LInvokeArgs).AsObject;
         AResponseData := JsonSerializer.Serialize(LResponseData);
      end
      else
         LMethod.Invoke(AServiceInstance, LInvokeArgs);
   finally
      LRttiCtx.Free;
      LRequestData.Free;
      LResponseData.Free;
   end;
end;

class function TDispatcher.ListMethodNames(AServiceName: string): TArray<string>;
var
   LRttiCtx: TRttiContext;
   LMethod: TRttiMethod;
   LBaseMethodNames: TList<string>;
begin
   Result := [];
   LBaseMethodNames := TList<string>.Create;

   try
      LRttiCtx := TRttiContext.Create;

      try
         for LMethod in LRttiCtx.GetType(TObject).GetMethods do
            LBaseMethodNames.Add(LMethod.Name);

         for LMethod in LRttiCtx.GetType(FServiceClasses[AServiceName]).GetMethods do
         begin
            if LBaseMethodNames.Contains(LMethod.Name) then
               Continue;

            Result := Result + [LMethod.Name];
         end;
      finally
         LRttiCtx.Free;
      end;
   finally
      LBaseMethodNames.Free;
   end;
end;

class function TDispatcher.ListServiceNames: TArray<string>;
begin
   Result := FServiceClasses.Keys.ToArray;
end;

class procedure TDispatcher.RegisterServiceClasses;
var
   LRttiCtx: TRttiContext;
   LType: TRttiType;
   LAttr: TCustomAttribute;
   LClass: TClass;
begin
   LRttiCtx := TRttiContext.Create;

   try
      for LType in LRttiCtx.GetTypes do
      begin
         if not (LType is TRttiInstanceType) then
            Continue;

         for LAttr in LType.GetAttributes do
            if LAttr is RegisterServiceAttribute then
            begin
               LClass := TRttiInstanceType(LType).MetaclassType;
               FServiceClasses.Add(
                  LClass.ClassName.Replace('Service', '').Substring(1),
                  TServiceClass(LClass));
               Break;
            end;
      end;
   finally
      LRttiCtx.Free;
   end;
end;

class procedure TDispatcher.ValidateSignature(AMethod: TRttiMethod);
var
   LParam: TRttiParameter;
begin
   for LParam in AMethod.GetParameters do
   begin
      if not (LParam.ParamType is TRttiInstanceType) then
         raise EInvalidMethodSignature.Create('Only class types are allowed as parameters');
   end;

   if (AMethod.ReturnType <> nil) and not (AMethod.ReturnType is TRttiInstanceType) then
      raise EInvalidMethodSignature.Create('Only class types are allowed as function result');

   if Length(AMethod.GetParameters) > 1 then
      raise EInvalidMethodSignature.Create('Method must not have more than 1 parameter');
end;

{ EServiceNotFound }

constructor EServiceNotFound.Create(AClassName: string);
begin
   inherited Create('No registered service class for name ' + AClassName.QuotedString +
      '. Use [RegisterService] or make sure the service name is correct.');
end;

{ EMethodNotFound }

constructor EMethodNotFound.Create(AMethodName: string);
begin
   inherited Create('The specified class has no method ' + AMethodName.QuotedString);
end;

{ EInvalidMethodSignature }

constructor EInvalidMethodSignature.Create(AReason: string);
begin
   inherited Create('Invalid method signature: ' + AReason);
end;

end.
