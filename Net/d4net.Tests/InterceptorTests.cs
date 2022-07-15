using FluentAssertions;
using Microsoft.Extensions.DependencyInjection;
using NSubstitute;

namespace d4net
{
    [TestClass]
    public class InterceptorTests
    {
        private ServiceCollection _serviceCollection = null!;
        private IServiceProvider? _serviceProvider;
        private IGateway _gateway = null!;
        private IDelphiService _delphiService = null!;
        private IContextProvider _contextProvider = null!;
        private readonly IJsonSerializer _jsonSerializer = new DefaultJsonSerializer();

        [TestInitialize]
        public void _Initialize() {
            _serviceCollection = new ServiceCollection();

            _gateway = Substitute.For<IGateway>();
            _gateway.CallEndpoint(default!, default!, default!, default)
                .ReturnsForAnyArgs(new Response() { IsSuccess = true });
            FakeGateway.Gateway = _gateway;

            _serviceCollection.AddDelphi4Net()
                .UseGateway<FakeGateway>()
                .UseContextProvider<FakeContextProvider>()
                .AddDelphiService<IDelphiService>();

            _serviceProvider = _serviceCollection.BuildServiceProvider();
            _delphiService = _serviceProvider.GetRequiredService<IDelphiService>();

            _contextProvider = Substitute.For<IContextProvider>();
            FakeContextProvider.ContextProvider = _contextProvider;
        }

        [TestMethod]
        public async Task ShouldCallGatewayWithTheRightDllName() {
            _serviceCollection.AddDelphi4Net()
                .UseGateway<FakeGateway>()
                .AddDelphiService<IDelphiService>();

            _serviceProvider = _serviceCollection.BuildServiceProvider();
            var delphiService = _serviceProvider.GetRequiredService<IDelphiService>();

            await delphiService.Method();

            await _gateway.Received().CallEndpoint(
                Arg.Is("DllName"),
                Arg.Any<EndpointInfo>(),
                Arg.Any<object>(),
                Arg.Any<string>());
        }

        [TestMethod]
        public async Task ShouldCallGatewayWithTheRightEndpointInfo() {
            await _delphiService.Method();

            await _gateway.Received().CallEndpoint(
                Arg.Any<string>(),
                Arg.Is<EndpointInfo>(endpointInfo =>
                    endpointInfo.ServiceName == "ServiceName" && endpointInfo.MethodName == "MethodName"),
                Arg.Any<object>(),
                Arg.Any<string>());
        }

        [TestMethod]
        public async Task ShouldCallGatewayWithContextData() {
            var context = new object();
            _contextProvider.GetContextAsync().Returns(context);

            await _delphiService.Method();

            await _gateway.Received().CallEndpoint(
                Arg.Any<string>(),
                Arg.Any<EndpointInfo>(),
                Arg.Is(context),
                Arg.Any<string>());
        }

        [TestMethod]
        public async Task ShouldCallGatewayWithRequestData() {
            var request = new MyDto { Value = "X" };
            string receivedRequestData = "";

            _gateway.CallEndpoint(default!, default!, default!, default)
                .ReturnsForAnyArgs(new Response() { IsSuccess = true })
                .AndDoes(callInfo => receivedRequestData = callInfo.ArgAt<string>(3));

            await _delphiService.MethodWithParameter(request);
            request = _jsonSerializer.Deserialize<MyDto>(receivedRequestData)!;
            request.Value.Should().Be("X");
        }

        [TestMethod]
        public async Task ShouldReturnResultFromGateway() {
            var response = new MyDto { Value = "X" };
            var responseData = _jsonSerializer.Serialize(response);

            _gateway.CallEndpoint(default!, default!, default!, default)
                .ReturnsForAnyArgs(new Response() { IsSuccess = true, Data = responseData });

            response = await _delphiService.MethodWithResult();
            response.Value.Should().Be("X");
        }

        [TestMethod]
        public async Task ShouldThrowWhenGatewayReturnsAnError() {
            var error = new ErrorInfo() {
                ErrorMessage = "ErrorMessage",
                ErrorStacktrace = "ErrorStackTrace",
                ErrorType = "ErrorType"
            };

            _gateway.CallEndpoint(default!, default!, default!, default)
                .ReturnsForAnyArgs(new Response() { IsSuccess = false, ErrorInfo = error });

            try {
                await _delphiService.Method();
                Assert.Fail();
            }
            catch (Exception e) {
                e.Should().BeOfType<ResponseException>();
                e.Message.Should().Contain(error.ErrorMessage);
                e.Data[nameof(error.ErrorStacktrace)].Should().Be(error.ErrorStacktrace);
                e.Data[nameof(error.ErrorType)].Should().Be(error.ErrorType);
            }
        }
    }

    [DllName("DllName")]
    [ServiceName("ServiceName")]
    public interface IDelphiService
    {
        [MethodName("MethodName")]
        Task Method();

        Task MethodWithParameter(MyDto request);

        Task<MyDto> MethodWithResult();
    }

    public class FakeContextProvider : IContextProvider
    {
        public static IContextProvider ContextProvider { get; set; } = null!;

        public async Task<object> GetContextAsync() {
            return await ContextProvider.GetContextAsync();
        }
    }

    public class MyDto
    {
        public string Value { get; set; } = "";
    }
}