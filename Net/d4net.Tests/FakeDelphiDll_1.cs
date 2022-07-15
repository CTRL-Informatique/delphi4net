namespace d4net
{
    public class FakeDelphiDll_1 : IDelphiDll
    {
        public void Execute(EndpointInfo endpointInfo, string? contextInfo, string? requestData, Action<string?> successAction, Action<string?> errorAction) {
            throw new NotImplementedException();
        }
    }
}