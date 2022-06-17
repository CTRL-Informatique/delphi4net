unit d4net.ServiceBase;

interface

uses
  System.SysUtils, System.Generics.Collections, System.Rtti;

type
   RegisterServiceAttribute = class(TCustomAttribute)
   end;

   TServiceBase = class abstract;
   
   TServiceBase<T: class, constructor> = class abstract(TServiceBase)
   strict private
      FContext: T;
   strict protected
      property Context: T read FContext;
   public
      destructor Destroy; override;
   end;

  TServiceClass = class of TServiceBase;

implementation

{ TServiceBase<T> }

destructor TServiceBase<T>.Destroy;
begin
   FreeAndNil(FContext);
   inherited Destroy;
end;

end.
