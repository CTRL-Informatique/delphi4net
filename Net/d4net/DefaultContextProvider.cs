namespace d4net;

public class DefaultContextProvider : IContextProvider
{
    public Task<object> GetContextAsync() {
        return Task.FromResult(new object());
    }
}