## About

iOS crypto algorithms wrappers mainly used in Nova Wallet and Substrate SDK.

## Usage with Cocoapods

```
pod 'NovaCrypto', :git => 'https://github.com/novasamatech/Crypto-iOS.git', :tag => '0.1.0'
pod 'secp256k1.c', :git => 'https://github.com/novasamatech/secp256k1.c', :tag => '0.1.3'
pod 'sr25519.c', :git => 'https://github.com/novasamatech/sr25519.c', :tag => '0.1.0'
pod 'ed25519.c', :git => 'https://github.com/novasamatech/ed25519.c', :tag => '0.1.1'
pod 'blake2.c', :git => 'https://github.com/novasamatech/blake2.c', :tag => '0.1.0'
```

Note that implementation of the several algorithms used by NovaCrypto must be manually provided from suggested novasama repositories.

## Usage with Swift Package Manager

Add NovaCrypto to your package dependency
```
.package(url: "https://github.com/novasamatech/Crypto-iOS", branch: "master")
```

or to your project dependency
```
https://github.com/novasamatech/Crypto-iOS
```
