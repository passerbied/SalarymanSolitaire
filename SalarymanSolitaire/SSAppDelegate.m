//
//  SSAppDelegate.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSAppDelegate.h"
#import "TopViewController.h"
#import <iAd/iAd.h>
#import "SSChallengeController.h"
#import <Crashlytics/Crashlytics.h>

@interface SSAppDelegate ()
{
}


@end

@implementation SSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    TopViewController *controller = [TopViewController controller];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    self.window.rootViewController = navigation;
    [self.window makeKeyAndVisible];
    
    [Crashlytics startWithAPIKey:@"228b4d6fcd0f59614dbcc0bc20910913f81c6e0c"];
    
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SolitaireWillPauseGameNotification
                                                        object:self];

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now = [dat timeIntervalSince1970]*1;
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%f",(double)now]
                                             forKey:kGameInfoPowerLastUsingTime];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo WU of the changes made on entering the background.
    [[NSNotificationCenter defaultCenter] postNotificationName:SolitaireWillResumeGameNotification
                                                        object:self];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{

}

@end
