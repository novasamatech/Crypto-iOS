//
//  SNKeyFactoryTests.m
//  IrohaCryptoTests
//
//  Created by Ruslan Rezin on 26.06.2020.
//  Copyright © 2020 Ruslan Rezin. All rights reserved.
//

@import XCTest;
#import "SNKeyFactory.h"
#import "SNBIP39SeedCreator.h"
#import "SNAccountTestData+Load.h"

enum {
    kSecretSize = 64,
    kPublicSize = 32,
    kSeedSize   = 32
};

@interface SNKeyFactoryTests : XCTestCase

@property(nonatomic, strong)SNKeyFactory *keysFactory;

@end

@implementation SNKeyFactoryTests

- (void)setUp {
    [super setUp];

    _keysFactory = [[SNKeyFactory alloc] init];
}

- (void)tearDown {
    _keysFactory = nil;

    [super tearDown];
}

- (void)testKeypairDeriviationFromSeed {
    NSError *error = nil;

    NSBundle *testBundle;
#if SWIFT_PACKAGE
    testBundle = SWIFTPM_MODULE_BUNDLE;
#else
    testBundle = [NSBundle bundleForClass:[self class]];
#endif
    NSArray<SNAccountTestData*> *tests = [SNAccountTestData loadFromBundle: testBundle
                                                                  filename:@"kusamaPubkeyTestVectors.json"
                                                                  language:@"english"
                                                                     error:&error];

    if (error != nil) {
        NSString *message = [error localizedDescription];
        XCTFail("%@", message);
        return;
    }

    SNBIP39SeedCreator *seedCreator = [[SNBIP39SeedCreator alloc] init];
    IRMnemonicCreator *mnemonicCreator = [[IRMnemonicCreator alloc] initWithLanguage:IREnglish];
    SNKeyFactory *keypairFactory = [[SNKeyFactory alloc] init];

    for (SNAccountTestData *testData in tests) {
        NSError *error = nil;

        id<IRMnemonicProtocol> mnemonic = [mnemonicCreator mnemonicFromList:testData.mnemonic
                                                                      error:&error];

        if (error != nil) {
            NSString *message = [error localizedDescription];
            XCTFail("%@", message);
            return;
        }

        NSData *fullSeed = [seedCreator deriveSeedFrom:mnemonic.entropy
                                        passphrase:@""
                                             error:&error];

        if (error != nil) {
            NSString *message = [error localizedDescription];
            XCTFail("%@", message);
            return;
        }

        NSData *seed = [fullSeed subdataWithRange:NSMakeRange(0, 32)];

        XCTAssertEqualObjects([seed toHexString], testData.seed);

        SNKeypair *keypair = [keypairFactory createKeypairFromSeed:seed
                                                             error:&error];

        if (error != nil) {
            NSString *message = [error localizedDescription];
            XCTFail("%@", message);
            return;
        }

        XCTAssertEqualObjects([keypair.publicKey.rawData toHexString], testData.publicKey);
    }
}

#pragma mark - Length guard

- (void)testReturnsNilAndErrorOnShortSecret {
    NSData *secret = [NSData dataWithBytes:(uint8_t[]){0} length:kSeedSize];
    NSError *error = nil;
    SNPublicKey *publicKey = [self.keysFactory createPublicKeyFromSecret:secret error:&error];
    XCTAssertNil(publicKey);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, SNKeyFactoryErrorInvalidSecret);
}

- (void)testReturnsNilAndErrorOnLongSecret {
    NSMutableData *secret = [NSMutableData dataWithLength:kSecretSize + 1];
    NSError *error = nil;
    SNPublicKey *publicKey = [self.keysFactory createPublicKeyFromSecret:secret error:&error];
    XCTAssertNil(publicKey);
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, SNKeyFactoryErrorInvalidSecret);
}

- (void)testReturnsNilOnEmptySecret {
    NSError *error = nil;
    SNPublicKey *publicKey = [self.keysFactory createPublicKeyFromSecret:[NSData data] error:&error];
    XCTAssertNil(publicKey);
    XCTAssertNotNil(error);
}

- (void)testTolerantToNilErrorPointerOnLengthViolation {
    NSData *secret = [NSData dataWithBytes:(uint8_t[]){0} length:8];
    SNPublicKey *publicKey = [self.keysFactory createPublicKeyFromSecret:secret error:NULL];
    XCTAssertNil(publicKey);
}

- (void)testMatchesPublicKeyDerivedFromSameSeedKeypair {
    // Derive a keypair from a known seed, then re-derive the public key from
    // the keypair's secret bytes and verify equality.
    uint8_t seedBytes[kSeedSize];
    memset(seedBytes, 0xAB, kSeedSize);
    NSData *seed = [NSData dataWithBytes:seedBytes length:kSeedSize];

    NSError *error = nil;
    SNKeypair *keypair = [self.keysFactory createKeypairFromSeed:seed error:&error];
    XCTAssertNotNil(keypair);
    XCTAssertNil(error);

    NSData *secretBytes = [keypair.privateKey rawData];
    XCTAssertEqual(secretBytes.length, kSecretSize);

    NSError *deriveError = nil;
    SNPublicKey *derived = [self.keysFactory createPublicKeyFromSecret:secretBytes error:&deriveError];
    XCTAssertNotNil(derived);
    XCTAssertNil(deriveError);
    XCTAssertEqualObjects(derived.rawData, keypair.publicKey.rawData);
}

#pragma mark - Non-canonical input (Rust returns error)

- (void)testAllZeroSecretIsAccepted {
    // schnorrkel 0.9.1 accepts all-zero 64-byte secret (zero scalar + zero nonce)
    NSMutableData *secret = [NSMutableData dataWithLength:kSecretSize];
    NSError *error = nil;
    SNPublicKey *publicKey = [self.keysFactory createPublicKeyFromSecret:secret error:&error];
    XCTAssertNotNil(publicKey);
    XCTAssertNil(error);
}

- (void)testAllOnesSecretShouldReturnError {
    uint8_t bytes[kSecretSize];
    memset(bytes, 0xFF, kSecretSize);
    NSData *secret = [NSData dataWithBytes:bytes length:kSecretSize];
    NSError *error = nil;
    SNPublicKey *publicKey = [self.keysFactory createPublicKeyFromSecret:secret error:&error];
    XCTAssertNil(publicKey);
    XCTAssertNotNil(error);
}

- (void)testInvalidHighBitsShouldReturnError {
    uint8_t bytes[kSecretSize];
    memset(bytes, 0x01, kSecretSize);
    bytes[31] = 0xE0; // top 3 bits = 111, violates required 010
    NSData *secret = [NSData dataWithBytes:bytes length:kSecretSize];
    NSError *error = nil;
    SNPublicKey *publicKey = [self.keysFactory createPublicKeyFromSecret:secret error:&error];
    XCTAssertNil(publicKey);
    XCTAssertNotNil(error);
}

@end
