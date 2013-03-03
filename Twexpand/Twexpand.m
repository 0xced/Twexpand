//
//  Twexpand.m
//  Twexpand
//
//  Created by Cédric Luthi on 01.03.13.
//  Copyright (c) 2013 Cédric Luthi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@interface Twexpand : NSObject
@end

@implementation Twexpand

static SEL expandedURLSelector;

+ (void) install
{
	BOOL installed = NO;
	NSRunningApplication *currentApplication = [NSRunningApplication currentApplication];
	NSString *bundleIdentifier = [currentApplication bundleIdentifier];
	
	for (NSDictionary *targetApplicationInfo in [[NSBundle bundleForClass:self] objectForInfoDictionaryKey:@"SIMBLTargetApplications"])
	{
		if ([targetApplicationInfo isKindOfClass:[NSDictionary class]] && [targetApplicationInfo[@"BundleIdentifier"] isEqual:bundleIdentifier])
		{
			NSDictionary *swizzleInfo = targetApplicationInfo[@"SwizzleInfo"];
			Class tweetEntityClass = NSClassFromString(swizzleInfo[@"TweetEntityClass"]);
			SEL displayURLSelector = NSSelectorFromString(swizzleInfo[@"DisplayURLSelector"]);
			expandedURLSelector = NSSelectorFromString(swizzleInfo[@"ExpandedURLSelector"]);
			Method m1 = class_getInstanceMethod(tweetEntityClass, displayURLSelector);
			Method m2 = class_getInstanceMethod([NSObject class], @selector(twexpand_displayExpandedURLString));
			installed = expandedURLSelector && m1 && m2 && strcmp(method_getTypeEncoding(m1), method_getTypeEncoding(m2)) == 0;
			if (installed)
				method_exchangeImplementations(m1, m2);
			
			break;
		}
	}
	
	if (installed)
		NSLog(@"Successfully installed %@ into %@", self, currentApplication.localizedName);
	else
		NSLog(@"Failed to install %@ into %@", self, currentApplication.localizedName);
}

@end

@implementation NSObject (Twexpand)

- (id) twexpand_displayExpandedURLString
{
	id displayURL = [self twexpand_displayExpandedURLString];
	id expandedURL = nil;
	if ([displayURL isKindOfClass:[NSString class]])
	{
		@try
		{
			expandedURL = [self performSelector:expandedURLSelector];
			if ([expandedURL isKindOfClass:[NSURL class]])
				expandedURL = [expandedURL absoluteString];
		}
		@catch (NSException *exception)
		{
			static dispatch_once_t onceToken;
			dispatch_once(&onceToken, ^{
				NSLog(@"%@", exception);
			});
		}
	}
	return [expandedURL isKindOfClass:[NSString class]] ? expandedURL : displayURL;
}

@end
