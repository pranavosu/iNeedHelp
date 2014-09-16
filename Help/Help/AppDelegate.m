//
//  AppDelegate.m
//  Help
//
//  Created by Pranav Malewadkar on 4/11/14.
//  Copyright (c) 2014 Me. All rights reserved.
//

#import "AppDelegate.h"
#import "HelperViewController.h"
#import "HelpeeViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
   
    HelpeeViewController * helpeeVC =(HelpeeViewController*) self.window.rootViewController;
    self.delegate = helpeeVC;
    
    NSDictionary *notificationDetails =
    [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notificationDetails) {
        
      //  NSLog(@"LocalNotifications:%@",localNotif);
        NSString *coords = [notificationDetails valueForKeyPath:@"aps.alert.payload"];
       // NSLog(@"Coords:%@",coords);
        
        NSArray *arrLatLong = [coords componentsSeparatedByString:@","];
        
        if(arrLatLong.count < 3){
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Help" message:@"Wrong Lat Long" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alert show];
            
        }
        else{
            
            
             [self.delegate didReceiveEmergencyFromLocation:arrLatLong[0] :arrLatLong[1] fromDevice: arrLatLong[2]];
            
            
        }
    }
   
    
    
    
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	
    NSString *device_id = [[NSString stringWithFormat:@"%@",deviceToken]mutableCopy];
    device_id = [device_id stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
   
    NSMutableString *str = [device_id mutableCopy];
    
    [str replaceOccurrencesOfString:@" "withString:@"" options:0 range:NSMakeRange(0, [str length]) ];
    
    [[NSUserDefaults standardUserDefaults] setObject:[str copy] forKey:@"device_id"];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    
    
    NSString *coords = [userInfo valueForKeyPath:@"aps.alert.payload"];
   // NSLog(@"Coords:%@",coords);
    
    NSArray *arrLatLong = [coords componentsSeparatedByString:@","];
    
    if(arrLatLong.count < 2){
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Help" message:@"Wrong Lat Long" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert show];
        
    }
    else{
        
        //NSLog(@"Lat: %@, Long: %@",arrLatLong[0],arrLatLong[1]);
        
        [self.delegate didReceiveEmergencyFromLocation:arrLatLong[0] :arrLatLong[1] fromDevice: arrLatLong[2]];
        
        
        
    }


}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSLog(@"Background Mode:iNeedHelp");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
