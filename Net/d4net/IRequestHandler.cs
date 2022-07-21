namespace d4net;

public interface IRequestHandler
{
    Task HandleAsync(IRequest request);

    Task<T> HandleAsync<T>(IRequest<T> request) where T : class;
}