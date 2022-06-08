namespace d4net.Library;

public interface IDllWrapperFilter
{
    void OnLog(LogLevel level, string message);

    void BeforeExecute(string requestData);

    void AfterExecute(string responseData);
}