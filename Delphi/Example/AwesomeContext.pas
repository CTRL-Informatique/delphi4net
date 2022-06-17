unit AwesomeContext;

interface

type
   TAwesomeContext = class
   strict private
      FField: string;
   public
      property Field: string read FField write FField;
   end;

implementation

end.
