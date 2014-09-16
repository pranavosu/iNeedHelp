//
//  EFEventAnnotation.m
//  EventFind
//
//  Created by Pranav Malewadkar on 3/13/14.
//  Copyright (c) 2014 Me. All rights reserved.
//
/*
 
 Custom map annotation
 
 */
#import "CustomAnnotation.h"
#import <AddressBook/AddressBook.h>

@interface CustomAnnotation ()

@property(nonatomic, copy) NSString* title;
@property(nonatomic, copy) NSString* venue;

@property(nonatomic, assign) CLLocationCoordinate2D location;

@end

@implementation CustomAnnotation

-(id)initWithTitle:(NSString *)title subtitle:(NSString *)venue
        coordinate:(CLLocationCoordinate2D)location{
    
    if(self = [super init]){
        
        self.title = title;
        self.venue = venue;
        self.location = location;
      
    }
    
    return  self;
    
}

-(NSString *)title{
    
    return _title;
}

-(NSString *)subtitle{
    
    return _venue;
}

-(CLLocationCoordinate2D)coordinate{
    
    return _location;
}

-(MKMapItem *)mapItem{
    
   // NSDictionary *addressDict = @{(NSString*)kABPersonAddressStreetKey : _venue};
    
    MKPlacemark *placemark = [[MKPlacemark alloc]
                              initWithCoordinate:self.coordinate
                              addressDictionary:nil];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.title;
    
    return mapItem;
}
@end
