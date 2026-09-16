Pod::Spec.new do |s|
  s.name             = 'KitoButtons'
  s.version          = '1.3.0'
  s.summary          = 'Themeable SwiftUI buttons with variants, sizes, phases, fly-to-cart and add-to-cart animations.'
  s.description      = <<-DESC
    KitoButtons is a pure-SwiftUI button toolkit: KitoButton (six variants, three sizes, icons,
    loading/success/failure phases with icon morphing, async actions), KitoCartButton with seven
    choreographed add-to-cart animations, a fly-to-target flight system and a bouncing badge button.
  DESC
  s.homepage         = 'https://github.com/wykeenjenga/KitoButtons'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Wycliff Njenga' => 'wycliff@triply.co' }
  s.source           = { :git => 'https://github.com/wykeenjenga/KitoButtons.git', :tag => s.version.to_s }
  s.social_media_url = 'https://x.com/wycliffnjenga2'

  s.ios.deployment_target = '15.0'
  s.osx.deployment_target = '12.0'
  s.swift_versions   = ['5.9']
  s.frameworks       = 'SwiftUI'
  s.source_files     = 'Sources/KitoButtons/**/*.swift'
end
