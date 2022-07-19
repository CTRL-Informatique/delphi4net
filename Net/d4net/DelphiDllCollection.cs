namespace d4net;

internal class DelphiDllCollection
{
    private readonly Dictionary<string, Type> _dlls = new();

    public void Add<T>(string identifier) where T : IDelphiDll {
        _dlls.Add(identifier, typeof(T));
    }

    public Type Get(string identifier) {
        return _dlls[identifier];
    }
}