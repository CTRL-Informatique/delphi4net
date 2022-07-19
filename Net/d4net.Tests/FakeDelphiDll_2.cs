namespace d4net
{
    public class FakeDelphiDll_2 : IDllWrapper
    {
        public void Execute(EndpointInfo endpointInfo, string? contextInfo, string? requestData, Action<string?> successAction, Action<string?> errorAction) {
            throw new NotImplementedException();
        }
    }
}