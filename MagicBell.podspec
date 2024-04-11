#
# Be sure to run `pod lib lint MagicBell.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MagicBell'
  s.version          = '2.0.0'
  s.summary          = 'Official MagicBell SDK for Swift'
  s.description      = 'Official MagicBell SDK for Swift. The notification inbox for your product.'

  s.homepage         = 'https://magicbell.com'
  s.license          = { :type => 'Custom', :file => 'LICENSE' }
  s.author           = { 'MagicBell' => 'hello@magicbell.com' }
  s.source           = { :git => 'https://github.com/magicbell-io/magicbell-swift.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/magicbell_io'

  s.osx.deployment_target = '10.15'
  s.ios.deployment_target = '12.0'

  s.swift_versions = ['5.3', '5.4', '5.5']

  s.source_files = 'Source/**/*.swift'

  s.dependency 'Harmony', '2.0.0'
  s.dependency 'Ably', '1.2.27'
end
