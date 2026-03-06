Pod::Spec.new do |s|
  s.name             = 'ss_preventer'
  s.version          = '0.1.0'
  s.summary          = 'Screenshot prevention and screenshot detection plugin for Flutter.'
  s.description      = <<-DESC
Flutter plugin that supports screenshot prevention and screenshot detection stream on iOS.
                       DESC
  s.homepage         = 'https://github.com/dl10yr/ss_preventer'
  s.license          = { :file => '../LICENSE' }
  s.author           = 'dl10yr'
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency       'Flutter'
  s.platform         = :ios, '13.0'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.swift_version = '5.0'
end
