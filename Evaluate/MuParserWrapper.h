//
//  MuParserWrapper.h
//  Evaluate
//
//  Created by Aaron Lynch on 2015-03-18.
//  Copyright (c) 2015 Lithiumcube. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MuParserWrapper : NSObject

-(BOOL)evaluateExpression:(NSString*)expression result:(double*)result error:(NSError* __autoreleasing * _Nullable)error NS_SWIFT_NAME(evaluate(_:result:));

@end

NS_ASSUME_NONNULL_END
