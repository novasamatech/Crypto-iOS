//
//  SNVrfSignature.m
//  IrohaCrypto
//

#import "SNVrfSignature.h"
#import "sr25519.h"

@interface SNVrfSignature()

@property(copy, nonatomic) NSData *preOutput;
@property(copy, nonatomic) NSData *proof;

@end

@implementation SNVrfSignature

- (nullable instancetype)initWithPreOutput:(nonnull NSData*)preOutput
                                     proof:(nonnull NSData*)proof
                                     error:(NSError*_Nullable*_Nullable)error {
    if (preOutput.length != SR25519_VRF_OUTPUT_SIZE || proof.length != SR25519_VRF_PROOF_SIZE) {
        if (error) {
            *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                         code:0
                                     userInfo:@{NSLocalizedDescriptionKey: @"Invalid VRF signature component sizes"}];
        }
        return nil;
    }

    if (self = [super init]) {
        self.preOutput = preOutput;
        self.proof = proof;
    }

    return self;
}

- (nullable instancetype)initWithRawData:(nonnull NSData*)data
                                   error:(NSError*_Nullable*_Nullable)error {
    if (data.length != SR25519_VRF_OUTPUT_SIZE + SR25519_VRF_PROOF_SIZE) {
        if (error) {
            *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                         code:0
                                     userInfo:@{NSLocalizedDescriptionKey: @"Invalid VRF signature raw data size"}];
        }
        return nil;
    }

    if (self = [super init]) {
        self.preOutput = [data subdataWithRange:NSMakeRange(0, SR25519_VRF_OUTPUT_SIZE)];
        self.proof = [data subdataWithRange:NSMakeRange(SR25519_VRF_OUTPUT_SIZE, SR25519_VRF_PROOF_SIZE)];
    }

    return self;
}

- (nonnull NSData*)rawData {
    NSMutableData *data = [NSMutableData dataWithCapacity:SR25519_VRF_OUTPUT_SIZE + SR25519_VRF_PROOF_SIZE];
    [data appendData:self.preOutput];
    [data appendData:self.proof];
    return data;
}

@end
