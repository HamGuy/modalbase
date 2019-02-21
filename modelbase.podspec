Pod::Spec.new do |s|
  s.name         = 'modelbase'
  s.version      = '1.2'
  s.license      =  :type => '<#License#>'
  s.homepage     = '<#Homepage URL#>'
  s.authors      =  '<#Author Name#>' => '<#Author Email#>'
  s.summary      = '<#Summary (Up to 140 characters#>'

# Source Info
  s.platform     =  :ios, '<#iOS Platform#>'
  s.source       =  :git => '<#Github Repo URL#>', :tag => '<#Tag name#>'
  s.source_files = '<#Resources#>'
  s.framework    =  '<#Required Frameworks#>'

  s.requires_arc = true
  
# Pod Dependencies
  s.dependencies =	pod 'MKNetworkKit'
  s.dependencies =	pod 'ASIHTTPRequest'
  s.dependencies =	pod 'MMDrawerController', '~> 0.5.3'
  s.dependencies =	pod 'FoundationExtension'
  s.dependencies =	pod 'FSImageViewer', '~> 2.4'
  s.dependencies =	pod 'SVPullToRefresh'
  s.dependencies =	pod 'UI7Kit'
  s.dependencies =	pod 'SDWebImage'
  s.dependencies =	pod 'JDStatusBarNotification'
  s.dependencies =	pod 'MagicalRecord'
  s.dependencies =	pod 'ZipArchive'
  s.dependencies =	pod 'AFNetworking'
  s.dependencies =	pod 'TestFlightSDK'

end