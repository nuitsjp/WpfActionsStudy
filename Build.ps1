git add .
git commit -m 'update'
git push
git push origin :release/0.0.1
git tag -d release/0.0.1
git tag release/0.0.1
git push --tags