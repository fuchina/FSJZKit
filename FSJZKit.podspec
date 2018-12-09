Pod::Spec.new do |s|
  s.name             = 'FSJZKit'
  s.version          = '0.0.2'
  s.summary          = 'FSJZKit is a tool for show logs when app run'
  s.description      = <<-DESC
		This is a very small software library, offering a few methods to help with programming.
    DESC

  s.homepage         = 'https://github.com/fuchina/FSJZKit.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fudon' => '1245102331@qq.com' }
  
  s.source           = { :git => 'https://github.com/fuchina/FSJZKit.git', :tag => s.version.to_s}
  
  s.source_files = 'FSJZKit/Classes/*.{h,m}'

  s.dependency   'FSKit'
  s.dependency   'FSShare'
  s.dependency   'FSDBMaster'
  s.dependency   'FSViewToImage'
  s.dependency   'FSTrack'
  s.dependency   'FSTuple'
  s.dependency   'FSCryptor'
  s.dependency   'FSBaseController'

  s.ios.deployment_target = '8.2'
  s.frameworks = 'UIKit'  

end
