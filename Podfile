# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

use_frameworks!

target 'GenericConnectionFramework' do

  target 'GenericConnectionFrameworkTests' do
  inherit! :search_paths
  end
end

target 'GenericConnectionFrameworkApp' do
end

post_install do |installer|
    installer.aggregate_targets.each do |target|
        # Without this hack resources from module tests won't make it to the unit test bundle
        # See https://github.com/CocoaPods/CocoaPods/issues/4752
        if target.name == "Pods-GenericConnectionFramework" then
            %x~ sed -i '' 's/CONFIGURATION_BUILD_DIR/TARGET_BUILD_DIR/g' '#{target.support_files_dir}/#{target.name}-resources.sh' ~
        end
    end
end

