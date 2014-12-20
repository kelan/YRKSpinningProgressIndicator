Pod::Spec.new do |s|

  s.name         = "YRKSpinningProgressIndicator"
  s.version      = "1.4"
  s.summary      = "A resizable, recolorable clone of the spinning NSProgressIndicator."
  s.homepage     = "http://github.com/kelan/YRKSpinningProgressIndicator"

  s.description  = <<-DESC
                   YRKSpinningProgressIndicator is a clone of the "Spinning style" NSProgressIndicator that can be set to an arbitrary size and color. The background color can also be set, or it can be transparent. You can even change the color in real-time while it's animating. SPIDemo is an app to demo its use.
                   DESC

  s.license      = { :type => 'BSD', :file => 'BSD-LICENSE.txt' }
  s.author       = { "Kelan Champagne" => "kelan@yeahrightkeller.com" }
  s.platform     = :osx, "10.7"
  s.source       = { :git => "https://github.com/kelan/YRKSpinningProgressIndicator.git", :tag => "1.4" }
  s.source_files = "Classes", "Classes/*.{h,m}"
  s.requires_arc = true

end
