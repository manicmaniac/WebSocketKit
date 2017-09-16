Pod::Spec.new do |s|
  s.name         = "WebSocketKit"
  s.version      = "0.0.1"
  s.summary      = "An implementation of web socket using WebKit."
  s.homepage     = "https://github.com/manicmaniac/WebSocketKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Ryosuke Ito" => "rito.0305@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/manicmaniac/WebSocketKit.git", :tag => "#{s.version}" }
  s.source_files  = "WebSocketKit/WebSocketKit.h", "WebSocketKit/Classes/**/*.{h,m}"
  s.public_header_files = "WebSocketKit/WebSocketKit.h", "WebSocketKit/Classes/**/*.h"
  s.frameworks = "Foundation", "WebKit"
  s.requires_arc = true
end
