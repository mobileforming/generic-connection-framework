#!/bin/sh

keysFile=""
bundleID=""

main() {
	readValues
	cloneTemplates
	modifyConfig
	modifyAppfile
}

# get user defined values
  readValues() {
	echo "\n\n"
	echo "Specify the keys file name which is located at https://gitlab.mobileforming.com/commons/fastlane-keys (ex: blizzard-keys):"
	read keysFile
	
	echo "\n\n"
	echo "Specify the bundle identifier of the app (ex: com.mobileforming.ios.blizzard):"
	read bundleID
  }

# cloning template files
  cloneTemplates() {
	echo "\nCloning template files into current directory"
	
	git clone https://gitlab.mobileforming.com/commons/ios-ci-stub-templates.git
	mv ./ios-ci-stub-templates/* ./
	rm -rf ./ios-ci-stub-templates

	git clone https://gitlab.mobileforming.com/commons/build-scripts.git
	mkdir -p fastshell
	mv ./build-scripts/ios/* ./fastshell
	rm -rf ./build-scripts

	echo "Done\n"
  }

# modify config.json
 modifyConfig() {
	echo "\nModifying config.json"	
	sed -i "" "s/KEYS_NAME/$keysFile/" ./config.json
	echo "Done\n"
 }

# Appfile
  modifyAppfile() {
	echo "\nModifying Appfile"
	sed -i "" "s/BUNDLE_ID/$bundleID/" ./fastlane/Appfile
	echo "Done\n"
  }
 

main "$@"
