namespace d4net;

public interface IDllResolver
{
    IDllWrapper Resolve(string identifier);
}