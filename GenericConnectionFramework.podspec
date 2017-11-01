Pod::Spec.new do |s|

s.name         = "GenericConnectionFramework"
s.version      = "0.1.5"
s.summary      = "mobileforming internal library for handling web service connections."
s.description  = "Module to be used for mobileforming development.  RxSwift compatibile this should bootstrap all future iOS web service development."
s.homepage     = "https://gitlab.mobileforming.com/mp/mobileforming-ios-module-gcf.git"
s.license          = { :type => 'INTERNAL', :file => 'LICENSE' }
s.author             = "mobileforming LLC"
s.platform     = :ios, "9.0"
s.source       = { :http => 'http://nexus.mf.internal/com/mobileforming/ios/module/gcf/0.0.1/gcf-0.0.1.zip' }
s.vendored_frameworks = 'GenericConnectionFramework.framework'
s.dependency "RxSwift", "~> 4.0"

end
