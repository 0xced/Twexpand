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

+ (void) install
{
	BOOL installed = NO;
	NSRunningApplication *currentApplication = [NSRunningApplication currentApplication];
	NSString *bundleIdentifier = [currentApplication bundleIdentifier];
	
	if ([bundleIdentifier isEqualToString:@"com.YoruFukurouProject.YoruFukurou"])
	{
		Class TCURLEntity = objc_getClass("TCURLEntity");
		Method m1 = class_getInstanceMethod(TCURLEntity, @selector(displayURL));
		Method m2 = class_getInstanceMethod([NSObject class], @selector(twexpand_displayURL));
		installed = m1 && m2 && strcmp(method_getTypeEncoding(m1), method_getTypeEncoding(m2)) == 0;
		if (installed)
			method_exchangeImplementations(m1, m2);
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
