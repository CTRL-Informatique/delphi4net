namespace d4net;

public class ResponseException : Exception
{
    public ResponseException(ErrorInfo errorInfo) : base(errorInfo.ErrorMessage) {
        errorInfo.GetType().GetProperties()
            .Where(p => p.Name != nameof(errorInfo.ErrorMessage)).ToList()
            .ForEach(p => Data[p.Name] = p.GetValue(errorInfo));
    }
}