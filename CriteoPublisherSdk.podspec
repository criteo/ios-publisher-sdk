Pod::Spec.new do |spec|
  spec.name              = "CriteoPublisherSdk"
  spec.version           = "3.9.0-rc2"
  spec.summary           = "Criteo Publisher SDK for iOS"

  spec.description       = <<-DESC
    Criteo Publisher SDK maximizes revenue by directly connecting your premium
    inventory to our premium demand. That means you retain the full value of
    every impression we buy.
  DESC
  spec.homepage          = "https://github.com/criteo/ios-publisher-sdk/"
  spec.documentation_url = "https://publisherdocs.criteotilt.com/app/ios/get-started/"
  spec.license           = { :type => "Apache 2.0", :file => "LICENSE" }
  spec.author            = { "Criteo" => "opensource@criteo.com" }

  spec.platform              = :ios
  spec.ios.deployment_target = "8.0"

  spec.source           = {
   :http => "https://github.com/criteo/ios-publisher-sdk/releases/download/#{spec.version}/CriteoPublisherSdk.Release.zip"
  }

  spec.vendored_frameworks = "CriteoPublisherSdk.framework"

  spec.weak_frameworks = "WebKit"
end
