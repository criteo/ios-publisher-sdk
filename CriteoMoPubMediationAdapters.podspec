Pod::Spec.new do |s|
  s.name             = 'CriteoMoPubMediationAdapters'
  s.version          = '3.5.0.0'
  s.summary          = 'Criteo MoPub Mediation Adapters'

  s.description      = <<-DESC
  This repository contains Criteo’s Adapter for MoPub Mediation. It must be used in conjunction with the Criteo Publisher SDK. For requirements, intructions, and other info, see Integrating Criteo with MoPub Mediation: https://publisherdocs.criteotilt.com/sdk-ios/3.1/mopub-mediation/
                       DESC

  s.homepage         = 'https://www.criteo.com'
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.author           = { 'Criteo' => 'github@criteo.com' }
  s.source           = { :git => 'https://github.com/criteo/ios-publisher-sdk-mopub-adapters.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = '*.{m,h}'
  s.static_framework = true
  s.dependency 'CriteoPublisherSdk', '>= 3.5.0'
  s.dependency 'mopub-ios-sdk/Core', '>= 5.6'
end
