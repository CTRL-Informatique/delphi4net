unit d4net.Json.Neon;

interface

uses
   System.JSON,
   Neon.Core.Persistence.JSON,
   Neon.Core.Persistence,
   d4net.Json;

type
   TNeonSerializer = class(TInterfacedObject, IJsonSerializer)
   strict private
      FConfig: INeonConfiguration;
   public
      constructor Create(AConfig: INeonConfiguration);
      procedure Deserialize(AJson: string; AObject: TObject);
      function Serialize(AObject: TObject): string;
      function ToJsonValue(AObject: TObject): TJSONValue;
   end;

implementation

uses
  Neon.Core.Types, System.TypInfo;

constructor TNeonSerializer.Create(AConfig: INeonConfiguration);
begin
   inherited Create;
   FConfig := AConfig;
end;

procedure TNeonSerializer.Deserialize(AJson: string; AObject: TObject);
begin
   TNeon.JSONToObject(AObject, AJson, FConfig);
end;

function TNeonSerializer.Serialize(AObject: TObject): string;
begin
   Result := TNeon.ObjectToJSONString(AObject, FConfig);
end;

function TNeonSerializer.ToJsonValue(AObject: TObject): TJSONValue;
begin
   Result := TNeon.ObjectToJSON(AObject, FConfig);
end;

initialization
   JsonSerializer := TNeonSerializer.Create(
      TNeonConfiguration.Default
         .SetMemberCase(TNeonCase.PascalCase)
         .SetMembers([TNeonMembers.Fields])
         .SetIgnoreFieldPrefix(True)
         .SetVisibility([mvPrivate]));

end.
