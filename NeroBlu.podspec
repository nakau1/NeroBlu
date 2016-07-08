Pod::Spec.new do |s|
  s.name         = "NeroBluNet"
  s.version      = "1.0.0"
  s.summary      = "NeroBlu + Networking."
  s.description  = ""
  s.frameworks   = "Foundation", "UIKit"
  s.source       = { :git => "https://github.com/nakau1/NeroBlu" }
  s.source_files = "NeroBlu/*"
  s.dependency 'Alamofire'
  s.dependency 'SwiftyJSON'
end
