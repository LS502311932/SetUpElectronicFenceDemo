# Uncomment this line to define a global platform for your project

source 'https://github.com/CocoaPods/Specs.git'
install! 'cocoapods', :deterministic_uuids => false

platform :ios, '9.0'
target 'ElectronicFenceDemo' do
inhibit_all_warnings!
    pod 'AMap3DMap', '~>6.3.0'
    pod 'AMapSearch' #搜索服务SDK
    pod 'AMapLocation'
    pod 'AMapNavi'#这个要放到其他高德sdk后
    pod 'JZLocationConverter'#gps纠偏
    pod 'JSONModel'

  target 'ElectronicFenceDemoTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ElectronicFenceDemoUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
