//
//  SNVrfSignature.h
//  IrohaCrypto
//

#import <Foundation/Foundation.h>

@interface SNVrfSignature : NSObject

@property(nonatomic, readonly, nonnull) NSData *preOutput;
@property(nonatomic, readonly, nonnull) NSData *proof;

- (nullable instancetype)initWithPreOutput:(nonnull NSData*)preOutput
                                     proof:(nonnull NSData*)proof
                                     error:(NSError*_Nullable*_Nullable)error;

- (nullable instancetype)initWithRawData:(nonnull NSData*)data
                                   error:(NSError*_Nullable*_Nullable)error;

- (nonnull NSData*)rawData;

@end
