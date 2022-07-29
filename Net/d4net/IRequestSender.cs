namespace d4net;

public interface IRequestSender
{
    Task Send(IRequest request, string dllName);

    Task<T> Send<T>(IRequest<T> request, string dllName) where T : class;
}