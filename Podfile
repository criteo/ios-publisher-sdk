project 'AdViewer/AdViewer.xcodeproj'

platform :ios, '9.0'

target 'AdViewer' do
  workspace 'fuji-test-app'
  # pod 'CriteoPublisherSdk' # to get published SDK
  pod 'mopub-ios-sdk'
  pod 'Google-Mobile-Ads-SDK'
  pod 'Eureka', '~> 4.3'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
    end
  end
end

