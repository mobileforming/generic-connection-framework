#!/bin/bash

################################################################################
# mobileforming build script template
# Define all build job variable parameters here
################################################################################
MOBILEOS="ios"
BUILD_KEYS="mf-ios-gcf-keys"
SCHEME="GenericConnectionFrameworkApp"
CONFIGURATION="Debug"
RUNLANE="coverageModule"


echo "## Jenkins Build shell execution for ${WORKSPACE}"

echo "## Moving the keys to the Fastlane directory"
mv keys/${BUILD_KEYS} fastlane/keys || echo WARNING: No secret keys found...continuing
mv keys/${BUILD_KEYS}.rb fastlane/keys.rb || echo WARNING: No Ruby include found...continuing

echo "## Sourcing the RVM directory to run the RVM set Ruby version, not systems ver"
source "$HOME/.rvm/scripts/rvm" || echo WARNING: Problem sourcing Ruby Version...continuing

echo "## Installing Bundler if need be"
gem install bundler

echo "## Installing Ruby Gems from Gemfile"
bundle install

if [ "$MOBILEOS" == "ios" ]; then
  echo "## iOS: Unlock the MAC keychain as the slave runs as a daemon"
  security unlock-keychain -p ${keychainPass} ~/Library/Keychains/login.keychain

  echo "## iOS: Update cocoapod repo shared by slave"
  cd ~ ; pwd
  pod repo update
  cd -
fi

echo "## Running Fastlane ${RUNLANE}"
fastlane ${MOBILEOS} ${RUNLANE} scheme:${SCHEME} configuration:${CONFIGURATION}
