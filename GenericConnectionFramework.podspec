Pod::Spec.new do |s|

s.name         = "GenericConnectionFramework"
s.version      = "0.1.2"
s.summary      = "mobileforming internal library for handling web service connections."
s.description  = "Module to be used for mobileforming development.  RxSwift compatibile this should bootstrap all future iOS web service development."
s.homepage     = "https://gitlab.mobileforming.com/mp/mobileforming-ios-module-gcf.git"
s.license          = { :type => 'INTERNAL', :file => 'LICENSE' }
s.author             = "mobileforming LLC"
s.platform     = :ios, "9.0"
s.source       = { :git => "https://gitlab.mobileforming.com/mp/mobileforming-ios-module-gcf.git", :tag => "#{s.version}" }
s.source_files  = "GenericConnectionFramework/*.{h,m,swift}", "GenericConnectionFramework/**/*.{h,m,swift}"
s.dependency "RxSwift", "4.0.0-beta.1"

end
