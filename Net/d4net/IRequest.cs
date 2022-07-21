namespace d4net;

public interface IRequest
{
}

public interface IRequest<TResponse> where TResponse : class
{
}