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
#import <Contacts/Contacts.h>

NS_ASSUME_NONNULL_BEGIN

@interface Image : NSObject

@property PHAsset* asset;
@property (nullable) NSImage* image;
@property (nullable) CLPlacemark* placemark;
@property (nullable) CNPostalAddress* postalAddress;
@property void(^retrievedHandler)(void);
@property void(^retrieveErrorHandler)(void);
@property (nonnull) NSString* categoryKey;
@property (nonnull) NSString* name;
@property (nullable) NSError* error;
@property BOOL cancelled;

- (id) initWithPHAsset: (PHAsset*) asset;
- (void) retrieve: (void(^)(void)) retrieveHandler errorHandler: (void(^)(void)) retrieveErrorHandler;
- (BOOL) retrieved;
- (int) save: (NSString*) path;

@end

NS_ASSUME_NONNULL_END
