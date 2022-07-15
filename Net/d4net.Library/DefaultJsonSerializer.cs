using System.Text.Json;

namespace d4net;

public class DefaultJsonSerializer : IJsonSerializer
{
    public T? Deserialize<T>(string json) {
        return JsonSerializer.Deserialize<T>(json);
    }

    public string Serialize(object obj) {
        return JsonSerializer.Serialize(obj);
    }
}