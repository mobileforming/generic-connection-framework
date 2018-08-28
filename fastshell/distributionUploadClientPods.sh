#!/bin/bash

################################################################################
# Hilton iOS build script template
# Define all build job variable parameters here
################################################################################
MOBILEOS="ios"       
RUNLANE="distributionUploadClientPods"  
BUILD_KEYS="mf-ios-gcf-keys"   
SCHEME="Framework"      
CONFIGURATION="Debug"     
PLIST_PATH="GenericConnectionFramework/Info.plist"
FRAMEWORK_NAME="GenericConnectionFramework.framework"
PODSPEC_PATH="GenericConnectionFramework.podspec"
# Separate multiple repo URLs with a comma, NO SPACES!
PODSPEC_REPO_URLS="https://jira.hilton.com/stash/scm/hm/hiltoncn-pods.git"
SOURCE_URLS="https://jira.hilton.com/stash/scm/hm/mobileforming-ios-module-gcf.git"


################################################################################
# Optional parameters
################################################################################
_MF_BRANCH_JOB_CREATE="dev"
_MF_EMAIL_LIST="alan.downs@mobileforming.com bret.seemann@mobileforming.com"
_MF_QUIET_PERIOD=360


################################################################################
# DO NOT MODIFY BELOW THIS LINE
################################################################################
echo "## Build shell execution for ${WORKSPACE}"
export FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT=20

echo "## Moving the keys to the Fastlane directory"
mv keys/${BUILD_KEYS} fastlane/keys || echo WARNING: No secret keys found...continuing
mv keys/${BUILD_KEYS}.rb fastlane/keys.rb || echo WARNING: No Ruby include found...continuing

echo "## Sourcing the RVM directory to run the RVM set Ruby version, not the system version"
source "$HOME/.rvm/scripts/rvm" || echo WARNING: Problem sourcing Ruby Version...continuing

echo "## Installing Bundler if need be"
gem install bundler

echo "## Installing Ruby Gems from Gemfile"
bundle install

echo "## iOS: Unlock the MAC keychain as the slave runs as a daemon"
security unlock-keychain -p ${keychainPass} ~/Library/Keychains/login.keychain

echo "## Running Fastlane ${RUNLANE}"
fastlane "${MOBILEOS}" "${RUNLANE}" \
  scheme:"${SCHEME}" \
  configuration:"${CONFIGURATION}" \
  plistPath:"${PLIST_PATH}" \
  framework:"${FRAMEWORK_NAME}" \
  podspecFilePath:"${PODSPEC_PATH}" \
  podspecRepoURLS:"${PODSPEC_REPO_URLS}" \
  sourceURLS:"${SOURCE_URLS}" \
  gitBranch:"${GIT_BRANCH}"