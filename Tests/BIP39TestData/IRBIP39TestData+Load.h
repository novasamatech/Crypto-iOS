//
//  IRBIP39TestData+Load.h
//  IrohaCryptoTests
//
//  Created by Ruslan Rezin on 27.02.2020.
//  Copyright © 2020 Ruslan Rezin. All rights reserved.
//

#import "IRBIP39TestData.h"

typedef NS_ENUM(NSUInteger, IRIRBIP39DataLoadingError) {
    IRIRBIP39DataLoadingFormat,
    IRIRBIP39DataLoadingInvalidFilename
};

@interface IRBIP39TestData (Load)

+ (nonnull NSArray<IRBIP39TestData*>*)loadFromBundle: (nonnull NSBundle*)bundle
                                            filename:(nonnull NSString*)filename
                                            language:(nonnull NSString*)language
                                               error:(NSError*_Nullable*_Nullable)error;

@end
