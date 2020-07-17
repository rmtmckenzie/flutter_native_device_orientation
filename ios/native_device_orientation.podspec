#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint native_device_orientation.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'native_device_orientation'
  s.version          = '0.0.1'
  s.summary          = 'Support code for flutter native_device_orientation.'
  s.description      = <<-DESC
Flutter plugin code for reading device orientation.
                       DESC
  s.homepage         = 'https://github.com/rmtmckenzie/flutter_native_device_orientation'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'rmtmckenzie' => 'rmtmckenzie@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
