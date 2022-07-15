namespace d4net;

public class MethodNameAttribute : Attribute
{
    public string Name { get; }

    public MethodNameAttribute(string name) {
        Name = name;
    }
}