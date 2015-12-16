# Give Now for iOS

## Setup and Build

This project uses CocoaPods to manage dependencies without integrating with a workspace.
This is done by defining the dependencies in a `Podfile` and running the following command.

```
pod install --no-integrate
```

The `Pods` folder with all of the files for the dependencies are not managed with source
control so when the repository is cloned it is necessary to run this command so that
the project can be built.
