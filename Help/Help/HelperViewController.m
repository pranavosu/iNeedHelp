//
//  HelperViewController.m
//  Help
//
//  Created by Pranav Malewadkar on 4/11/14.
//  Copyright (c) 2014 Me. All rights reserved.
//

#import "HelperViewController.h"
#import "CustomAnnotation.h"

#define EVCOLOR [UIColor colorWithRed:247/255.0f green:102/255.0f blue:0/255.0f alpha:1.0f]

@interface HelperViewController ()

@end

@implementation HelperViewController
{
     CLLocation *currentLocation;
     CLLocationManager *locationManager;
     MKDirections *routeDirections;
     MKRoute *routeToDisplay;
     CustomAnnotation *patientAnnotation;
     int replyCount;
     NSTimer *timerReply;
     BOOL isAlerted;
    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    replyCount = 0;
    isAlerted = NO;
    [self.lbNumPeople setText:[NSString stringWithFormat:@"",replyCount]];
  //  NSLog(@"Lat: %@, Long: %@",self.strLatitude, self.strLongitude);
    [self startLocationChangeUpdates];
    
    [self startFetchingReplyCounts];
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - WS Call

-(void) handleError:(NSError*) error{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Help" message:error.localizedDescription delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
}
-(void) makeRequestWithCommand:(NSString*) cmd{
    
    NSString *deviceID = self.strDeviceId; //[[NSUserDefaults standardUserDefaults] objectForKey:@"device_id"];
    
    NSString* latitude = [NSString stringWithFormat:@"%.6f",currentLocation.coordinate.latitude];
    NSString* longitude = [NSString stringWithFormat:@"%.6f",currentLocation.coordinate.longitude];
    
    NSString *queryString = [NSString stringWithFormat:@"device_id=%@&latitude=%@&longitude=%@&cmd=%@", deviceID, latitude, longitude, cmd];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURL *url = [NSURL URLWithString:ServerApiURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPBody = [queryString dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 30;
    
    
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    
                    
                    
                    if(!error){
                        
                        NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                    
                        //Handle reply count result.
                        if([cmd isEqualToString:@"getreplycount"]){
                            
                            replyCount = string.intValue;
                            if(replyCount>0){
                        
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.lbNumPeople setText:[NSString stringWithFormat:@"%d people are on their way",replyCount]];
                                });
                            }
                            else{
                                
                                 [self.lbNumPeople setText:[NSString stringWithFormat:@""]];
                            }
                        }
                        
                    }
                    else{
                        //Network response error.
                        [self handleError:error];
                    }
                }] resume];
    
    
    
}


#pragma mark - Reply Count Fetch

-(void)fetchReplyCount:(NSTimer*) timer{
    
    
    [self makeRequestWithCommand:@"getreplycount"];
}

-(void)startFetchingReplyCounts{
     [self makeRequestWithCommand:@"getreplycount"];
    timerReply = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(fetchReplyCount:) userInfo:nil repeats:YES];
    
    
}

-(void)stopFetchingReplyCounts{
    
    [timerReply invalidate];
    timerReply = nil;
    
}

#pragma mark - Location Manager

/*Get events for new location whenever significant location change occurs.*/

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    CLLocation* location = [locations lastObject];
    
    currentLocation = location;
   
    [self showDirections];
    
}


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

#pragma mark - MapView Stuff

-(void) showDirections{
    
    
    //NSMutableArray *arrAnnotations = [NSMutableArray new];
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = self.strLatitude.doubleValue;
    coordinate.longitude = self.strLongitude.doubleValue;
    
    CustomAnnotation *annotation = [[CustomAnnotation alloc] initWithTitle:@"Patient" subtitle:@"Needs Help" coordinate:coordinate];
    
    patientAnnotation = annotation;
   // [arrAnnotations addObject:annotation];
    
      //[self.mapView showAnnotations:arrAnnotations animated:YES];
    
   // [self.mapView showAnnotations:[NSArray arrayWithObject:annotation] animated:YES];
    
    [self getDirectionsFor:annotation mapView:self.mapView];
    
}




- (void)getDirectionsFor:(CustomAnnotation *)evAnnotation mapView:(MKMapView *)mapView {
    
    MKDirectionsRequest *routeRequest = [[MKDirectionsRequest alloc] init];
    routeRequest.transportType = MKDirectionsTransportTypeAny;
    
    [routeRequest setSource:[MKMapItem mapItemForCurrentLocation]];
    [routeRequest setDestination :[evAnnotation mapItem]];
    
    //Cancel previous request.
    if(!routeDirections)
    {
        if(routeDirections.isCalculating){
            [routeDirections cancel];
        }
    }
    
    //No property for setting route request, so unfortunately have to init new object.
    routeDirections = nil;
    routeDirections = [[MKDirections alloc] initWithRequest:routeRequest];
    
    
    //iOS 7 maps way finding. Calculates route and returns in completion handler.
    [routeDirections calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * routeResponse, NSError *routeError) {
        if (routeError) {
            [self handleDirectionsError:routeError];
            
        } else {
            
            
            // The code doesn't request alternate routes, so add the single calculated route to
            // a previously declared MKRoute property called routeToDisplay.
            routeToDisplay = routeResponse.routes[0];
            
            [self.lblDistance setText:[NSString stringWithFormat:@"Distance: %.02f m",routeToDisplay.distance]];
            
            
            float travelTime = (routeToDisplay.expectedTravelTime<60?routeToDisplay.expectedTravelTime:routeToDisplay.expectedTravelTime/60);
            
            NSString* units =routeToDisplay.expectedTravelTime<60? @"secs":@"min";
            
            
            [self.lblETA setText:[NSString stringWithFormat:@"ETA: %0.2f %@",travelTime,units]];
            
            //Draw route on mapview.
            [self.mapView addOverlay:routeToDisplay.polyline level:MKOverlayLevelAboveRoads];
            
            [self.mapView showAnnotations:@[evAnnotation,mapView.userLocation] animated:YES];
            
            [mapView deselectAnnotation:evAnnotation animated:NO];
        }
    }];
}


-(void)viewDidDisappear:(BOOL)animated{
    
    [self dismissViewControllerAnimated:NO completion:^{}];
}


-(void) handleDirectionsError:(NSError*) error{
    
    if(!isAlerted){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Help" message:@"Sorry! Could not calculate route." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
        isAlerted = YES;
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
        routeRenderer.strokeColor = EVCOLOR;
        return routeRenderer;
    }
    else return nil;
}


- (IBAction)accept:(id)sender {
    
    
    
    [self stopFetchingReplyCounts];
    
    [self makeRequestWithCommand:@"updatereplycount"];
    
    
    // Set the directions mode to "Walking"
    // Can use MKLaunchOptionsDirectionsModeDriving instead
    NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking};
    // Get the "Current User Location" MKMapItem
    MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
    // Pass the current location and destination map items to the Maps app
    // Set the direction mode in the launchOptions dictionary
    [MKMapItem openMapsWithItems:@[currentLocationMapItem, [patientAnnotation mapItem] ]
                   launchOptions:launchOptions];
    
    
}

- (IBAction)no:(id)sender {
    
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"iNeedHelp" message:@"Are you sure you can't help?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alert.tag = 10;
    [alert show];
    
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
  
    if(alertView.tag ==10)
    {
        switch (buttonIndex) {
            case 0:
            {
                [self dismissViewControllerAnimated:YES completion:^{
                
                    [self stopFetchingReplyCounts];
                
                }];
            }
                break;
            case 1:
                break;
            default:
                break;
        }
    }
    isAlerted = NO;
}

@end
