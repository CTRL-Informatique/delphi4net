namespace d4net;

public class DeserializationException : Exception
{
    public DeserializationException(string? data) : base("Response deserialization failed") {
        Data["ResponseData"] = data;
    }
}