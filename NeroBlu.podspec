Pod::Spec.new do |s|
  s.name         = "NeroBluRealm"
  s.version      = "1.0.0"
  s.summary      = "NeroBlu + Realm"
  s.description  = ""
  s.frameworks   = "Foundation", "UIKit"
  s.source       = { :git => "https://github.com/nakau1/NeroBlu" }
  s.source_files = "NeroBlu/*"
  s.dependency 'Realm'
  s.dependency 'RealmSwift'
end
