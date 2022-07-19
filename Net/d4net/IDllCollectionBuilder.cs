namespace d4net;

public interface IDllCollectionBuilder
{
    IDllCollectionBuilder Add<T>(string name = "") where T : class, IDllWrapper;
}