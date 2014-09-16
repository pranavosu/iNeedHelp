//
//  HelperViewController.h
//  Help
//
//  Created by Pranav Malewadkar on 4/11/14.
//  Copyright (c) 2014 Me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface HelperViewController : UIViewController<CLLocationManagerDelegate, MKMapViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblETA;

@property (weak, nonatomic) IBOutlet UILabel *lbNumPeople;
@property (nonatomic, copy) NSString *strLatitude;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, copy) NSString *strLongitude;
@property (nonatomic, copy) NSString *strDeviceId;
@end
