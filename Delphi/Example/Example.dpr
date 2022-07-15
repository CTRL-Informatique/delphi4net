library Example;

{$STRONGLINKTYPES ON}

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
  d4net.ExportedMethods,
  d4net.Dispatcher,
  //include this to use the default JsonSerializer
  d4net.Json.Neon,
  AwesomeService in 'AwesomeService.pas',
  AwesomeContext in 'AwesomeContext.pas';

{$R *.res}

exports
   d4net.ExportedMethods.Execute,
   d4net.ExportedMethods.SetLogProc;

begin
   IsMultiThread := True;
   Dispatcher := TDispatcher<TAwesomeContext>.Create;
end.
