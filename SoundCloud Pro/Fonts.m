//
//  Fonts.m
//  SoundCloud Pro
//
//  Created by Austin Feight on 8/16/15.
//  Copyright © 2015 Lost in Flight. All rights reserved.
//

#import "Fonts.h"

#import <objc/runtime.h>

// TODO: make it work for bold, italic
NSString *const FOFontName = @"Avenir-Medium";

#pragma mark - UIFont category
@implementation UIFont (CustomFonts)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

+ (void)replaceClassSelector:(SEL)originalSelector withSelector:(SEL)modifiedSelector
{
  Method originalMethod = class_getClassMethod(self, originalSelector);
  Method modifiedMethod = class_getClassMethod(self, modifiedSelector);
  method_exchangeImplementations(originalMethod, modifiedMethod);
}

+ (void)replaceInstanceSelector:(SEL)originalSelector withSelector:(SEL)modifiedSelector
{
  Method originalDecoderMethod = class_getInstanceMethod(self, originalSelector);
  Method modifiedDecoderMethod = class_getInstanceMethod(self, modifiedSelector);
  method_exchangeImplementations(originalDecoderMethod, modifiedDecoderMethod);
}

+ (UIFont *)regularFontWithSize:(CGFloat)size
{
  return [UIFont fontWithName:FOFontName size:size];
}

+ (UIFont *)boldFontWithSize:(CGFloat)size
{
  return [UIFont fontWithName:FOFontName size:size];
}

+ (UIFont *)italicFontOfSize:(CGFloat)fontSize
{
  return [UIFont fontWithName:FOFontName size:fontSize];
}

- (id)initCustomWithCoder:(NSCoder *)aDecoder {
  BOOL result = [aDecoder containsValueForKey:@"UIFontDescriptor"];
  
  if (result) {
    UIFontDescriptor *descriptor = [aDecoder decodeObjectForKey:@"UIFontDescriptor"];
    
    NSString *fontName;
    if ([descriptor.fontAttributes[@"NSCTFontUIUsageAttribute"] isEqualToString:@"CTFontRegularUsage"]) {
      fontName = FOFontName;
    }
    else if ([descriptor.fontAttributes[@"NSCTFontUIUsageAttribute"] isEqualToString:@"CTFontEmphasizedUsage"]) {
      fontName = FOFontName;
    }
    else if ([descriptor.fontAttributes[@"NSCTFontUIUsageAttribute"] isEqualToString:@"CTFontObliqueUsage"]) {
      fontName = FOFontName;
    }
    else {
      fontName = descriptor.fontAttributes[@"NSFontNameAttribute"];
    }
    
    return [UIFont fontWithName:fontName size:descriptor.pointSize];
  }
  
  self = [self initCustomWithCoder:aDecoder];
  
  return self;
}

+ (void)load
{
  [self replaceClassSelector:@selector(systemFontOfSize:) withSelector:@selector(regularFontWithSize:)];
  [self replaceClassSelector:@selector(boldSystemFontOfSize:) withSelector:@selector(boldFontWithSize:)];
  [self replaceClassSelector:@selector(italicSystemFontOfSize:) withSelector:@selector(italicFontOfSize:)];
  
  [self replaceInstanceSelector:@selector(initWithCoder:) withSelector:@selector(initCustomWithCoder:)];
}

#pragma clang diagnostic pop

@end