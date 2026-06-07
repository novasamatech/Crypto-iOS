//
//  SNSigner.m
//  IrohaCrypto
//
//  Created by Ruslan Rezin on 23.06.2020.
//

#import "SNSigner.h"
#import "sr25519.h"

@interface SNSigner()

@property(strong, nonatomic)_Nonnull id<SNKeypairProtocol> keypair;

@end

@implementation SNSigner

- (nonnull instancetype)initWithKeypair:(id<SNKeypairProtocol> _Nonnull)keypair {
    if (self = [super init]) {
        self.keypair = keypair;
    }

    return self;
}

- (nullable SNSignature*)sign:(nonnull NSData*)originalData
                              error:(NSError*_Nullable*_Nullable)error {
    uint8_t signatureBytes[SR25519_SIGNATURE_SIZE];

    Sr25519SignatureResult result = sr25519_sign(signatureBytes,
                 _keypair.publicKey.rawData.bytes,
                 _keypair.privateKey.rawData.bytes,
                 originalData.bytes,
                 originalData.length);

    if (result != Ok) {
        if (error) {
            *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                         code:0
                                     userInfo:@{NSLocalizedDescriptionKey: @"sr25519 signing failed"}];
        }
        return nil;
    }

    NSData *signatureData = [NSData dataWithBytes:signatureBytes length:SR25519_SIGNATURE_SIZE];

    return [[SNSignature alloc] initWithRawData:signatureData error:error];
}

@end
