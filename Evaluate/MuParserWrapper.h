//
//  MuParserWrapper.h
//  Evaluate
//
//  Created by Aaron Lynch on 2015-03-18.
//  Copyright (c) 2015 Lithiumcube. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MuParserWrapper : NSObject

-(BOOL)evaluate:(NSString*)expression result:(double*)result errorMessage:(NSString* __autoreleasing*)errorMessage;

@end