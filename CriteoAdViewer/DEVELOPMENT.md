# Developing using test app with SDK

In a new folder, checkout both repositories and install their pods:
```sh
for repo in fuji fuji-test-app; do
  echo "Preparing $repo"
  git clone ssh://$USER@review.crto.in:29418/pub-sdk/$repo
  pushd $repo; pod install; popd
done```

Then open the workspace with sdk: `open fuji-test-app/fuji-test-app-with-sdk.xcworkspace`

## Side note
Related to Cocoapods, we have to use "Legacy build system", for more information:
https://stackoverflow.com/questions/53050108/xcode-10-how-to-switch-to-legacy-build-system

