#============================================================================
# Copyright © 2022 YouTransactor.
# All Rights Reserved.
#
# This software is the confidential and proprietary information of YouTransactor
# ("Confidential Information"). You  shall not disclose or redistribute such
# Confidential Information and shall use it only in accordance with the terms of
# the license agreement you entered into with YouTransactor.
#
# This software is provided by YouTransactor AS IS, and YouTransactor
# makes no representations or warranties about the suitability of the software,
# either express or implied, including but not limited to the implied warranties
# of merchantability, fitness for a particular purpose or non-infringement.
# YouTransactor shall not be liable for any direct, indirect, incidental,
# special, exemplary, or consequential damages suffered by licensee as the
# result of using, modifying or distributing this software or its derivatives.
#
#==========================================================================#

# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'uCubeSampleApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for uCubeSampleApp
  
  # Framework only
  #pod 'UCube', :git => 'git@github.com:YouTransactor/mPOS-SDK-IOS-Framework.git', :tag => 'v0.5.28'
  
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
