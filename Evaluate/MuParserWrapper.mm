//
//  MuParserWrapper.m
//  Evaluate
//
//  Created by Aaron Lynch on 2015-03-18.
//  Copyright (c) 2015 Lithiumcube. All rights reserved.
//

#import "MuParserWrapper.h"
#import "muParser.h"

using namespace mu;

@implementation MuParserWrapper {
	Parser _parser;
	double _lastValue;
}

-(instancetype)init {
	self = [super init];
	
	if (self) {
		_parser.DefineVar("Prev", &_lastValue);
	}
	
	return self;
}

-(BOOL)evaluate:(NSString*)expression result:(double*)result errorMessage:(NSString* __autoreleasing*)errorMessage {
	try {
		_parser.SetExpr(expression.UTF8String);
		*result = _lastValue = _parser.Eval();
		
		return YES;
	} catch (Parser::exception_type &e) {
		*errorMessage = [NSString stringWithCString:e.GetMsg().c_str() encoding:NSUTF8StringEncoding];
		
		return NO;
	}
}

@end
