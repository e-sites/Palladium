Pod::Spec.new do |s|
  s.name           = "Palladium"
  s.version        = "v1.1.1"
  s.platform       = :ios
  s.ios.deployment_target = "10.0"
  s.summary        = "A lightweight framework to schedule and cancel local notifications."
  s.author         = { "Bas van Kuijck" => "bas@e-sites.nl" }
  s.license        = { :type => "MIT", :file => "LICENSE" }
  s.homepage       = "https://github.com/e-sites/#{s.name}"
  s.source         = { :git => "https://github.com/e-sites/#{s.name}.git", :tag => s.version.to_s }
  s.source_files   = "Palladium/**/*.{h,swift}"
  s.requires_arc   = true
  s.frameworks    = 'Foundation', 'UserNotifications'
end
