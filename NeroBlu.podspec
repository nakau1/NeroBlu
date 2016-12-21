Pod::Spec.new do |s|
  s.name         = "NeroBlu"
  s.version      = "1.0.0"
  s.summary      = "NeroBlu iOS Core Library."
  s.description  = ""
  s.frameworks   = "Foundation", "UIKit"
  s.source       = { :git => "https://github.com/nakau1/NeroBlu" }
  s.source_files = "NeroBlu/*"
  s.xcconfig = {
    'SWIFT_VERSION' => '3'
  }
end
