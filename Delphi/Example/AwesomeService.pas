unit AwesomeService;

interface

uses
  d4net.ServiceBase;

type
   TMyRequest = class
   strict private
      FField: string;
   public
      property Field: string read FField write FField;
   end;

   TMyResponse = class(TMyRequest);

   [RegisterService]
   TAwesomeService = class(TServiceBase<TObject>)
   public
      function GetResult(ARequest: TMyRequest): TMyResponse;
   end;

implementation

{ TAwesomeService }

function TAwesomeService.GetResult(ARequest: TMyRequest): TMyResponse;
begin
   Result := TMyResponse.Create;
   Result.Field := ARequest.Field;
end;

end.
