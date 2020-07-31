project 'AdViewer/AdViewer.xcodeproj'

platform :ios, '9.0'

target 'AdViewer' do
  workspace 'fuji-test-app'
  # pod 'CriteoPublisherSdk', '~> 3.0', '~> 3.0-alpha', '~> 3.0-beta', '~> 3.0-rc'
  pod 'mopub-ios-sdk/Core'
  pod 'Google-Mobile-Ads-SDK'
  pod 'Eureka'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
    end
  end
end

