source "https://rubygems.org"

# Cocoapods pinned to 1.9 as 1.10 breaking build:
# https://github.com/CocoaPods/CocoaPods/issues/10106
gem "cocoapods", "~>1.9.3"
gem "fastlane"
gem "iostrust"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
