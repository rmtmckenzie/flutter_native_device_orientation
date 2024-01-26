#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_device_orientation.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'native_device_orientation'
  s.version          = '0.0.1'
  s.summary          = 'Plugin to retrieve native device orientation'
  s.description      = <<-DESC
Plugin to retrieve native device orientation
                       DESC
  s.homepage         = 'https://github.com/rmtmckenzie/flutter_native_device_orientation'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'rmtmckenzie' => 'rmtmckenzie@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
