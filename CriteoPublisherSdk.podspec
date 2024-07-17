Pod::Spec.new do |spec|
  spec.name              = "CriteoPublisherSdk"
  spec.version           = "7.0.0"
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
  spec.ios.deployment_target = "13.0"
  spec.swift_version         = "5.0"
  spec.static_framework      = true # Required by Google Sdk

  spec.source            = {
    :git => "https://github.com/criteo/ios-publisher-sdk.git",
    :tag => spec.version
  }

  spec.requires_arc      = true
  spec.default_subspecs  = "Sdk"
  spec.dependency          "CriteoMRAID", "~> 1.0.1"

  spec.resource_bundles = {'CriteoPublisherSDK' => ['CriteoPublisherSDK/Sources/PrivacyInfo.xcprivacy']}

  spec.subspec "Sdk" do |sdk|
    sdk.source_files         = "CriteoPublisherSdk/Sources/**/*.{h,m,swift}"
    sdk.public_header_files  = "CriteoPublisherSdk/Sources/Public/*.h"
    sdk.weak_frameworks      = "WebKit"
  end

  spec.subspec "GoogleAdapter" do |adapter|
    adapter.source_files     = "CriteoGoogleAdapter/Sources/**/*.{h,m}"
    adapter.dependency         "CriteoPublisherSdk/Sdk"
    adapter.dependency         "Google-Mobile-Ads-SDK", "~> 11.1.0"
  end


end
