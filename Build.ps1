git add .
git commit -m 'update'
git push
$tag = "release/dotnet-desktop/DotnetWpfApp/0.0.1"
git push origin ":$tag"
git tag -d $tag
git tag $tag
git push --tags

# $temp = $tag.Substring($tag.IndexOf("/") + 1)
# # Write-Host $temp

# $moduleType = $temp.Substring(0, $temp.IndexOf("/"))
# Write-Host $moduleType

# $temp = $temp.Substring($temp.IndexOf("/") + 1)
# # Write-Host $temp

# $module = $temp.Substring(0, $temp.IndexOf("/"))
# Write-Host $module

# $version = $temp.Substring($temp.IndexOf("/") + 1)
# Write-Host $version
