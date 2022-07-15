using FluentAssertions;
using Microsoft.Extensions.DependencyInjection;

namespace d4net
{
    [TestClass]
    public class ServiceRegisteringTests
    {
        private ServiceCollection _serviceCollection = null!;
        private IServiceProvider? _serviceProvider = null;

        [TestInitialize]
        public void _Initialize() {
            _serviceCollection = new ServiceCollection();
        }

        [TestMethod]
        public void ShouldRegisterDefaultGateway() {
            _serviceCollection.AddDelphi4Net().AddDelphiDll<FakeDelphiDll_1>("");
            _serviceProvider = _serviceCollection.BuildServiceProvider();
            _serviceProvider.GetRequiredService<IGateway>().Should().BeOfType<DefaultGateway>();
        }

        [TestMethod]
        public void ShouldRegisterDefaultJsonSerializer() {
            _serviceCollection.AddDelphi4Net().AddDelphiDll<FakeDelphiDll_1>("");
            _serviceProvider = _serviceCollection.BuildServiceProvider();
            _serviceProvider.GetRequiredService<IJsonSerializer>().Should().BeOfType<DefaultJsonSerializer>();
        }

        [TestMethod]
        public void ShouldRegisterDefaultContextProvider() {
            _serviceCollection.AddDelphi4Net().AddDelphiDll<FakeDelphiDll_1>("");
            _serviceProvider = _serviceCollection.BuildServiceProvider();
            _serviceProvider.GetRequiredService<IContextProvider>().Should().BeOfType<DefaultContextProvider>();
        }
    }
}