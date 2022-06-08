unit d4net.Types;

interface

uses
  System.SysUtils;

type
   TResultProc = procedure(AResponse: WideString) stdcall;

   IDispatcher = interface
   ['{5F6F7525-3D84-4BCD-96CE-83F43EAD9410}']
      procedure DispatchRequest(AServiceName, AMethodName, AContextInfo, ARequestData: string; ASuccessProc,
          AErrorProc: TResultProc);
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

implementation

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
