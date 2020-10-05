#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_usabilla.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_usabilla'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter wrapper for Usabilla native iOS and Android SDKs.'
  s.description      = <<-DESC
A Flutter wrapper for Usabilla native iOS and Android SDKs.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'
  s.dependency 'Usabilla', '~> 6.5'
  s.static_framework = true
  s.ios.deployment_target = '9.0'
  s.swift_version = '4.2'

end
