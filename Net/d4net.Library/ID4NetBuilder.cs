namespace d4net;

public interface ID4NetBuilder
{
    ID4NetBuilder UseGateway<T>() where T : class, IGateway;

    ID4NetBuilder UseJsonSerializer<T>() where T : class, IJsonSerializer;

    ID4NetBuilder AddDelphiDll<T>(string name = "") where T : class, IDelphiDll;

    ID4NetBuilder AddDelphiService<T>() where T : class;
    ID4NetBuilder UseContextProvider<T>() where T : class, IContextProvider;
}