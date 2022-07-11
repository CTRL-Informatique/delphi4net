unit d4net.Dispatcher;

interface

uses
  System.SysUtils, System.Generics.Collections, System.Rtti,
  d4net.ServiceBase, d4net.Logging, d4net.Json, d4net.Types;

type
   IDispatcher = d4net.Types.IDispatcher;

   TDispatcher = class abstract(TInterfacedObject)
   strict private
      class constructor CreateClass;
      class destructor DestroyClass;
   strict protected
      FLogger: ILogger;
      FJsonSerializer: IJsonSerializer;
      class var FServiceClasses: TDictionary<string, TServiceClass>;
      class function Instantiate(AClass: TClass; AArgs: TArray<TValue> = []): TObject;
      class procedure RegisterServiceClasses;
      class procedure ValidateSignature(AMethod: TRttiMethod);
      procedure HandleException(AException: Exception; out AResponseData: string);
      procedure Invoke(AServiceInstance: TServiceBase; AMethodName, ARequestData: string; out AResponseData: string);
   public
      constructor Create(AJsonSerializer: IJsonSerializer; ALogger: ILogger);
      class function GetRequestDataClass(AServiceName, AMethodName: string): TClass;
      class function ListMethodNames(AServiceName: string): TArray<string>;
      class function ListServiceNames: TArray<string>;
   end;

   TDispatcher<TContext: class, constructor> = class(TDispatcher, IDispatcher)
   strict protected
      procedure AfterRequest; virtual;
      procedure BeforeRequest(AContext: TContext); virtual;
   public
      procedure DispatchRequest(AServiceName, AMethodName, AContextInfo, ARequestData: string; ASuccessProc,
          AErrorProc: TResultProc);
   end;

var
   OnCreateDispatcher: TFunc<IDispatcher>;

implementation

uses
  d4net.Rtti;

{ TDispatcher<T> }

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
   FLogger.Info('Processing request: ServiceName=' + AServiceName + ' MethodName=' + AMethodName +
      ' AContextInfo=' + AContextInfo);

   FLogger.Debug('RequestData=' + ARequestData);

   try
      if not FServiceClasses.TryGetValue(AServiceName, LServiceClass) then
         raise EServiceNotFound.Create(AServiceName);

      LContext := TContext.Create;

      try
         FJsonSerializer.Deserialize(AContextInfo, LContext);
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
            AfterRequest;
         end;
      finally
         LServiceInstance.Free;
      end;

      FLogger.Debug('ResponseData=' + LResponseData);

      if Assigned(ASuccessProc) then
      try
         ASuccessProc(LResponseData);
      except
         on E: Exception do
            FLogger.Error('Success proc invocation failed: ' + e.ToString);
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
               FLogger.Error('Error proc invocation failed: ' + e.ToString);
         end;
      end;
   end;
end;

{ TDispatcher }

constructor TDispatcher.Create(AJsonSerializer: IJsonSerializer; ALogger: ILogger);
begin
  FJsonSerializer := AJsonSerializer;
  FLogger := ALogger;
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
   FLogger.Error(AException);
   LError := TErrorInfo.Create;

   try
      LError.ErrorType := AException.ClassName;
      LError.ErrorMessage := AException.Message;
      LError.ErrorStackTrace := AException.StackTrace;
      AResponseData := FJsonSerializer.Serialize(LError);
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
         FJsonSerializer.Deserialize(ARequestData, LRequestData);
         LInvokeArgs[0] := LRequestData;
      end;

      if LMethod.ReturnType <> nil then
      begin
         LResponseData := LMethod.Invoke(AServiceInstance, LInvokeArgs).AsObject;
         AResponseData := FJsonSerializer.Serialize(LResponseData);
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

end.
