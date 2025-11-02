#import <XCTest/XCTest.h>
#import "NSData+Blake2.h"
#import "NSData+Hex.h"

static const int MESSAGES_COUNT = 4;

static NSString * const MESSAGES[] = {
    @"",
    @"00",
    @"0001",
    @"000102030405060708090a0b0c0d0e0f1011121314151617"
};

static NSString * const KEY2b_64 = @"000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f";

static NSString * const KEY2s_32 = @"000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f";

static NSString * const BLAKE2b_64[] = {
    @"10ebb67700b1868efb4417987acf4690ae9d972fb7a590c2f02871799aaa4786b5e996e8f0f4eb981fc214b005f42d2ff4233499391653df7aefcbc13fc51568",
    @"961f6dd1e4dd30f63901690c512e78e4b45e4742ed197c3c5e45c549fd25f2e4187b0bc9fe30492b16b0d0bc4ef9b0f34c7003fac09a5ef1532e69430234cebd",
    @"da2cfbe2d8409a0f38026113884f84b50156371ae304c4430173d08a99d9fb1b983164a3770706d537f49e0c916d9f32b95cc37a95b99d857436f0232c88a965",
    @"5e9c93158d659b2def06b0c3c7565045542662d6eee8a96a89b78ade09fe8b3dcc096d4fe48815d88d8f82620156602af541955e1f6ca30dce14e254c326b88f"
};

static NSString * const BLAKE2s_32[] = {
    @"48a8997da407876b3d79c0d92325ad3b89cbb754d86ab71aee047ad345fd2c49",
    @"40d15fee7c328830166ac3f918650f807e7e01e177258cdc0a39b11f598066f1",
    @"6bb71300644cd3991b26ccd4d274acd1adeab8b1d7914546c1198bbe9fc9d803",
    @"e3e3ace537eb3edd8463d9ad3582e13cf86533ffde43d668dd2e93bbdbd7195a"
};

@interface Blake2KeyedTests : XCTestCase

@end

@implementation Blake2KeyedTests

- (void)testBlake2b64 {
    NSError *error;
    
    NSData *keyData = [[NSData alloc] initWithHexString:KEY2b_64 error:&error];
    
    if (error != nil) {
        NSString *message = [error localizedDescription];
        XCTFail("%@", message);
        return;
    }
    
    for (int i = 0; i < MESSAGES_COUNT; i++) {
        NSData *message = [[NSData alloc] initWithHexString:MESSAGES[i] error:&error];
        NSData *hashedMessage = [message blake2b:64 key:keyData error:&error];

        if (error != nil) {
            NSString *message = [error localizedDescription];
            XCTFail("%@", message);
            return;
        }

        XCTAssertEqualObjects(BLAKE2b_64[i], [hashedMessage toHexString]);
    }
}

- (void)testBlake2s32 {
    NSError *error;
    
    NSData *keyData = [[NSData alloc] initWithHexString:KEY2s_32 error:&error];
    
    if (error != nil) {
        NSString *message = [error localizedDescription];
        XCTFail("%@", message);
        return;
    }
    
    for (int i = 0; i < MESSAGES_COUNT; i++) {
        NSData *message = [[NSData alloc] initWithHexString:MESSAGES[i] error:&error];
        NSData *hashedMessage = [message blake2s:32 key:keyData error:&error];

        if (error != nil) {
            NSString *message = [error localizedDescription];
            XCTFail("%@", message);
            return;
        }

        XCTAssertEqualObjects(BLAKE2s_32[i], [hashedMessage toHexString]);
    }
}

@end
