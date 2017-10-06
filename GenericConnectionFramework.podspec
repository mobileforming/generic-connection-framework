Pod::Spec.new do |s|

s.name         = "GenericConnectionFramework"
s.version      = "0.1.0"
s.summary      = "mobileforming internal library for handling web service connections."
s.description  = "Module to be used for mobileforming development."
s.homepage     = "https://gitlab.mobileforming.com/mp/mobileforming-ios-module-gcf.git"
s.license          = { :type => 'INTERNAL', :file => 'LICENSE' }
s.author             = "mobileforming LLC"
s.platform     = :ios, "9.0"
s.source       = { :git => "https://gitlab.mobileforming.com/mp/mobileforming-ios-module-gcf.git", :tag => "#{s.version}" }
s.source_files  = "GenericConnectionFramework/*.{h,m,swift}", "GenericConnectionFramework/**/*.{h,m,swift}"
s.dependency "RxSwift", "~> 3.2"
s.dependency "RxCocoa", "~> 3.2"

end
