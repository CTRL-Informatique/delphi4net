library Example;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  System.SysUtils,
  System.Classes,
  System.TypInfo,
  Neon.Core.Persistence,
  Neon.Core.Types,
  d4net.Execute,
  d4net.Dispatcher,
  d4net.Json.Neon,
  d4net.Logging.Default,
  d4net.Types;

{$R *.res}

begin
   IsMultiThread := True;

   OnCreateDispatcher :=
      function: IDispatcher
      begin
         TDispatcher<TObject>.Create(
            TNeonSerializer.Create(
               TNeonConfiguration.Default
                  .SetMemberCase(TNeonCase.PascalCase)
                  .SetMembers([TNeonMembers.Fields])
                  .SetIgnoreFieldPrefix(True)
                  .SetVisibility([mvPrivate])),
            TDefaultLogger.Create);
      end;
end.
