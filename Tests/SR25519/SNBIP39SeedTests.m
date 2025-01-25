//
//  SNBIP39SeedTests.m
//  IrohaCryptoTests
//
//  Created by Ruslan Rezin on 26.06.2020.
//  Copyright © 2020 Ruslan Rezin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SNBIP39SeedCreator.h"
#import "IRBIP39TestData+Load.h"

@interface SNBIP39SeedTests : XCTestCase

@end

@implementation SNBIP39SeedTests

- (void)testSubstrateSeedMatching {
    NSError *error = nil;

    NSString *testPassphrase = @"Substrate";
    NSBundle *testBundle;
#if SWIFT_PACKAGE
    testBundle = SWIFTPM_MODULE_BUNDLE;
#else
    testBundle = [NSBundle bundleForClass:[self class]];
#endif
    
    NSArray<IRBIP39TestData*> *tests = [IRBIP39TestData loadFromBundle: testBundle
                                                              filename:@"substrateTestVectors.json"
                                                              language:@"english"
                                                                 error:&error];

    if (error != nil) {
        NSString *message = [error localizedDescription];
        XCTFail("%@", message);
        return;
    }

    SNBIP39SeedCreator *seedCreator = [[SNBIP39SeedCreator alloc] init];

    for (IRBIP39TestData *testData in tests) {
        NSError *error = nil;

        NSData *entropy = [[NSData alloc] initWithHexString:testData.entropy error:&error];

        XCTAssertNil(error);

        NSData *seed = [seedCreator deriveSeedFrom:entropy
                                        passphrase:testPassphrase
                                             error:&error];

        XCTAssertNil(error);
        XCTAssertEqualObjects([seed toHexString], testData.seed);
    }
}

@end
