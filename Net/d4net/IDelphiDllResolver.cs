namespace d4net;

public interface IDelphiDllResolver
{
    IDelphiDll Resolve(string identifier);
}