Pod::Spec.new do |spec|
  spec.name              = "CriteoPublisherSdk"
  spec.version           = "3.8.0"
  spec.summary           = "Criteo Publisher SDK for iOS"

  spec.description       = <<-DESC
    Criteo Publisher SDK maximizes revenue by directly connecting your premium
    inventory to our premium demand. That means you retain the full value of
    every impression we buy.
  DESC
  spec.homepage          = "https://github.com/criteo/ios-publisher-sdk/"
  spec.license           = { :type => "Apache 2.0", :file => "LICENSE" }
  spec.author            = { "Criteo" => "opensource@criteo.com" }

  spec.platform              = :ios
  spec.ios.deployment_target = "8.0"

  spec.source           = { :http => "https://pubsdk-bin.criteo.com/publishersdk/ios/CriteoPublisherSdk_iOS_v#{spec.version}.Release.zip" }

  spec.vendored_frameworks = "CriteoPublisherSdk.framework"

  spec.weak_frameworks = "WebKit"
end
