# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
use_frameworks!
inhibit_all_warnings!

target 'SoundCloud Pro' do
  # swift pods, need use_frameworks
  pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git', :branch => 'xcode7'
  pod 'Bond', :git => 'https://github.com/SwiftBond/Bond.git', :branch => 'swift-2.0'
  pod 'Alamofire', :git => 'https://github.com/Alamofire/Alamofire.git', :branch => 'swift-2.0'

  # obj-c pods, need to include header path in build settings
  pod 'Parse'
  pod 'CocoaSoundCloudAPI', '1.0.1'
  pod 'StreamingKit'
  pod 'SCLAlertView-Objective-C'
  pod 'SVPullToRefresh'
  pod 'BOZPongRefreshControl'
end

target 'SoundCloud ProTests' do

end

