using System;
using Codeer.Friendly.Windows;
using System.Diagnostics;
using System.IO;
using System.Reflection;

namespace Driver.TestController
{
    public static class ProcessController
    {
        public static WindowsAppFriend Start()
        {
            //target path
            var current = Assembly.GetExecutingAssembly().Location;
            var repositoryPath = current.Substring(0, current.IndexOf("Source", StringComparison.Ordinal));
            var targetPath = Path.Combine(repositoryPath, @"Source\FrameworkSdkStyleWpfApp\FrameworkSdkStyleWpfApp\bin\Debug\net48\FrameworkSdkStyleWpfApp.exe");
            if (File.Exists(targetPath) is false)
            {
                throw new FileNotFoundException(targetPath);
            }
            var info = new ProcessStartInfo(targetPath) { WorkingDirectory = Path.GetDirectoryName(targetPath) };
            var app = new WindowsAppFriend(Process.Start(info));
            app.ResetTimeout();
            return app;
        }

        public static void Kill(this WindowsAppFriend app)
        {
            if (app == null) return;

            app.ClearTimeout();
            try
            {
                Process.GetProcessById(app.ProcessId).Kill();
            }
            catch { }
        }
    }
}
