﻿using FluentAssertions;
using Microsoft.Extensions.DependencyInjection;

namespace d4net;

[TestClass]
public class DelphiDllResolverTests
{
    private ServiceCollection _serviceCollection = null!;
    private IServiceProvider _serviceProvider = null!;
    private IDllResolver _resolver = null!;

    [TestInitialize]
    public void _Initialize() {
        _serviceCollection = new ServiceCollection();
    }

    [TestMethod]
    public void ShouldTheDllAssociatedWithTheName() {
        _serviceCollection.AddDelphi4Net()
            .AddDlls(dlls => dlls
                .Add<FakeDelphiDll_1>("1")
                .Add<FakeDelphiDll_2>("2"));

        _serviceProvider = _serviceCollection.BuildServiceProvider();
        _resolver = _serviceProvider.GetRequiredService<IDllResolver>();

        _resolver.Resolve("1").Should().BeOfType<FakeDelphiDll_1>();
        _resolver.Resolve("2").Should().BeOfType<FakeDelphiDll_2>();
    }

    [TestMethod]
    public void ShouldWorkWithoutDllName() {
        _serviceCollection.AddDelphi4Net().AddDlls(dlls => dlls.Add<FakeDelphiDll_1>());
        _serviceProvider = _serviceCollection.BuildServiceProvider();
        _resolver = _serviceProvider.GetRequiredService<IDllResolver>();
        _resolver.Resolve("").Should().BeOfType<FakeDelphiDll_1>();
    }

    [TestMethod]
    [ExpectedException(typeof(ArgumentException))]
    public void ShouldThrowIfTwoDllsRegisteredWithoutAName() {
        _serviceCollection.AddDelphi4Net()
            .AddDlls(dlls => dlls
                .Add<FakeDelphiDll_1>()
                .Add<FakeDelphiDll_2>());
    }
}