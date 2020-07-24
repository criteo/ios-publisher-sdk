platform :ios, '9.0'

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

target 'CriteoGoogleAdapter' do
  project 'CriteoGoogleAdapter/CriteoGoogleAdapter'

  pod 'Google-Mobile-Ads-SDK'
end

target 'CriteoGoogleAdapterTests' do
  project 'CriteoGoogleAdapter/CriteoGoogleAdapter'

  # Test libs
  pod 'OCMock', '~> 3.6'
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
  project 'CriteoMoPubAdapterTestApp/CriteoMoPubAdapterTestApp'
  platform :ios, '10.0' # iOS 10 required by MoPub

  pod 'mopub-ios-sdk/Core', '~> 5.13'
end

