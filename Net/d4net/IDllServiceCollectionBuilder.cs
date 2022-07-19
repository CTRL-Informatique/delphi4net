using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace d4net;

public interface IDllServiceCollectionBuilder
{
    IDllServiceCollectionBuilder Add<T>() where T : class;
}