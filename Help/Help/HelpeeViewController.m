//
//  ViewController.m
//  Help
//
//  Created by Pranav Malewadkar on 4/11/14.
//  Copyright (c) 2014 Me. All rights reserved.
//

#import "HelpeeViewController.h"
#import "HelperViewController.h"

@interface HelpeeViewController ()

@end

@implementation HelpeeViewController
{
    CLLocation *currentLocation;
    CLLocationManager *locationManager;
    CLLocation *patientLocation;
    BOOL isHandlingEmergency;
    NSString * emergencyLatitude;
    NSString * emergencyLongitude;
    BOOL isAlerted;

}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    isAlerted = NO;
    [self startLocationChangeUpdates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    
    if(isHandlingEmergency){
        
        isHandlingEmergency = NO;
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        HelperViewController *controller =(HelperViewController*) [mainStoryboard instantiateViewControllerWithIdentifier: @"mapView"];
        [controller setStrLatitude:emergencyLatitude];
        [controller setStrLongitude:emergencyLongitude];
        [self presentViewController: controller animated:YES completion:nil];
        
    }
}






-(void) handleError:(NSError*) error{
    
//    if(!isAlerted){
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Help" message:error.localizedDescription delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
//        [alert show];
//    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    CLLocation* location = [locations lastObject];
    
    currentLocation = location;
    
    //<+39.99758994,-83.04203852>
    [self makeRequestWithCommand:@"update"];
    
}


-(void) makeRequestWithCommand:(NSString*) cmd{
    
    NSString *deviceID = [[NSUserDefaults standardUserDefaults] objectForKey:@"device_id"];
    
    NSString* latitude = [NSString stringWithFormat:@"%.6f",currentLocation.coordinate.latitude];
    NSString* longitude = [NSString stringWithFormat:@"%.6f",currentLocation.coordinate.longitude];
    
    NSString *queryString = [NSString stringWithFormat:@"device_id=%@&latitude=%@&longitude=%@&cmd=%@", deviceID, latitude, longitude, cmd];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    //    sessionConfiguration.HTTPAdditionalHeaders = @{
    //                                                   @"api-key"       : @"API_KEY"
    //                                                   };
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURL *url = [NSURL URLWithString:ServerApiURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPBody = [queryString dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    
    //TODO: If the request times out. Make it again.
    request.timeoutInterval = 30;
    
    
    [[session dataTaskWithRequest:request
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                
                
                
                if(error){              //Network response error.
                    [self handleError:error];
                }
            }] resume];

    
    
}



#pragma mark - Location Updates

- (void)startLocationChangeUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    
    //Monitor only significant changes for power saving. Don't need accurate location.
    [locationManager startUpdatingLocation];
}

#pragma mark - EmergencyNotifyDelegate

-(void)didReceiveEmergencyFromLocation:(NSString *)latitude :(NSString *)longitude fromDevice:(NSString *)device_id{
    
    
    
    emergencyLatitude = latitude;
    emergencyLongitude = longitude;
    
    isHandlingEmergency = YES;
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    HelperViewController *controller =(HelperViewController*) [mainStoryboard instantiateViewControllerWithIdentifier: @"mapView"];
    [controller setStrLatitude:latitude];
    [controller setStrLongitude:longitude];
    [controller setStrDeviceId:device_id];
    [self presentViewController: controller animated:YES completion:nil];
    
    
}

- (IBAction)help:(id)sender {
    
    
    [self makeRequestWithCommand:@"help"];
    
    
    //Open phone number
    NSString *phoneNumber = [@"tel://" stringByAppendingString:@"614-441-6118"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    
    
}

#pragma mark - UIAlertView Delegates
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    isAlerted = NO;
    
}

@end
