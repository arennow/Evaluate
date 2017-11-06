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

static double eval_rand(void) {
	double const scale = 100000;
	return arc4random_uniform(scale)/(double)scale;
}

static double eval_fact(double input) {
	double rounded = floor(input);
	double outVal = rounded;
	
	while (rounded > 1 && !isinf(outVal)) {
		rounded -= 1;
		outVal *= rounded;
	}
	
	return outVal;
}

// I'm not sure why this is necessary. Perhaps MuParser needs a static function?
static double eval_round(double input) {
	return round(input);
}

@implementation MuParserWrapper {
	Parser _parser;
	double _lastValue;
}

-(instancetype)init {
	self = [super init];
	
	if (self) {
		_parser.DefineVar("P", &_lastValue);
		_parser.DefineFun("rand", &eval_rand);
		_parser.DefineFun("fact", &eval_fact);
		_parser.DefineFun("round", &eval_round);
	}
	
	return self;
}

-(BOOL)evaluateExpression:(NSString*)expression result:(double*)result error:(NSError* __autoreleasing * _Nullable)error {
	try {
		_parser.SetExpr(expression.UTF8String);
		*result = _lastValue = _parser.Eval();
		
		return YES;
	} catch (Parser::exception_type &e) {
		if (error) {
			NSString* errorMessage = [NSString stringWithCString:e.GetMsg().c_str() encoding:NSUTF8StringEncoding];
			NSError* outError = [NSError errorWithDomain:@"MuParser" code:-100 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
			
			*error = outError;
		}
		
		return NO;
	}
}

@end
