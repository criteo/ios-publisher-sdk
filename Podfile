platform :ios, '8.0'

workspace 'CriteoPublisherSdk'

target 'CriteoPublisherSdk' do
  project 'CriteoPublisherSdk/CriteoPublisherSdk'
  pod 'Cassette', '~> 1.0-beta'
end

target 'CriteoPublisherSdkTests' do
  project 'CriteoPublisherSdk/CriteoPublisherSdk'
  platform :ios, '10.0' # iOS 10 required by MoPub

  # Test libs
  pod 'OCMock', '~> 3.6'
  pod 'FunctionalObjC', '~> 1.0'

  # Third party SDKs
  pod 'mopub-ios-sdk/Core', '~> 5.13'
  pod 'Google-Mobile-Ads-SDK'
end

target 'CriteoMoPubAdapter' do
  project 'CriteoMoPubAdapter/CriteoMoPubAdapter'
  platform :ios, '10.0' # iOS 10 required by MoPub

  pod 'mopub-ios-sdk/Core', '~> 5.13'
end

target 'CriteoMoPubAdapterTests' do
  project 'CriteoMoPubAdapter/CriteoMoPubAdapter'

  # Test libs
  pod 'OCMock', '~> 3.6'
end

target 'CriteoMoPubAdapterTestApp' do
  project 'CriteoMoPubAdapter/CriteoMoPubAdapterTestApp'
  platform :ios, '10.0' # iOS 10 required by MoPub

  pod 'mopub-ios-sdk/Core', '~> 5.13'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '8.0'
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
    end
  end
end
