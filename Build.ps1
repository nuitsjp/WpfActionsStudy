git add .
git commit -m 'update'
git push
$tag = "release/0.0.1"
git push origin ":$tag"
git tag -d $tag
git tag $tag
git push --tags