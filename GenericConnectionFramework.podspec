Pod::Spec.new do |s|

  s.name         = "GenericConnectionFramework"
  s.version      = "0.1.5"
  s.summary      = "mobileforming internal library for handling web service connections."
  s.description  = "Module to be used for mobileforming development.  RxSwift compatibile this should bootstrap all future iOS web service development."
  s.homepage     = "https://gitlab.mobileforming.com/mp/mobileforming-ios-module-gcf.git"
  s.license          = { :type => 'INTERNAL', :file => 'LICENSE' }
  s.author             = "mobileforming LLC"
  s.platform     = :ios, "9.0"
  s.dependency "RxSwift", "~> 4.0"

  s.default_subspec = 'Binary'

  s.subspec 'Binary' do |binary|
    binary.source = { :http => 'http://nexus.mf.internal/com/mobileforming/ios/module/gcf/0.0.1/gcf-0.0.1.zip' }
    binary.vendored_frameworks = 'GenericConnectionFramework.framework'
  end
  
  s.subspec 'Source' do |source|
    source.source = {
	  :http => 'https://gitlab.mobileforming.com/mp/mobileforming-ios-module-gcf.git',
	  :tag => s.version.to_s
	}
	source.source_files = "GenericConnectionFramework/*.{h,m,swift}", "GenericConnectionFramework/**/*.{h,m,swift}"
  end
	

end
