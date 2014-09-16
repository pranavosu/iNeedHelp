//
//  AppDelegate.h
//  Help
//
//  Created by Pranav Malewadkar on 4/11/14.
//  Copyright (c) 2014 Me. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol EmergencyNotificationDelegate <NSObject>

-(void) didReceiveEmergencyFromLocation:(NSString*) latitude :(NSString*) longitude fromDevice:(NSString*)device_id;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) id<EmergencyNotificationDelegate> delegate;



@end
