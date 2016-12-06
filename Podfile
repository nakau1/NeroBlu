# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'NeroBlu' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!

  pod 'Realm', :git => 'https://github.com/realm/realm-cocoa.git', :submodules => true
  pod 'RealmSwift', :git => 'https://github.com/realm/realm-cocoa.git', :submodules => true

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = "3.0"
        end
    end
end
