using System.Collections.Generic;
using PropertyChanged;

namespace FrameworkWpfApp
{
    [AddINotifyPropertyChangedInterface]
    public class MainWindowViewModel
    {
        public IList<string> Colors { get; } = new List<string>
        {
            "Red", "Blue", "Black"
        };


        public string SelectedColors { get; set; }
    }
}