#
# Be sure to run `pod lib lint MagicBell.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MagicBell'
  s.version          = '0.1.0'
  s.summary          = 'Official MagicBell SDK for iOS.'

  s.description      = <<-DESC
This is the official MagicBell SDK for iOS. You can easily fetch, delete and create notifications.
                       DESC

  s.homepage         = 'https://magicbell.com'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'MagicBell' => 'hello@magicbell.com' }
  s.source           = { :git => 'https://javitb@bitbucket.org/javitb/magicbell-ios.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/magicbell_io'

  s.ios.deployment_target = '12.0'

  s.swift_versions = ['5.3', '5.4', '5.5']

  s.source_files = 'Source/**/*.swift'

  s.dependency 'Harmony/Repository'

  # s.resource_bundles = {
  #   'MagicBell' => ['MagicBell/Assets/*.png']
  # }

end
