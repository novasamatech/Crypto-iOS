#
# Be sure to run `pod lib lint IrohaCrypto.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NovaCrypto'
  s.version          = '0.1.0'
  s.summary          = 'Provides object oriented wrappers for C/C++ crypto functions used by blockchains.'

  s.homepage         = 'https://github.com/novasamatech/Crypto-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ruslan Rezin' => 'ruslan@novawallet.io' }
  s.source           = { :git => 'https://github.com/novasamatech/Crypto-iOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '14.0'

  s.subspec 'Common' do |cn|
    cn.source_files = 'Sources/Common/**/*'
    cn.public_header_files = 'Sources/Common/**/*.h'
  end

  s.subspec 'BIP39' do |bip39|
    bip39.dependency 'NovaCrypto/Common'
    bip39.source_files = 'Sources/BIP39/**/*'
    bip39.public_header_files = 'Sources/BIP39/**/*.h'
  end

  s.subspec 'Scrypt' do |sct|
    sct.dependency 'NovaCrypto/Common'
    sct.dependency 'scrypt.c', '~> 0.1'
    sct.source_files = 'Sources/Scrypt/**/*'
    sct.public_header_files = 'Sources/Scrypt/**/*.h'
  end

  s.subspec 'sr25519' do |sr|
    sr.dependency 'NovaCrypto/blake2'
    sr.dependency 'NovaCrypto/Common'
    sr.dependency 'NovaCrypto/BIP39'
    sr.dependency 'sr25519.c', '~> 0.1.0'
    sr.source_files = 'Sources/sr25519/**/*'
    sr.public_header_files = 'Sources/sr25519/**/*.h'
  end

  s.subspec 'blake2' do |b2|
    b2.source_files = 'Sources/blake2/**/*'
    b2.dependency 'blake2.c', '~> 0.1.0'
  end

  s.subspec 'secp256k1' do |secp|
    secp.dependency 'NovaCrypto/Common'
    secp.dependency 'secp256k1.c', '~> 0.1'
    secp.source_files = 'Sources/secp256k1/**/*'
  end

  s.subspec 'ed25519' do |ed|
    ed.dependency 'NovaCrypto/Common'
    ed.dependency 'ed25519.c', '~> 0.1.0'
    ed.source_files = 'Sources/ed25519/**/*'
  end

  s.subspec 'ss58' do |ss|
    ss.dependency 'NovaCrypto/blake2'
    ss.dependency 'NovaCrypto/Common'
    ss.source_files = 'Sources/ss58/**/*'
    ss.public_header_files = 'Sources/ss58/**/*.h'
  end
  
  s.libraries = "sr25519"
  
  s.pod_target_xcconfig = { 'CLANG_WARN_DOCUMENTATION_COMMENTS' => "NO",
   'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => "YES",
   'LIBRARY_SEARCH_PATHS' => "${PODS_XCFRAMEWORKS_BUILD_DIR}/sr25519.c" }

end
