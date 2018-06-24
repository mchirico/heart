using System;
using System.IO;
using System.Reflection;
using Xunit;

namespace TestHeart
{
    public class UnitTest1
    {
        [Fact]
        public void Test1()
        {
            var output = new StringWriter();
            Console.SetOut(output);

            var input = new StringReader("Somebody");
            Console.SetIn(input);


            Type testType = typeof(Heart.Program);
            ConstructorInfo ctor = testType.GetConstructor(System.Type.EmptyTypes);
            if (ctor != null)
            {
                object instance = ctor.Invoke(null);
                MethodInfo methodInfo =
                    testType.GetMethod("Main", BindingFlags.Public | BindingFlags.NonPublic |
                              BindingFlags.Static | BindingFlags.Instance);

                string[] args = { "one", "two" };
                Console.WriteLine(methodInfo.Invoke(instance, new object[] { args }));

                // Test input

                Assert.Equal(
                             string.Format("Hello World!\n\n"),
                         output.ToString());


            }
        }
    }
}
