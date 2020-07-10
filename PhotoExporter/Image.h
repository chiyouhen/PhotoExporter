//
//  Image.h
//  PhotoExporter
//
//  Created by henkzhang(张珩) on 2020/7/10.
//  Copyright © 2020 chiyouhen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

enum ImageRes {
    ImageResOK = 0,
    ImageResBadType = 1,
    ImageResGeoFailed = 2,
    ImageResRetrieveImage = 3,
};

@interface Image : NSObject

@property PHAsset* asset;
@property NSImage* image;
@property CLPlacemark* placemark;
@property void(^retrieveHandler)(void);
@property dispatch_semaphore_t parallel;
@property NSString* categoryKey;

- (id) initWithPHAsset: (PHAsset*) asset;
- (void) retrieve: (void(^)(void)) retrieveHandler;
- (BOOL) retrieved;
- (int) save: (NSString*) path;

@end

NS_ASSUME_NONNULL_END
