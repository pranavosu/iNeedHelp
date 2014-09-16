//
//  ViewController.h
//  Help
//
//  Created by Pranav Malewadkar on 4/11/14.
//  Copyright (c) 2014 Me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
@interface HelpeeViewController : UIViewController<CLLocationManagerDelegate, EmergencyNotificationDelegate,UIAlertViewDelegate>

@end
