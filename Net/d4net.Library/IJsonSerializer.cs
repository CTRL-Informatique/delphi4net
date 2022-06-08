namespace d4net.Library;

public interface IJsonSerializer
{
    string Serialize(object obj);

    T Deserialize<T>(string json);
}