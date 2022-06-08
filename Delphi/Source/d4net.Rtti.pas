unit d4net.Rtti;

interface

uses
  System.Rtti;

type
   TRttiHelper = class
   public
      class function HasAttribute(AParam: TRttiParameter; AClass: TClass): Boolean;
   end;

implementation

{ TRttiHelper }

class function TRttiHelper.HasAttribute(AParam: TRttiParameter; AClass: TClass): Boolean;
var
   oAttr: TCustomAttribute;
begin
   for oAttr in AParam.GetAttributes do
   begin
      if oAttr is AClass then
         Exit(True);
   end;

   Result := False;
end;

end.
