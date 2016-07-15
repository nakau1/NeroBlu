Pod::Spec.new do |s|
  s.name         = "NeroBluHUD"
  s.version      = "1.0.0"
  s.summary      = "NeroBlu + HUD."
  s.description  = ""
  s.frameworks   = "Foundation", "UIKit"
  s.source       = { :git => "https://github.com/nakau1/NeroBlu" }
  s.source_files = "NeroBlu/*"
  s.dependency 'SVProgressHUD'
end
