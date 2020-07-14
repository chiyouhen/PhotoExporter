//
//  BDGeoCoder.m
//  PhotoExporter
//
//  Created by henkzhang(张珩) on 2020/7/14.
//  Copyright © 2020 chiyouhen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Contacts/Contacts.h>
#import <Intents/Intents.h>
#import "BDGeoCoder.h"
#import "Secret.h"

@implementation BDGeoCoder

- (void) reverseGeocodeLocation: (CLLocation*) location completionHandler: (void(^)(CNPostalAddress* postalAddress, NSError* error)) completionHandler {
    CLLocationCoordinate2D coordinate = [location coordinate];
    NSURL* url = [NSURL URLWithString:
                  [NSString stringWithFormat: @"https://api.map.baidu.com/reverse_geocoding/v3/?ak=%@&output=json&coordtype=wgs84ll&location=%f,%f", BD_MAP_AK, coordinate.latitude, coordinate.longitude]];
    NSMutableURLRequest* r = [NSMutableURLRequest requestWithURL: url];
    [r setValue: BD_MAP_REFERER_HOST forHTTPHeaderField: @"Referer"];
    [r setTimeoutInterval: 1.0];
    
    NSURLSession* s = [NSURLSession sharedSession];
    NSLog(@"session: %@", s);
    NSURLSessionDataTask* t = [s dataTaskWithRequest: r
         completionHandler: ^(NSData* data, NSURLResponse* res, NSError* error) {
        if (error != nil) {
            NSLog(@"dataTaskWithRequest error: %@", error);
            completionHandler(nil, error);
            return;
        }
        NSError* e;
        id obj = [NSJSONSerialization JSONObjectWithData: data
                                                 options: nil
                                                   error: &e];
        if (e != nil) {
            NSLog(@"JSONObjectWithData error: %@", e);
            completionHandler(nil, e);
            return;
        }
        NSDictionary* geoData = (NSDictionary*) obj;
        //NSLog(@"geoData: %@", geoData);
        NSDictionary* addressComponent = geoData[@"result"][@"addressComponent"];
        NSLog(@"address: %@", addressComponent);
        CNMutablePostalAddress* postalAddress = [[CNMutablePostalAddress alloc] init];
        [postalAddress setCountry: addressComponent[@"country"]];
        [postalAddress setState: addressComponent[@"province"]];
        [postalAddress setCity: addressComponent[@"city"]];
        [postalAddress setSubLocality: addressComponent[@"district"]];
        [postalAddress setStreet: addressComponent[@"street"]];
        [postalAddress setISOCountryCode: addressComponent[@"country_code_iso"]];
        [postalAddress setSubAdministrativeArea: addressComponent[@"province"]];
        NSLog(@"postalAddress: %@", postalAddress);
        completionHandler(postalAddress, nil);
        /*
        
        CLPlacemark* placemark = [CLPlacemark placemarkWithLocation: location
                                                               name: addressComponent[@"street"]
                                                      postalAddress: postalAddress];
        NSLog(@"placemark: %@", placemark);
        NSArray<CLPlacemark*>* placemarks = [NSArray arrayWithObjects: placemark, nil];
        completionHandler(placemarks, nil);
         */
    }];
    [t resume];

}

@end
