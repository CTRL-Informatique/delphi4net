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
  d4net.Logging.Default,
  d4net.DebugUI.Form;

{$R *.res}

begin
  JsonSerializer := TNeonSerializer.Create(
      TNeonConfiguration.Default
         .SetMemberCase(TNeonCase.PascalCase)
         .SetMembers([TNeonMembers.Fields])
         .SetIgnoreFieldPrefix(True)
         .SetVisibility([mvPrivate]));

   OnGetContextClass :=
      function: TClass
      begin
         Result := TAwesomeContext;
      end;

   OnCreateDispatcher :=
      function: IDispatcher
      begin
         Result := TDispatcher<TAwesomeContext>.Create(JsonSerializer, TDefaultLogger.Create);
      end;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDebugUIForm, DebugUIForm);
  Application.Run;
end.
