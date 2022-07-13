unit d4net.Json;

interface

uses
  System.JSON;

type
  IJsonSerializer = interface
  ['{6D1E6154-E818-43C9-A617-D6C4C0D97A94}']
    function Serialize(AObject: TObject): string;
    function ToJsonValue(AObject: TObject): TJsonValue;
    procedure Deserialize(AJson: string; AObject: TObject);
  end;

var
   JsonSerializer: IJsonSerializer;

implementation

end.
