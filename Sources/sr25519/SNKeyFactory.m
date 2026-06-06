//
//  SNKeypairFactory.m
//  IrohaCrypto
//
//  Created by Ruslan Rezin on 23.06.2020.
//

#import "SNKeyFactory.h"
#import "sr25519.h"

// MARK: - Canonical scalar validation (schnorrkel 0.9.1 from_bytes)
// Curve25519 group order L = 2^252 + 27742317777372353535851937790883648493, LE.
static const uint8_t SNRistrettoGroupOrder[32] = {
    0xed, 0xd3, 0xf5, 0x5c, 0x1a, 0x63, 0x12, 0x58,
    0xd6, 0x9c, 0xf7, 0xa2, 0xde, 0xf9, 0xde, 0x14,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10
};

// Returns YES iff s (LE, 32 bytes) is strictly less than L.
static BOOL SNIsCanonicalScalar(const uint8_t s[32]) {
    for (int i = 31; i >= 0; i--) {
        if (s[i] < SNRistrettoGroupOrder[i]) return YES;
        if (s[i] > SNRistrettoGroupOrder[i]) return NO;
    }
    return NO; // s == L rejected
}

static BOOL SNIsValidCanonicalScalar(const uint8_t s[32]) {
    BOOL nonZero = NO;
    for (int i = 0; i < 32; i++) if (s[i]) { nonZero = YES; break; }
    return nonZero && SNIsCanonicalScalar(s);
}

@implementation SNKeyFactory

- (id<SNKeypairProtocol> _Nullable)createKeypairFromSeed:(nonnull NSData*)seed
                                                   error:(NSError*_Nullable*_Nullable)error {
    if ([seed length] != SR25519_SEED_SIZE) {
        if (error) {
            NSString *message = [NSString stringWithFormat:@"Invalid seed length %@ but expected %@",
                                 @([seed length]), @(SR25519_SEED_SIZE)];
            *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                         code:SNKeyFactoryErrorInvalidSeed
                                     userInfo:@{NSLocalizedDescriptionKey: message}];
        }

        return nil;
    }

    uint8_t keypair[SR25519_KEYPAIR_SIZE];
    
    sr25519_keypair_from_seed(keypair, seed.bytes);

    NSData *keypairData = [NSData dataWithBytes:keypair length:SR25519_KEYPAIR_SIZE];

    return [[SNKeypair alloc] initWithRawData:keypairData error:error];
}

- (id<SNKeypairProtocol> _Nullable)createKeypairHard:(nonnull SNKeypair*)parent
                                           chaincode:(nonnull NSData*)chaincode
                                               error:(NSError*_Nullable*_Nullable)error {
    if ([chaincode length] != SR25519_CHAINCODE_SIZE) {
        if (error) {
            *error = [[self class] createChainCodeError:[chaincode length]];
        }

        return nil;
    }

    uint8_t keypair[SR25519_KEYPAIR_SIZE];

    sr25519_derive_keypair_hard(keypair, parent.rawData.bytes, chaincode.bytes);

    NSData *keypairData = [NSData dataWithBytes:keypair length:SR25519_KEYPAIR_SIZE];

    return [[SNKeypair alloc] initWithRawData:keypairData error:error];
}

- (id<SNKeypairProtocol> _Nullable)createKeypairSoft:(nonnull SNKeypair*)parent
                                           chaincode:(nonnull NSData*)chaincode
                                               error:(NSError*_Nullable*_Nullable)error {
    if ([chaincode length] != SR25519_CHAINCODE_SIZE) {
        if (error) {
            *error = [[self class] createChainCodeError:[chaincode length]];
        }

        return nil;
    }

    uint8_t keypair[SR25519_KEYPAIR_SIZE];

    sr25519_derive_keypair_soft(keypair, parent.rawData.bytes, chaincode.bytes);

    NSData *keypairData = [NSData dataWithBytes:keypair length:SR25519_KEYPAIR_SIZE];

    return [[SNKeypair alloc] initWithRawData:keypairData error:error];
}

- (nullable SNPublicKey*)createPublicKeySoft:(nonnull SNPublicKey*)parentPublicKey
                                   chaincode:(nonnull NSData*)chaincode
                                       error:(NSError*_Nullable*_Nullable)error {
    if ([chaincode length] != SR25519_CHAINCODE_SIZE) {
        if (error) {
            *error = [[self class] createChainCodeError:[chaincode length]];
        }

        return nil;
    }

    uint8_t publicKeyBytes[SR25519_PUBLIC_SIZE];

    sr25519_derive_public_soft(publicKeyBytes, parentPublicKey.rawData.bytes, chaincode.bytes);

    NSData *publicKeyData = [NSData dataWithBytes:publicKeyBytes length:SR25519_PUBLIC_SIZE];

    return [[SNPublicKey alloc] initWithRawData:publicKeyData error:error];
}

- (nullable SNPublicKey*)createPublicKeyFromSecret:(nonnull NSData*)secret
                                             error:(NSError*_Nullable*_Nullable)error {
    if (secret.length != SR25519_SECRET_SIZE) {
        if (error) {
            NSString *message = [NSString stringWithFormat:@"Invalid secret length %@ but expected %@",
                                 @(secret.length), @(SR25519_SECRET_SIZE)];
            *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                         code:SNKeyFactoryErrorInvalidSecret
                                     userInfo:@{NSLocalizedDescriptionKey : message}];
        }
        return nil;
    }
    // Mirror schnorrkel 0.9.1 SecretKey::from_bytes Scalar::from_canonical_bytes:
    //   1. high bit of scalar must be clear
    //   2. scalar must be < L (canonical)
    // Failing either causes Rust panic in create_secret
    const uint8_t *s = secret.bytes;
    if ((s[31] & 0x80) != 0 || !SNIsValidCanonicalScalar(s)) {
        if (error) {
            *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                         code:SNKeyFactoryErrorInvalidSecret
                                     userInfo:@{NSLocalizedDescriptionKey: @"sr25519 secret scalar is not canonical (>= group order)"}];
        }
        return nil;
    }
    
    uint8_t publicKeyBytes[SR25519_PUBLIC_SIZE];
    
    sr25519_secret_to_public_key(publicKeyBytes, secret.bytes);
    
    NSData *publicKeyData = [NSData dataWithBytes:publicKeyBytes length:SR25519_PUBLIC_SIZE];
    
    return [[SNPublicKey alloc] initWithRawData:publicKeyData error:error];
}

+ (nonnull NSError*)createChainCodeError:(NSUInteger)actualSize {
    NSString *message = [NSString stringWithFormat:@"Invalid chaincode length %@ but expected %@",
                         @(actualSize), @(SR25519_CHAINCODE_SIZE)];
    return [NSError errorWithDomain:NSStringFromClass([self class])
                               code:SNKeyFactoryErrorInvalidChaincode
                           userInfo:@{NSLocalizedDescriptionKey: message}];
}

@end
