source "https://rubygems.org"

gem "xcodeproj", '1.23.0'
gem "cocoapods", '1.15.2'
gem "fastlane", '2.220.0'
gem "iostrust"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
