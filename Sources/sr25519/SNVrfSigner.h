//
//  SNVrfSigner.h
//  IrohaCrypto
//

#import <Foundation/Foundation.h>
#import "SNKeypair.h"
#import "SNVrfSignature.h"
#import "SNVrfField.h"

typedef NS_ENUM(NSUInteger, SNVrfSignerError) {
    SNVrfSignerErrorSigningFailed
};

@interface SNVrfSigner : NSObject

- (nonnull instancetype)initWithKeypair:(id<SNKeypairProtocol> _Nonnull)keypair;

/// Sign a VRF transcript with the given label and key-value fields.
- (nullable SNVrfSignature*)signWithLabel:(nonnull NSData*)label
                                   fields:(nonnull NSArray<SNVrfField*>*)fields
                                    error:(NSError*_Nullable*_Nullable)error;

@end
