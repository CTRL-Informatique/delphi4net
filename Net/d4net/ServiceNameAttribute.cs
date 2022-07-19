namespace d4net;

public class ServiceNameAttribute : Attribute
{
    public string Name { get; }

    public ServiceNameAttribute(string name) {
        Name = name;
    }
}