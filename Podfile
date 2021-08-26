# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'uCubeSampleApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for uCubeSampleApp
  
  # Framework only
  #pod 'UCube', :git => 'git@github.com:YouTransactor/mPOS-SDK-IOS-Framework.git', :tag => 'v0.5.23'
  
  # Development
  pod 'UCube', :path => '../mPOS-SDK-IOS-Source-Code'

end

#Sets the Build library for distribution to yes for all pods 
post_install do |installer|
installer.pods_project.targets.each do |target|
target.build_configurations.each do |config|
config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
end
end
end
