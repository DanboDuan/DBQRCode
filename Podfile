#use_frameworks!

platform :ios, '10.0'

target 'Demo' do
  pod 'DBQRCode', :path => './'
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings['CLANG_ANALYZER_LOCALIZABILITY_NONLOCALIZED'] = 'YES'
  end
end
