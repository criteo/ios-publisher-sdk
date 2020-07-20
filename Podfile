platform :ios, '8.0'

workspace 'CriteoPublisherSdk.xcworkspace'
project 'CriteoPublisherSdk/CriteoPublisherSdk.xcodeproj'

target 'CriteoPublisherSdkTests' do
  # Test libs
  pod 'OCMock', '~> 3.6'
  pod 'FunctionalObjC', '~> 1.0'

  # Third party SDKs
  pod 'mopub-ios-sdk/Core'
  pod 'Google-Mobile-Ads-SDK'
end

target 'CriteoPublisherSdk' do
  pod 'Cassette', '~> 1.0-beta'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '8.0'
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
    end
  end
end
