//
//  SNVrfSignature.m
//  IrohaCrypto
//

#import "SNVrfSignature.h"
#import "sr25519.h"

const NSUInteger SNVrfPreOutputSize = SR25519_VRF_OUTPUT_SIZE;
const NSUInteger SNVrfProofSize = SR25519_VRF_PROOF_SIZE;

@interface SNVrfSignature()

@property(copy, nonatomic) NSData *preOutput;
@property(copy, nonatomic) NSData *proof;

@end

@implementation SNVrfSignature

- (nullable instancetype)initWithPreOutput:(nonnull NSData*)preOutput
                                     proof:(nonnull NSData*)proof
                                     error:(NSError*_Nullable*_Nullable)error {
    if (preOutput.length != SNVrfPreOutputSize || proof.length != SNVrfProofSize) {
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
    if (data.length != SNVrfPreOutputSize + SNVrfProofSize) {
        if (error) {
            *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                         code:0
                                     userInfo:@{NSLocalizedDescriptionKey: @"Invalid VRF signature raw data size"}];
        }
        return nil;
    }

    if (self = [super init]) {
        self.preOutput = [data subdataWithRange:NSMakeRange(0, SNVrfPreOutputSize)];
        self.proof = [data subdataWithRange:NSMakeRange(SNVrfPreOutputSize, SNVrfProofSize)];
    }

    return self;
}

- (nonnull NSData*)rawData {
    NSMutableData *data = [NSMutableData dataWithCapacity:SNVrfPreOutputSize + SNVrfProofSize];
    [data appendData:self.preOutput];
    [data appendData:self.proof];
    return data;
}

@end
