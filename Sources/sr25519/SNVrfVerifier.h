//
//  SNVrfVerifier.h
//  IrohaCrypto
//

#import <Foundation/Foundation.h>
#import "SNPublicKey.h"
#import "SNVrfSignature.h"
#import "SNVrfField.h"

@interface SNVrfVerifier : NSObject

/// Verify a VRF signature against a public key, label, and key-value fields.
- (BOOL)verify:(nonnull SNVrfSignature*)signature
     publicKey:(nonnull SNPublicKey*)publicKey
         label:(nonnull NSData*)label
        fields:(nonnull NSArray<SNVrfField*>*)fields;

@end
