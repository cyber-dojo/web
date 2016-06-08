using Moq;
using System;

public interface IFoo
{
    bool DoSomething(string s);
}

public class Demo
{
    public static void Main()
    {
        var mock = new Mock<IFoo>();
        mock.Setup((foo => foo.DoSomething("ping"))).Returns(true);
        Console.WriteLine("Hello Moq");
    }
}

