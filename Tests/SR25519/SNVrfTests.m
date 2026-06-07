//
//  SNVrfTests.m
//  IrohaCryptoTests
//

@import XCTest;
#import "SNKeyFactory.h"
#import "SNVrfSigner.h"
#import "SNVrfVerifier.h"
#import "SNVrfField.h"
#import "sr25519.h"

@interface SNVrfTests : XCTestCase

@property(nonatomic, strong) SNKeyFactory *keyFactory;

@end

@implementation SNVrfTests

- (void)setUp {
    [super setUp];
    _keyFactory = [[SNKeyFactory alloc] init];
}

- (void)tearDown {
    _keyFactory = nil;
    [super tearDown];
}

- (NSData*)labelData {
    return [@"pop:airdrop" dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSArray<SNVrfField*>*)fieldsWithDomain:(NSData*)domain signer:(NSData*)signer {
    return @[
        [SNVrfField fieldWithKey:@"domain" value:domain],
        [SNVrfField fieldWithKey:@"signer" value:signer]
    ];
}

#pragma mark - Sign and verify roundtrip

- (void)testSignAndVerifyRoundtrip {
    uint8_t seedBytes[32];
    memset(seedBytes, 0xAB, 32);
    NSData *seed = [NSData dataWithBytes:seedBytes length:32];

    NSError *error = nil;
    SNKeypair *keypair = [_keyFactory createKeypairFromSeed:seed error:&error];
    XCTAssertNotNil(keypair);
    XCTAssertNil(error);

    NSData *label = [self labelData];
    uint8_t eventId[32];
    memset(eventId, 0x07, 32);
    NSMutableData *domain = [NSMutableData dataWithData:label];
    [domain appendBytes:eventId length:32];

    NSArray *fields = [self fieldsWithDomain:domain signer:keypair.publicKey.rawData];

    SNVrfSigner *signer = [[SNVrfSigner alloc] initWithKeypair:keypair];
    SNVrfSignature *signature = [signer signWithLabel:label fields:fields error:&error];
    XCTAssertNotNil(signature);
    XCTAssertNil(error);
    XCTAssertEqual(signature.preOutput.length, SR25519_VRF_OUTPUT_SIZE);
    XCTAssertEqual(signature.proof.length, SR25519_VRF_PROOF_SIZE);

    SNVrfVerifier *verifier = [[SNVrfVerifier alloc] init];
    BOOL valid = [verifier verify:signature publicKey:keypair.publicKey label:label fields:fields];
    XCTAssertTrue(valid);
}

#pragma mark - Deterministic pre-output

- (void)testDeterministicPreOutput {
    uint8_t seedBytes[32];
    memset(seedBytes, 0xCD, 32);
    NSData *seed = [NSData dataWithBytes:seedBytes length:32];

    NSError *error = nil;
    SNKeypair *keypair = [_keyFactory createKeypairFromSeed:seed error:&error];
    XCTAssertNotNil(keypair);

    NSData *label = [self labelData];
    uint8_t eventId[32];
    memset(eventId, 0x42, 32);
    NSMutableData *domain = [NSMutableData dataWithData:label];
    [domain appendBytes:eventId length:32];

    NSArray *fields = [self fieldsWithDomain:domain signer:keypair.publicKey.rawData];
    SNVrfSigner *signer = [[SNVrfSigner alloc] initWithKeypair:keypair];

    SNVrfSignature *sig1 = [signer signWithLabel:label fields:fields error:&error];
    SNVrfSignature *sig2 = [signer signWithLabel:label fields:fields error:&error];

    XCTAssertEqualObjects(sig1.preOutput, sig2.preOutput);
}

#pragma mark - Verification rejects wrong inputs

- (void)testVerifyFailsWithWrongPublicKey {
    uint8_t seedBytes[32];
    memset(seedBytes, 0x11, 32);
    NSData *seed = [NSData dataWithBytes:seedBytes length:32];

    uint8_t otherSeedBytes[32];
    memset(otherSeedBytes, 0x22, 32);
    NSData *otherSeed = [NSData dataWithBytes:otherSeedBytes length:32];

    NSError *error = nil;
    SNKeypair *keypair = [_keyFactory createKeypairFromSeed:seed error:&error];
    SNKeypair *otherKeypair = [_keyFactory createKeypairFromSeed:otherSeed error:&error];

    NSData *label = [self labelData];
    NSData *domain = [@"test-domain" dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *fields = [self fieldsWithDomain:domain signer:keypair.publicKey.rawData];

    SNVrfSigner *signer = [[SNVrfSigner alloc] initWithKeypair:keypair];
    SNVrfSignature *signature = [signer signWithLabel:label fields:fields error:&error];
    XCTAssertNotNil(signature);

    SNVrfVerifier *verifier = [[SNVrfVerifier alloc] init];
    BOOL valid = [verifier verify:signature publicKey:otherKeypair.publicKey label:label fields:fields];
    XCTAssertFalse(valid);
}

- (void)testVerifyFailsWithWrongLabel {
    uint8_t seedBytes[32];
    memset(seedBytes, 0x33, 32);
    NSData *seed = [NSData dataWithBytes:seedBytes length:32];

    NSError *error = nil;
    SNKeypair *keypair = [_keyFactory createKeypairFromSeed:seed error:&error];

    NSData *label = [self labelData];
    NSData *domain = [@"test-domain" dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *fields = [self fieldsWithDomain:domain signer:keypair.publicKey.rawData];

    SNVrfSigner *signer = [[SNVrfSigner alloc] initWithKeypair:keypair];
    SNVrfSignature *signature = [signer signWithLabel:label fields:fields error:&error];
    XCTAssertNotNil(signature);

    SNVrfVerifier *verifier = [[SNVrfVerifier alloc] init];
    NSData *wrongLabel = [@"wrong:label" dataUsingEncoding:NSUTF8StringEncoding];
    BOOL valid = [verifier verify:signature publicKey:keypair.publicKey label:wrongLabel fields:fields];
    XCTAssertFalse(valid);
}

- (void)testVerifyFailsWithWrongDomain {
    uint8_t seedBytes[32];
    memset(seedBytes, 0x44, 32);
    NSData *seed = [NSData dataWithBytes:seedBytes length:32];

    NSError *error = nil;
    SNKeypair *keypair = [_keyFactory createKeypairFromSeed:seed error:&error];

    NSData *label = [self labelData];
    NSData *domain = [@"correct-domain" dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *fields = [self fieldsWithDomain:domain signer:keypair.publicKey.rawData];

    SNVrfSigner *signer = [[SNVrfSigner alloc] initWithKeypair:keypair];
    SNVrfSignature *signature = [signer signWithLabel:label fields:fields error:&error];
    XCTAssertNotNil(signature);

    NSData *wrongDomain = [@"wrong-domain" dataUsingEncoding:NSUTF8StringEncoding];
    NSArray<SNVrfField*> *wrongFields = [self fieldsWithDomain:wrongDomain signer:keypair.publicKey.rawData];

    SNVrfVerifier *verifier = [[SNVrfVerifier alloc] init];
    BOOL valid = [verifier verify:signature publicKey:keypair.publicKey label:label fields:wrongFields];
    XCTAssertFalse(valid);
}

#pragma mark - VrfSignature raw data roundtrip

- (void)testVrfSignatureRawDataRoundtrip {
    uint8_t seedBytes[32];
    memset(seedBytes, 0x55, 32);
    NSData *seed = [NSData dataWithBytes:seedBytes length:32];

    NSError *error = nil;
    SNKeypair *keypair = [_keyFactory createKeypairFromSeed:seed error:&error];

    NSData *label = [self labelData];
    NSData *domain = [@"roundtrip" dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *fields = [self fieldsWithDomain:domain signer:keypair.publicKey.rawData];

    SNVrfSigner *signer = [[SNVrfSigner alloc] initWithKeypair:keypair];
    SNVrfSignature *original = [signer signWithLabel:label fields:fields error:&error];
    XCTAssertNotNil(original);

    NSData *raw = [original rawData];
    XCTAssertEqual(raw.length, SR25519_VRF_OUTPUT_SIZE + SR25519_VRF_PROOF_SIZE);

    SNVrfSignature *restored = [[SNVrfSignature alloc] initWithRawData:raw error:&error];
    XCTAssertNotNil(restored);
    XCTAssertEqualObjects(original.preOutput, restored.preOutput);
    XCTAssertEqualObjects(original.proof, restored.proof);
}

#pragma mark - Empty fields

- (void)testSignAndVerifyWithEmptyFields {
    uint8_t seedBytes[32];
    memset(seedBytes, 0x66, 32);
    NSData *seed = [NSData dataWithBytes:seedBytes length:32];

    NSError *error = nil;
    SNKeypair *keypair = [_keyFactory createKeypairFromSeed:seed error:&error];
    XCTAssertNotNil(keypair);

    NSData *label = [@"label-only" dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *fields = @[];

    SNVrfSigner *signer = [[SNVrfSigner alloc] initWithKeypair:keypair];
    SNVrfSignature *signature = [signer signWithLabel:label fields:fields error:&error];
    XCTAssertNotNil(signature);
    XCTAssertNil(error);

    SNVrfVerifier *verifier = [[SNVrfVerifier alloc] init];
    BOOL valid = [verifier verify:signature publicKey:keypair.publicKey label:label fields:fields];
    XCTAssertTrue(valid);
}

@end
