//
//  SNVrfVerifier.m
//  IrohaCrypto
//

#import "SNVrfVerifier.h"
#import "sr25519.h"

@implementation SNVrfVerifier

- (BOOL)verify:(nonnull SNVrfSignature*)signature
     publicKey:(nonnull SNPublicKey*)publicKey
         label:(nonnull NSData*)label
        fields:(nonnull NSArray<SNVrfField*>*)fields {
    NSUInteger count = fields.count;
    VrfTranscriptField *cFields = NULL;

    if (count > 0) {
        cFields = calloc(count, sizeof(VrfTranscriptField));
        if (!cFields) {
            return NO;
        }

        for (NSUInteger i = 0; i < count; i++) {
            SNVrfField *field = fields[i];
            cFields[i].key = field.key.bytes;
            cFields[i].key_length = field.key.length;
            cFields[i].value = field.value.bytes;
            cFields[i].value_length = field.value.length;
        }
    }

    Sr25519Result result = sr25519_generic_vrf_verify(
        publicKey.rawData.bytes,
        label.bytes,
        label.length,
        cFields,
        count,
        signature.preOutput.bytes,
        signature.proof.bytes
    );

    free(cFields);

    return result == Ok;
}

@end
