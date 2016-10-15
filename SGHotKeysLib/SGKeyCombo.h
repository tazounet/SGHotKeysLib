//
//  SGKeyCombo.h
//  SGHotKeyCenter
//
//  Created by Justin Williams on 7/26/09.
//  Copyright 2009 Second Gear. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SGKeyCombo : NSObject {
  NSInteger keyCode;
  NSInteger modifiers;
}

@property (nonatomic, assign) NSInteger keyCode;
@property (nonatomic, assign) NSInteger modifiers;

- (instancetype)init NS_UNAVAILABLE;

+ (id)clearKeyCombo;
+ (instancetype)keyComboWithKeyCode:(NSInteger)theKeyCode modifiers:(NSInteger)theModifiers;
- (instancetype)initWithKeyCode:(NSInteger)theKeyCode modifiers:(NSInteger)theModifiers NS_DESIGNATED_INITIALIZER;

- (id)plistRepresentation;
- (instancetype)initWithPlistRepresentation:(id)thePlist;

- (BOOL)isEqual:(SGKeyCombo *)theCombo;

- (BOOL)isClearCombo;
- (BOOL)isValidHotKeyCombo;

@end

@interface SGKeyCombo (UserDisplayAdditions)
- (NSString *)description;
- (NSString *)keyCodeString;
- (NSUInteger)modifierMask;
@end

