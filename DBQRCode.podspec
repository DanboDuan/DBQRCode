#
# Be sure to run `pod lib lint BDAutoTracker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DBQRCode'
  s.version          = '0.0.1'
  s.summary          = 'QRCode'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/DanboDuan/DBQRCode'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'bob' => 'bob170131@gmail.com' }
  s.source           = { :git => 'https://github.com/DanboDuan/DBQRCode.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.public_header_files = 'DBQRCode/*.h'
  s.default_subspec = 'Core'
  s.requires_arc = true
  s.frameworks = 'Foundation','UIKit','AVFoundation','CoreImage','CoreGraphics'

  s.subspec 'Utility' do |utility|
        utility.source_files = 'DBQRCode/Utility/**/*.{h,m,c}'
  end

  s.subspec 'Core' do |core|
      core.source_files = 'DBQRCode/Core/**/*.{h,m,c}'
      core.dependency 'DBQRCode/Utility'
  end

end
