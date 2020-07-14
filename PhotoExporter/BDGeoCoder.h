//
//  BDGeoCoder.h
//  PhotoExporter
//
//  Created by henkzhang(张珩) on 2020/7/14.
//  Copyright © 2020 chiyouhen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BDGeoCoder : NSObject
- (void) reverseGeocodeLocation: (CLLocation*) location completionHandler: (void(^)(CNPostalAddress* postalAddress, NSError* error)) completionHandler;
@end

NS_ASSUME_NONNULL_END


