#
#  Be sure to run `pod spec lint TPreventUnrecognizedSEL.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
    s.name                      = 'TPreventUnrecognizedSEL'
    s.version                   = '1.1.1'
    s.summary                   = <<-DESC
    Use TPreventUnrecognizedSEL can prevent the unrecognized selector crash.
    ⚠️You just can use one of NormalForwarding and FastForwarding⚠️.
                                    DESC
    s.description               = <<-DESC
    You just can use `FastForwarding` subspec **or**  use `NormalForwarding` subspec, you can not use both them at the same time.
    In podfile `pod 'TPreventUnrecognizedSEL/NormalForwarding'` to use `NormalForwarding` subspec;
    In podfile `pod 'TPreventUnrecognizedSEL/FastForwarding'` to use `FastForwarding` subspec;
    !!!  !!!
    !!! ⚠️Remember, **JUST USE ONE OF THEM** ⚠️!!!
    github : https://github.com/tobedefined/TPreventUnrecognizedSEL
                                    DESC
    s.homepage                  = 'https://github.com/tobedefined/TPreventUnrecognizedSEL'
    s.license                   = { :type => 'MIT', :file => 'LICENSE' }
    s.author                    = { 'ToBeDefined' => 'weinanshao@163.com' }
    s.social_media_url          = 'http://tbd.ink/'
    s.source                    = { :git => 'https://github.com/tobedefined/TPreventUnrecognizedSEL.git', :tag => s.version}
    s.frameworks                = 'Foundation'
    s.default_subspec           = 'NormalForwarding'
    s.requires_arc              = true
    s.ios.deployment_target     = '3.1'
    s.osx.deployment_target     = '10.6'
    s.tvos.deployment_target    = '9.0'
    s.watchos.deployment_target = '1.0'
  
    s.subspec 'NormalForwarding' do |ss|
        ss.public_header_files  = 'TPUSELNormalForwarding/Sources/*.h'
        ss.source_files         = 'TPUSELNormalForwarding/Sources/*.{h,m}'
    end

    s.subspec 'FastForwarding' do |ss|
      ss.public_header_files    = 'TPUSELFastForwarding/Sources/*.h'
      ss.source_files           = 'TPUSELFastForwarding/Sources/*.{h,m}'
    end
end

