namespace d4net;

public interface IJsonSerializer
{
    string Serialize(object obj);

    T? Deserialize<T>(string json);
}