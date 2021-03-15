Pod::Spec.new do |spec|
  spec.name              = "CriteoPublisherSdk"
  spec.version           = "4.3.0"
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
  spec.ios.deployment_target = "9.0"
  spec.swift_version         = "5.0"
  spec.static_framework      = true # Required by Google Sdk

  spec.source            = {
    :git => "https://github.com/criteo/ios-publisher-sdk.git",
    :tag => spec.version
  }

  spec.requires_arc      = true
  spec.default_subspecs  = "Sdk"

  spec.subspec "Sdk" do |sdk|
    sdk.source_files         = "CriteoPublisherSdk/Sources/**/*.{h,m,swift}"
    sdk.public_header_files  = "CriteoPublisherSdk/Sources/Public/*.h"
    sdk.weak_frameworks      = "WebKit"
  end

  spec.subspec "GoogleAdapter" do |adapter|
    adapter.source_files     = "CriteoGoogleAdapter/Sources/**/*.{h,m}"
    adapter.dependency         "CriteoPublisherSdk/Sdk"
    adapter.dependency         "Google-Mobile-Ads-SDK", ">= 7.49", "<9"

    # Xcode 12 workaround: https://github.com/CocoaPods/CocoaPods/issues/10065
    adapter.pod_target_xcconfig   = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 arm64e armv7 armv7s i386', 'EXCLUDED_ARCHS[sdk=iphoneos*]' => 'i386 x86_64' }
    adapter.user_target_xcconfig  = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 arm64e armv7 armv7s i386', 'EXCLUDED_ARCHS[sdk=iphoneos*]' => 'i386 x86_64' }
  end

  spec.subspec "MoPubAdapter" do |adapter|
    adapter.source_files     = "CriteoMoPubAdapter/Sources/**/*.{h,m}"
    adapter.exclude_files    = "CriteoMoPubAdapter/Sources/CriteoMoPubAdapterTestApp"
    adapter.dependency         "CriteoPublisherSdk/Sdk"
    adapter.dependency         "mopub-ios-sdk", "~> 5.13"
    adapter.ios.deployment_target = "10.0"

    # Xcode 12 workaround: https://github.com/CocoaPods/CocoaPods/issues/10065
    adapter.pod_target_xcconfig   = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 arm64e armv7 armv7s', 'EXCLUDED_ARCHS[sdk=iphoneos*]' => 'i386 x86_64' }
    adapter.user_target_xcconfig  = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 arm64e armv7 armv7s', 'EXCLUDED_ARCHS[sdk=iphoneos*]' => 'i386 x86_64' }
  end

end
