//
//  SNVrfField.h
//  IrohaCrypto
//

#import <Foundation/Foundation.h>

@interface SNVrfField : NSObject

@property(nonatomic, readonly, nonnull) NSData *key;
@property(nonatomic, readonly, nonnull) NSData *value;

- (nonnull instancetype)initWithKey:(nonnull NSData*)key value:(nonnull NSData*)value;

+ (nonnull instancetype)fieldWithKey:(nonnull NSString*)key value:(nonnull NSData*)value;

@end
