namespace d4net;

[AttributeUsage(AttributeTargets.Class)]
public class EndpointAttribute : Attribute
{
    public EndpointAttribute(string service, string method) {
        Service = service;
        Method = method;
    }

    public string Service { get; }
    public string Method { get; }
}