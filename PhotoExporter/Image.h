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

@interface Image : NSObject{
    PHAsset* asset;
    NSImage* image;
    CLPlacemark* placemark;
}

@property PHAsset* asset;
@property NSImage* image;
@property CLPlacemark* placemark;

- (id) initWithPHAsset: (PHAsset*) asset;
- (id) initWithPHAssetAsync: (PHAsset*) asset dispatchGroup: (dispatch_group_t) group;

@end

NS_ASSUME_NONNULL_END
