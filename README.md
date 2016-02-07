# Give Now for iOS

## Setup and Build

This project uses CocoaPods to manage dependencies without integrating with a workspace.
This is done by defining the dependencies in a `Podfile` and running the following command.

```
pod install --no-integrate
```

Alernatively you can run the following script.

```
sh install_pods.sh
```

The `Pods` folder with all of the files for the dependencies are not managed with source
control so when the repository is cloned it is necessary to run this command so that
the project can be built.

Since the `--no-integrate` switch is used the workspace which is created by default is
not created. This requires the `Pods` project to be referenced as a sub project and
configured manually, making it easier to manage changes.

## Keys

Keys are required for Parse and Mapbox. These string values are stored outside of
source control so these values are not exposed publicly. These values are found in
`~/.givenowkeys` in the user's home directory and read with a build script which
updates `Keys.plist` in the build output folder.

```sh
#!/bin/sh

export ProdParseApplicationId="INSERT_VALUE_HERE"
export ProdParseClientKey="INSERT_VALUE_HERE"
export DevParseApplicationId="INSERT_VALUE_HERE"
export DevParseClientKey="INSERT_VALUE_HERE"
export MapboxToken="INSERT_VALUE_HERE"
```
