Pod::Spec.new do |s|

  s.name         = "GenericConnectionFramework"
  s.version      = "6.4.1"
  s.summary      = "mobileforming internal library for handling web service connections."
  s.description  = "Module to be used for mobileforming development.  RxSwift compatibile this should bootstrap all future iOS web service development."
  s.homepage     = "https://gitlab.mobileforming.com/mp/mobileforming-ios-module-gcf.git"
  s.license      = { :type => 'MIT', :text => <<-LICENSE
                   [2018] mobileforming, LLC. All Rights Reserved.
                   NOTICE:  All information contained herein is, and remains
                   the property of mobileforming, LLC.  The intellectual and technical concepts contained
                   herein are proprietary to mobileforming, LLC,
                   and may be covered by U.S. and Foreign Patents,
                   patents in process, and are protected by trade secret or copyright law.
                   Dissemination of this information or reproduction of this material
                   is strictly forbidden unless prior written permission is obtained
                   from mobileforming, LLC.
                   LICENSE
                   }
  s.author       = "mobileforming LLC"
  s.platform     = :ios, "9.0"
  
  s.ios.deployment_target = '10.2'
  s.swift_version = '4.0'
  
  s.source 		 = { :git => 'https://gitlab.mobileforming.com/mp/mobileforming-ios-module-gcf.git', :tag => "#{s.version}" }
  s.source_files = 'GenericConnectionFramework/*.{h,m,swift}', 'GenericConnectionFramework/**/*.{h,m,swift}' 

  
end
  
