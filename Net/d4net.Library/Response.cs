﻿namespace d4net.Library;

public class Response
{
    public ErrorInfo? ErrorInfo { get; set; }
    public bool IsSuccess { get; set; }
    public string? Data { get; set; }
}