Pod::Spec.new do |s|
  s.name             = 'CriteoGoogleMediationAdapters'
  s.version          = '3.6.1.0'
  s.summary          = 'Criteo Google Mediation Adapters'

  s.description      = <<-DESC
  This repository contains Criteo’s Adapter for Admob Mediation. It must be used in conjunction with the Criteo Publisher SDK. For requirements, instructions, and other info, see Integrating Criteo with Admob Mediation https://publisherdocs.criteotilt.com/app/ios/mediation/admob/
                       DESC

  s.homepage         = 'https://github.com/criteo/ios-publisher-sdk-google-adapters'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Criteo' => 'opensource@criteo.com' }
  s.source           = { :git => 'https://github.com/criteo/ios-publisher-sdk-google-adapters.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = '*.{m,h}'
  s.static_framework = true
  s.dependency 'CriteoPublisherSdk', '>= 3.6.1'
  s.dependency 'Google-Mobile-Ads-SDK', '>= 7.49.0'
end
