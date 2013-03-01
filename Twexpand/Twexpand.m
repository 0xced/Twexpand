//
//  Twexpand.m
//  Twexpand
//
//  Created by Cédric Luthi on 01.03.13.
//  Copyright (c) 2013 Cédric Luthi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>

@interface Twexpand : NSObject
@end

@implementation Twexpand

static BOOL TwexpandSwizzle(NSString *className, SEL selector)
{
	SEL twexpandSelector = NSSelectorFromString([@"twexpand_" stringByAppendingString:NSStringFromSelector(selector)]);
	Method m1 = class_getInstanceMethod(NSClassFromString(className), selector);
	Method m2 = class_getInstanceMethod([NSObject class], twexpandSelector);
	BOOL swizzled = m1 && m2 && strcmp(method_getTypeEncoding(m1), method_getTypeEncoding(m2)) == 0;
	if (swizzled)
		method_exchangeImplementations(m1, m2);
	
	return swizzled;
}

+ (void) install
{
	BOOL installed = NO;
	NSRunningApplication *currentApplication = [NSRunningApplication currentApplication];
	NSString *bundleIdentifier = [currentApplication bundleIdentifier];
	
	if ([bundleIdentifier isEqualToString:@"com.YoruFukurouProject.YoruFukurou"])
	{
		installed = TwexpandSwizzle(@"TCURLEntity", @selector(displayURL));
	}
	
	if (installed)
		NSLog(@"Successfully installed %@ into %@", self, currentApplication.localizedName);
	else
		NSLog(@"Failed to install %@ into %@", self, currentApplication.localizedName);
}

@end

@implementation NSObject (TCURLEntity)

- (id) twexpand_displayURL
{
	NSString *displayURLString = [self twexpand_displayURL];
	NSString *expandedURLString = nil;
	if ([displayURLString isKindOfClass:[NSString class]])
	{
		@try
		{
			expandedURLString = [[self performSelector:@selector(URL)] absoluteString];
		}
		@catch (NSException *exception)
		{
			static dispatch_once_t onceToken;
			dispatch_once(&onceToken, ^{
				NSLog(@"%@", exception);
			});
		}
	}
	return expandedURLString ?: displayURLString;
}

@end
