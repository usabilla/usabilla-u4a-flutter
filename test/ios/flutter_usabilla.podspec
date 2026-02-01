#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_usabilla.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_usabilla'
  s.version          = '2.5.0'
  s.summary          = 'A Flutter wrapper for Usabilla native iOS and Android SDKs.'
  s.description      = <<-DESC
A Flutter wrapper for Usabilla native iOS and Android SDKs.
                       DESC
  s.homepage         = 'https://github.com/usabilla/usabilla-u4a-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Usabilla' => 'support@usabilla.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '12.0'
  s.dependency 'Usabilla', '~> 6.5'
  s.static_framework = true
  s.ios.deployment_target = '12.0'
  s.swift_version    = '5.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
