// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NovaCrypto",
    products: [
        .library(
            name: "NovaCrypto",
            targets: [
                "NovaCrypto"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/novasamatech/secp256k1.c", exact: "0.1.4"),
        .package(url: "https://github.com/novasamatech/ed25519.c", exact: "0.1.2"),
        .package(url: "https://github.com/novasamatech/sr25519.c", exact: "0.1.1"),
        .package(url: "https://github.com/novasamatech/blake2.c", exact: "0.1.1"),
        .package(url: "https://github.com/v57/scrypt.c", exact: "0.1.1")
    ],
    targets: targets + testTargets,
    swiftLanguageVersions: [.v5]
)

var targets: [Target] {
    [
        .target(
            name: "NovaCrypto",
            dependencies: [
                "BIP39",
                "blake2",
                "ed25519",
                "ScryptExtension",
                "secp256k1",
                "sr25519",
                "ss58",
                "Common"
            ]
        ),
        .target(
            name: "Common",
            publicHeadersPath: "."
        ),
        .target(
            name: "BIP39",
            dependencies: [
                "Common"
            ],
            publicHeadersPath: "."
        ),
        .target(
            name: "blake2",
            dependencies: [
                .product(name: "blake2.c", package: "blake2.c")
            ],
            publicHeadersPath: "."
        ),
        .target(
            name: "ed25519",
            dependencies: [
                .product(name: "ed25519.c", package: "ed25519.c"),
                "Common"
            ],
            publicHeadersPath: "."
        ),
        .target(
            name: "secp256k1",
            dependencies: [
                .product(name: "secp256k1.c", package: "secp256k1.c"),
                "Common"
            ],
            publicHeadersPath: "."
        ),
        .target(
            name: "ScryptExtension",
            dependencies: [
                .product(name: "scrypt", package: "scrypt.c"),
                "Common"
            ],
            path: "Sources/Scrypt",
            publicHeadersPath: "."
        ),
        .target(
            name: "sr25519",
            dependencies: [
                .product(name: "sr25519.c", package: "sr25519.c"),
                "Common",
                "BIP39"
            ],
            sources: ["."],
            publicHeadersPath: "."
        ),
        .target(
            name: "ss58",
            dependencies: [
                "Common",
                "blake2"
            ],
            publicHeadersPath: "."
        )
    ]
}
var testTargets: [Target] {
    [
        .testTarget(
            name: "CommonTests",
            dependencies: [
                "Common"
            ],
            path: "Tests/Common",
            resources: [
                .process("base58test.json")
            ],
            cSettings: [
                .headerSearchPath("..")
            ]
        ),
        .testTarget(
            name: "Blake2sTests",
            dependencies: [
                "blake2",
                "Common"
            ],
            path: "Tests/Blake2s"
        ),
        .testTarget(
            name: "ed25519Tests",
            dependencies: [
                "ed25519"
            ],
            path: "Tests/ed25519"
        ),
        .testTarget(
            name: "ScryptTests",
            dependencies: [
                "ScryptExtension"
            ],
            path: "Tests/Scrypt",
            cSettings: [
                .headerSearchPath("..")
            ]
        ),
        .testTarget(
            name: "secp256k1Tests",
            dependencies: [
                "secp256k1",
                "blake2"
            ],
            path: "Tests/secp256k1"
        ),
        .testTarget(
            name: "SR25519Tests",
            dependencies: [
                "sr25519",
                "BIP39",
                "Common",
                "BIP39TestData"
            ],
            path: "Tests/SR25519",
            resources: [
                .process("kusamaPubkeyTestVectors.json"),
                .process("substrateTestVectors.json"),
            ]
        ),
        .testTarget(
            name: "ss58Tests",
            dependencies: [
                "ss58",
                "secp256k1",
                "sr25519"
            ],
            path: "Tests/ss58"
        ),
        .testTarget(
            name: "BIP39Tests",
            dependencies: [
                "BIP39",
                "BIP39TestData"
            ],
            path: "Tests/BIP39",
            resources: [
                .process("bip39vectors.json")
            ],
            cSettings: [
                .headerSearchPath(".."),
            ]
        ),
        .target(
            name: "BIP39TestData",
            path: "Tests/BIP39TestData",
            publicHeadersPath: "."
        )
    ]
}
