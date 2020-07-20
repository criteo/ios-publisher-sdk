#
# Be sure to run `pod lib lint CriteoPublisherSdk.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
  spec.name             = 'CriteoPublisherSdk'
  spec.version          = '3.8.0'
  spec.summary          = 'Criteo Publisher SDK for iOS'
  spec.description      = <<-DESC
    Criteo Publisher SDK maximizes revenue by directly connecting your premium
    inventory to our premium demand. That means you retain the full value of
    every impression we buy.
  DESC
  spec.homepage         = 'https://github.com/criteo/ios-publisher-sdk/'
  spec.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  spec.author           = { 'Criteo' => 'opensource@criteo.com' }
  spec.source           = { :http => "https://pubsdk-bin.criteo.com/publishersdk/ios/CriteoPublisherSdk_iOS_v#{spec.version}.Release.zip" }
  spec.vendored_frameworks = 'CriteoPublisherSdk.framework'
  spec.ios.deployment_target = '8.0'

  spec.platform          = :ios

  spec.weak_frameworks = 'WebKit'
end
