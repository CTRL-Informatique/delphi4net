namespace d4net;

public class DllNameAttribute : Attribute
{
    public string Value { get; }

    public DllNameAttribute(string value) {
        Value = value;
    }
}