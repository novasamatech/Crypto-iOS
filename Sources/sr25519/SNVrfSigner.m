//
//  SNVrfSigner.m
//  IrohaCrypto
//

#import "SNVrfSigner.h"
#import "sr25519.h"

@interface SNVrfSigner()

@property(strong, nonatomic) _Nonnull id<SNKeypairProtocol> keypair;

@end

@implementation SNVrfSigner

- (nonnull instancetype)initWithKeypair:(id<SNKeypairProtocol> _Nonnull)keypair {
    if (self = [super init]) {
        self.keypair = keypair;
    }
    return self;
}

- (nullable SNVrfSignature*)signWithLabel:(nonnull NSData*)label
                                   fields:(nonnull NSArray<SNVrfField*>*)fields
                                    error:(NSError*_Nullable*_Nullable)error {
    NSUInteger count = fields.count;
    VrfTranscriptField *cFields = NULL;

    if (count > 0) {
        cFields = calloc(count, sizeof(VrfTranscriptField));
        if (!cFields) {
            if (error) {
                *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:SNVrfSignerErrorSigningFailed
                                         userInfo:@{NSLocalizedDescriptionKey: @"Memory allocation failed"}];
            }
            return nil;
        }

        for (NSUInteger i = 0; i < count; i++) {
            SNVrfField *field = fields[i];
            cFields[i].key = field.key.bytes;
            cFields[i].key_length = field.key.length;
            cFields[i].value = field.value.bytes;
            cFields[i].value_length = field.value.length;
        }
    }

    uint8_t out[SR25519_VRF_OUTPUT_SIZE + SR25519_VRF_PROOF_SIZE];

    Sr25519Result result = sr25519_generic_vrf_sign(
        out,
        _keypair.rawData.bytes,
        label.bytes,
        label.length,
        cFields,
        count
    );

    free(cFields);

    if (result != Ok) {
        if (error) {
            *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                         code:SNVrfSignerErrorSigningFailed
                                     userInfo:@{NSLocalizedDescriptionKey: @"sr25519 VRF signing failed"}];
        }
        return nil;
    }

    NSData *rawData = [NSData dataWithBytes:out length:sizeof(out)];
    return [[SNVrfSignature alloc] initWithRawData:rawData error:error];
}

@end
