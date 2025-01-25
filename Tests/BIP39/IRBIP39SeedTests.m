//
//  IRBIP39SeedTests.m
//  IrohaCryptoTests
//
//  Created by Ruslan Rezin on 27.02.2020.
//  Copyright © 2020 Ruslan Rezin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IRBIP39SeedCreator.h"
#import "IRBIP39TestData+Load.h"
#import "Constants.h"

@interface IRBIP39SeedTests : XCTestCase

@end

@implementation IRBIP39SeedTests

- (void)testSeedMatching {
    NSError *error = nil;

    NSString *testPassphrase = @"TREZOR";
    NSBundle *testBundle;
#if SWIFT_PACKAGE
    testBundle = SWIFTPM_MODULE_BUNDLE;
#else
    testBundle = [NSBundle bundleForClass:[self class]];
#endif
    NSArray<IRBIP39TestData*> *tests = [IRBIP39TestData loadFromBundle:testBundle
                                                              filename:@"bip39vectors.json"
                                                                language:@"english"
                                                                   error:&error];

    if (error != nil) {
        NSString *message = [error localizedDescription];
        XCTFail("%@", message);
        return;
    }

    IRBIP39SeedCreator *seedCreator = [[IRBIP39SeedCreator alloc] init];

    for (IRBIP39TestData *testData in tests) {
        NSError *error = nil;

        NSData *seed = [seedCreator deriveSeedFrom:testData.mnemonic
                                        passphrase:testPassphrase
                                             error:&error];

        XCTAssertNil(error);
        XCTAssertEqualObjects([seed toHexString], testData.seed);
    }
}

- (void)testPerformanceExample {

    IRBIP39SeedCreator *seedCreator = [[IRBIP39SeedCreator alloc] init];

    [self measureBlock:^{
        for (int index = 0; index < MNEMONIC_COUNT; index++) {
            [seedCreator deriveSeedFrom:MNEMONIC_STRING[index]
                             passphrase:@""
                                  error:nil];
        }
    }];
}

@end
