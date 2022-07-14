

$Solution_Name = "Source\FramwworkWpfApp\FramwworkWpfApp.sln"
$Wap_Project_Path = "Source\FramwworkWpfApp\FramwworkWpfApp.Package\FramwworkWpfApp.Package.wapproj"
$Appx_Package_Build_Mode = "StoreUpload"
$Configuration = "Release"
$Appx_Bundle = "Always"
$Appx_Bundle_Platforms = "x86|x64"
$GitHubActionsWorkflow = "Source\FramwworkWpfApp\FramwworkWpfApp.Package\FramwworkWpfApp.Package_TemporaryKey.pfx"

msbuild $Solution_Name /t:Restore /p:Configuration=$Configuration
msbuild `
	$Wap_Project_Path `
	/p:Configuration=$Configuration `
	/p:UapAppxPackageBuildMode=$Appx_Package_Build_Mode `
	/p:AppxBundle=$Appx_Bundle `
	/p:PackageCertificateKeyFile=$GitHubActionsWorkflow `
	/p:PackageCertificatePassword="karYwH@%4g#q9J" `
