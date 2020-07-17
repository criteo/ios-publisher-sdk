#
# Be sure to run `pod lib lint CriteoPublisherSdk.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CriteoPublisherSdk'
  s.version          = '3.8.0'
  s.summary          = 'Criteo Publisher SDK for iOS'
  s.description      = <<-DESC
    Criteo Publisher SDK maximizes revenue by directly connecting your premium
    inventory to our premium demand. That means you retain the full value of
    every impression we buy.
  DESC
  s.homepage         = 'https://github.com/criteo/ios-publisher-sdk/'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Criteo' => 'opensource@criteo.com' }
  s.source           = { :http => "https://pubsdk-bin.criteo.com/publishersdk/ios/CriteoPublisherSdk_iOS_v#{s.version}.Release.zip" }
  s.vendored_frameworks = 'CriteoPublisherSdk.framework'
  s.ios.deployment_target = '8.0'

  s.platform          = :ios

  s.weak_frameworks = 'WebKit'
end
