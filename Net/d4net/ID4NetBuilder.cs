namespace d4net;

public interface ID4NetBuilder
{
    ID4NetBuilder UseGateway<T>() where T : class, IGateway;

    ID4NetBuilder UseJsonSerializer<T>() where T : class, IJsonSerializer;

    ID4NetBuilder UseContextProvider<T>() where T : class, IContextProvider;

    ID4NetBuilder AddDlls(Action<IDllCollectionBuilder> action);

    ID4NetBuilder AddDllServices(Action<IDllServiceCollectionBuilder> action);
}