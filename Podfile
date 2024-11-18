# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Adf Ready' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Adf Ready

   pod 'Firebase/Firestore'

   pod 'Firebase/Analytics'
   
   pod 'Firebase/Storage'
   
   pod 'Firebase/Messaging'
   
   pod 'Firebase/Auth'

   pod 'FirebaseFirestoreSwift'

   pod 'MBProgressHUD', '~> 1.2.0'
   
   pod 'SDWebImage', '~> 5.0'

   pod 'CropViewController'
   
   pod 'IQKeyboardManagerSwift'
   
   pod 'lottie-ios'

   pod 'TTGSnackbar'
   
   pod 'SwiftyGif'
   
   pod 'FirebaseFunctions'
   
   pod 'GooglePlaces'
   
   pod 'GeoFire/Utils'
   
   
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    # First part: Modify BoringSSL-GRPC compiler flags
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        if file.settings && file.settings['COMPILER_FLAGS']
          flags = file.settings['COMPILER_FLAGS'].split
          flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
          file.settings['COMPILER_FLAGS'] = flags.join(' ')
        end
      end
    end

    # Second part: Set deployment target and modify xcconfig
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.2'
      xcconfig_path = config.base_configuration_reference.real_path
      xcconfig = File.read(xcconfig_path)
      xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
      File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
    end
  end
end
