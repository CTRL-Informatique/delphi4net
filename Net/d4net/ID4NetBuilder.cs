namespace d4net;

public interface ID4NetBuilder
{
    ID4NetBuilder AddDll<T>() where T : class, IDllWrapper;

    ID4NetBuilder AddRequestHandler<TIntf, TImpl>()
        where TIntf : class, IRequestHandler
        where TImpl : class, TIntf;

    ID4NetBuilder UseContextProvider<T>() where T : class, IContextProvider;

    ID4NetBuilder UseJsonSerializer<T>() where T : class, IJsonSerializer;
}