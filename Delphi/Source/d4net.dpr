library d4net;

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
  d4net.Dispatcher in 'd4net.Dispatcher.pas',
  d4net.Json.Neon in 'd4net.Json.Neon.pas',
  d4net.Json in 'd4net.Json.pas',
  d4net.Logging in 'd4net.Logging.pas',
  d4net.ServiceBase in 'd4net.ServiceBase.pas',
  d4net.Rtti in 'd4net.Rtti.pas',
  d4net.ExportedMethods in 'd4net.ExportedMethods.pas',
  d4net.DebugUI.Form in 'd4net.DebugUI.Form.pas' {DebugUIForm};

{$R *.res}

begin

end.
