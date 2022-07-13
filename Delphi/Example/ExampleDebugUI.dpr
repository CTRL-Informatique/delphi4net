program ExampleDebugUI;

{$STRONGLINKTYPES ON}

uses
  Vcl.Forms,
  Neon.Core.Persistence,
  Neon.Core.Types,
  System.TypInfo,
  d4net.Json.Neon,
  AwesomeService,
  AwesomeContext,
  d4net.Dispatcher,
  d4net.DebugUI.Form;

{$R *.res}

begin
   ContextClass := TAwesomeContext;
   Dispatcher := TDispatcher<TAwesomeContext>.Create;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDebugUIForm, DebugUIForm);
  Application.Run;
end.
