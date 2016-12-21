Pod::Spec.new do |s|
  s.name         = "NeroBlu"
  s.version      = "2.0.0"
  s.summary      = "NeroBlu iOS Core Library."
  s.license      = { :type => 'MIT' }
  s.description  = "NeroBlu core utilities library for swift3"
  s.authors      = { "NeroBlu" => "neroblu@neroblu.com" }
  s.homepage     = "https://github.com/nakau1/NeroBlu/blob/master/README.md"
  s.frameworks   = "Foundation", "UIKit"
  s.source       = { :git => "https://github.com/nakau1/NeroBlu.git" }
  s.source_files = "NeroBlu/*"
  s.xcconfig = {
    'SWIFT_VERSION' => '3'
  }
end
