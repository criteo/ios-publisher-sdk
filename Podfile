platform :ios, '9.0'

workspace 'CriteoPublisherSdk'

target 'CriteoPublisherSdk' do
  project 'CriteoPublisherSdk/CriteoPublisherSdk'
end

target 'CriteoPublisherSdkTests' do
  project 'CriteoPublisherSdk/CriteoPublisherSdk'
  platform :ios, '10.0'

  # Test libs
  pod 'OCMock', '~> 3.6'
  pod 'FunctionalObjC', '~> 1.0'

  # Third party SDKs
  pod 'Google-Mobile-Ads-SDK'
end

target 'CriteoAdViewer' do
  project 'CriteoAdViewer/CriteoAdViewer'
  platform :ios, '10.0'

  pod 'Google-Mobile-Ads-SDK'
  pod 'Eureka'
end

target 'CriteoGoogleAdapter' do
  project 'CriteoGoogleAdapter/CriteoGoogleAdapter'
  # As declared in podspec, iOS 9 is supported
  # This is a workaround to address a CocoaPods v1.10 regression:
  # https://github.com/CocoaPods/CocoaPods/issues/10106
  platform :ios, '10.0'

  pod 'Google-Mobile-Ads-SDK'
end

target 'CriteoGoogleAdapterTests' do
  project 'CriteoGoogleAdapter/CriteoGoogleAdapter'

  # Test libs
  pod 'OCMock', '~> 3.6'
end

# Development tools
pod 'SwiftLint', '~> 0.45.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
    end
  end
end
