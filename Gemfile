source "https://rubygems.org"

ruby "3.2.2"

gem "cocoapods"
gem "fastlane", '2.198.1'
gem "iostrust"
gem "unf_ext", '0.0.8.2'
gem "json", '2.6.3'

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
