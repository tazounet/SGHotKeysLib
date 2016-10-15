//
//  SGKeyCombo.m
//  SGHotKeyCenter
//
//  Created by Justin Williams on 7/26/09.
//  Copyright 2009 Second Gear. All rights reserved.
//

#import <Carbon/Carbon.h>
#import "SGKeyCombo.h"
#import "SGKeyCodeTranslator.h"

NSString * const kKeyCodeDictionaryKey = @"keyCode";
NSString * const kModifiersDictionaryKey = @"modifiers";

@implementation SGKeyCombo

@synthesize keyCode;
@synthesize modifiers;

+ (id)clearKeyCombo {
  return [self keyComboWithKeyCode:-1 modifiers:-1];
}

+ (instancetype)keyComboWithKeyCode:(NSInteger)theKeyCode modifiers:(NSInteger)theModifiers {
  return [[self alloc] initWithKeyCode:theKeyCode modifiers:theModifiers];
}


- (instancetype)initWithKeyCode:(NSInteger)theKeyCode modifiers:(NSInteger)theModifiers {
  if (self = [super init]) {
    keyCode = theKeyCode;
    modifiers = theModifiers;
  }
  
  return self;
}

- (instancetype)initWithPlistRepresentation:(id)thePlist {
  NSInteger theKeyCode;
  NSInteger theModifiers;
  
  if (!thePlist || ![thePlist count]) {
    theKeyCode = -1;
    theModifiers = -1;
  } else {
    theKeyCode = [thePlist[kKeyCodeDictionaryKey] integerValue];
    if (theKeyCode < 0) theKeyCode = -1;
    
    theModifiers = [thePlist[kModifiersDictionaryKey] integerValue];
    if (theModifiers <= 0) theModifiers = -1;    
  }
  
  return [self initWithKeyCode:theKeyCode modifiers:theModifiers];
}


- (id)plistRepresentation {
  return @{kKeyCodeDictionaryKey: @(self.keyCode),
            kModifiersDictionaryKey: @(self.modifiers)};  
}

- (BOOL)isEqual:(SGKeyCombo *)theCombo {
  return self.keyCode == theCombo.keyCode && self.modifiers == theCombo.modifiers;

}

- (BOOL)isClearCombo {
  return keyCode == -1 && modifiers == -1;
}


- (BOOL)isValidHotKeyCombo {
  return keyCode >= 0 && modifiers > 0;
}

+ (NSString*)_stringForModifiers:(NSInteger)theModifiers {
	static unichar modToChar[4][2] =
	{
		{ cmdKey, 		kCommandUnicode },
		{ optionKey,	kOptionUnicode },
		{ controlKey,	kControlUnicode },
		{ shiftKey,		kShiftUnicode }
	};
  
	NSString *string = [NSString string];
	long i;
  
	for( i = 0; i < 4; i++ ) {
		if (theModifiers & modToChar[i][0] )
			string = [string stringByAppendingString: [NSString stringWithCharacters: &modToChar[i][1] length: 1]];
	}
  
	return string;
}

+ (NSDictionary *)_keyCodesDictionary {
	static NSDictionary *keyCodes = nil;
	
	if(keyCodes == nil) {
		NSString *path;
		NSString *contents;
    NSError *error;
		
		path = [[NSBundle bundleForClass:self] pathForResource:@"SGKeyCodes" ofType:@"plist"];
		contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    NSAssert(contents != nil, @"Contents of SGKeyCodes is nil");    
		keyCodes = [contents propertyList];
	}
	
	return keyCodes;
}

+ (NSString*)_stringForKeyCode: (short)theKeyCode legacyKeyCodeMap: (NSDictionary*)theDictionary {
	id key;
	NSString *string;
	
	key = [NSString stringWithFormat:@"%d", theKeyCode];
	string = theDictionary[key];
	
	if( !string )
		string = [NSString stringWithFormat:@"%X", theKeyCode];
	
	return string;
}

+ (NSString*)_stringForKeyCode:(short)theKeyCode newKeyCodeMap:(NSDictionary*)theDictionary {
	NSString *result;
	NSString *keyCodeString;
	NSDictionary *unmappedKeys;
	NSArray *padKeys;
	
	keyCodeString = [NSString stringWithFormat: @"%d", theKeyCode];
	
	//Handled if its not handled by translator
	unmappedKeys = theDictionary[@"unmappedKeys"];
	result = unmappedKeys[keyCodeString];
	if( result )
		return result;
	
	//Translate it
	result = [[SGKeyCodeTranslator currentTranslator] translateKeyCode:theKeyCode].uppercaseString;
	
	//Handle if its a key-pad key
	padKeys = theDictionary[@"padKeys"];  
	if([padKeys indexOfObject:keyCodeString] != NSNotFound) {
    result = [NSString stringWithFormat:@"%@ %@", theDictionary[@"padKeyString"], result];
	}
	
	return result;
}

+ (NSString *)_stringForKeyCode:(short)theKeyCode {
	NSDictionary *dict;
  
	dict = [self _keyCodesDictionary];
	if([dict[@"version"] integerValue] <= 0)
		return [self _stringForKeyCode:theKeyCode legacyKeyCodeMap:dict];
  
	return [self _stringForKeyCode:theKeyCode newKeyCodeMap:dict];
}

- (NSString*)keyCodeString {
	// special case: the modifiers for the "clear" key are 0x0
	if ( self.isClearCombo ) return @"";
	
  return [[self class] _stringForKeyCode:self.keyCode];
}

- (NSUInteger)modifierMask {
	// special case: the modifiers for the "clear" key are 0x0
	if (self.isClearCombo) return 0;
	
	static NSUInteger modToChar[4][2] =
	{
		{ cmdKey, 		NSEventModifierFlagCommand },
		{ optionKey,	NSEventModifierFlagOption },
		{ controlKey,	NSEventModifierFlagControl },
		{ shiftKey,		NSEventModifierFlagShift }
	};
  
  NSUInteger i, ret = 0;
  
  for (i = 0; i < 4; i++)  {
    if (self.modifiers & modToChar[i][0]) {
      ret |= modToChar[i][1];
    }
  }
  
  return ret;
}

- (NSString *)description {
	NSString *desc;
	
	if (self.isValidHotKeyCombo) {
		desc = [NSString stringWithFormat: @"%@%@",
            [[self class] _stringForModifiers:self.modifiers],
            [[self class] _stringForKeyCode:self.keyCode]];
	}
	else {
    desc = NSLocalizedString(@"(None)", @"Hot Keys: Key Combo text for 'empty' combo" );
	}
  
	return desc;
}
@end
