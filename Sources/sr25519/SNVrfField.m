//
//  SNVrfField.m
//  IrohaCrypto
//

#import "SNVrfField.h"

@interface SNVrfField()

@property(copy, nonatomic) NSData *key;
@property(copy, nonatomic) NSData *value;

@end

@implementation SNVrfField

- (nonnull instancetype)initWithKey:(nonnull NSData*)key value:(nonnull NSData*)value {
    if (self = [super init]) {
        self.key = key;
        self.value = value;
    }
    return self;
}

+ (nonnull instancetype)fieldWithKey:(nonnull NSString*)key value:(nonnull NSData*)value {
    return [[self alloc] initWithKey:[key dataUsingEncoding:NSUTF8StringEncoding] value:value];
}

@end
