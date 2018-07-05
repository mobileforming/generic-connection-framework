fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios maintenanceBuildTest
```
fastlane ios maintenanceBuildTest
```
'build scheme:NAME configuration:NAME method:NAME' Builds a given scheme, configuration, and export method without distributing the IPA.
### ios coverage
```
fastlane ios coverage
```
Runs Sonar Swift code coverage analysis for app
### ios coverageModule
```
fastlane ios coverageModule
```
Runs Sonar Swift code coverage analysis for modules
### ios codereview
```
fastlane ios codereview
```
Runs all the tests and Danger on merge
### ios distributionFabricQA
```
fastlane ios distributionFabricQA
```
'distributionFabricQA scheme:NAME configuration:NAME plistPath:NAME buildNumber:NAME buildType:NAME' Distribution lane to fabric from the Dev environment.
### ios automationAWS
```
fastlane ios automationAWS
```
'automation workspace:NAME scheme:NAME configuration:NAME' Automation lane for building UI Test targets for upload to AWS Device Farm.
### ios releaseUpload
```
fastlane ios releaseUpload
```
'releaseUpload scheme:NAME configuration:NAME' Upload only lane, not a submission or activation of TestFlight (Unless previously activated)
### ios maintenanceRefreshDsyms
```
fastlane ios maintenanceRefreshDsyms
```
Lane for refreshing the DSYMs from a submitted app.
### ios maintenanceRepairProfiles
```
fastlane ios maintenanceRepairProfiles
```
Lane to repair adhoc and development profiles.
### ios distributionUploadInternalPods
```
fastlane ios distributionUploadInternalPods
```
Lane to upload podspec to internal source podspec repos
### ios distributionUploadClientPods
```
fastlane ios distributionUploadClientPods
```
Lane to upload podspec to client source podspec repos

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
