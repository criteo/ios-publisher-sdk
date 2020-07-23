Pod::Spec.new do |spec|
  spec.name              = "CriteoPublisherSdk"
  spec.version           = "4.0.0-alpha1"
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

  spec.source            = {
    :git => "https://github.com/criteo/ios-publisher-sdk.git",
    :tag => spec.version
  }

  spec.requires_arc      = true
  spec.default_subspecs  = "Sdk"

  spec.subspec "Sdk" do |sdk|
    sdk.source_files         = "CriteoPublisherSdk/Sources/**/*.{h,m}"
    sdk.private_header_files = "**/{CR_,CAS}*.h", "**/*+{Private,Internal}.h"
    sdk.weak_frameworks      = "WebKit"
    sdk.dependency             "Cassette", "~> 1.0-beta"
  end

  spec.subspec "MoPubAdapter" do |adapter|
    adapter.source_files     = "CriteoMoPubAdapter/Sources/**/*.{h,m}"
    adapter.exclude_files    = "CriteoMoPubAdapter/Sources/CriteoMoPubAdapterTestApp"
    adapter.dependency         "CriteoPublisherSdk/Sdk"
    adapter.dependency         "mopub-ios-sdk/Core", "~> 5.13"
    adapter.ios.deployment_target = "10.0"
  end

end
