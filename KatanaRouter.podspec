Pod::Spec.new do |s|
  s.name             = "KatanaRouter"
  s.version          = "0.4"
  s.summary          = "App Routing for Katana"
  s.description      = <<-DESC
						  Declarative and type-safe routing for Katana.
                        DESC
  s.homepage         = "https://github.com/michalciurus/KatanaRouter"
  s.license          = { :type => "MIT", :file => "LICENSE.md" }
  s.author           = { "Michal Ciurus" => "michael.ciurus@gmail.com" }
  s.social_media_url = "https://twitter.com/MichaelCiurus"
  s.source           = { :git => "https://github.com/michalciurus/KatanaRouter.git", :tag => s.version.to_s }
  s.ios.deployment_target = '8.3'
  s.osx.deployment_target = '10.10'	
  s.requires_arc = true
  s.source_files     = 'KatanaRouter/**/*.swift'
  s.dependency 'Katana', '~> 0.6.1'
end