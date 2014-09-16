//
//  EFEventAnnotation.h
//  EventFind
//
//  Created by Pranav Malewadkar on 3/13/14.
//  Copyright (c) 2014 Me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CustomAnnotation : NSObject<MKAnnotation>

@property(nonatomic, copy) NSString* url;

-(id)initWithTitle:(NSString*) title subtitle:(NSString*) venue coordinate:(CLLocationCoordinate2D) location;

-(MKMapItem*) mapItem;

@end
