namespace d4net.Library;

public class MethodNameAttribute : Attribute
{
    public string Name { get; }

    public MethodNameAttribute(string name) {
        Name = name;
    }
}