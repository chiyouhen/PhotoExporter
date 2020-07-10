//
//  Image.m
//  PhotoExporter
//
//  Created by henkzhang(张珩) on 2020/7/10.
//  Copyright © 2020 chiyouhen. All rights reserved.
//

#import <Photos/Photos.h>
#import <AppKit/AppKit.h>
#import "Image.h"

@implementation Image

@synthesize asset;
@synthesize image;
@synthesize resources;
@synthesize placemarks;
@synthesize retrieveHandler;

- (int) retrieveImage {
    if ([[self asset] mediaType] != PHAssetMediaTypeImage) {
        return 1;
    }
    if ([self image] != nil) {
        return 0;
    }
    /*
    PHImageManager* phImageManager = [PHImageManager defaultManager];
    CGSize imageSize;
    imageSize.height = [[self asset] pixelHeight];
    imageSize.width = [[self asset] pixelWidth];
    PHImageRequestOptions* imageRequestOptions = [[PHImageRequestOptions alloc] init];
    [imageRequestOptions setSynchronous: YES];
    [imageRequestOptions setVersion: PHImageRequestOptionsVersionCurrent];
    [imageRequestOptions setDeliveryMode: PHImageRequestOptionsDeliveryModeHighQualityFormat];
    [imageRequestOptions setNetworkAccessAllowed: YES];
    
    [phImageManager requestImageForAsset: asset
                              targetSize: imageSize
                             contentMode: PHImageContentModeDefault
                                 options: imageRequestOptions
                           resultHandler: ^(NSImage* result, NSDictionary* info){
        [self setImage: result];
        if ([self retrieved]) {
            [self retrieveHandler]();
        }
        
    }];
     */
    NSArray<PHAssetResource*>* phAssetResources = [PHAssetResource assetResourcesForAsset: [self asset]];
    [self setResources: phAssetResources];
    for (PHAssetResource* res in phAssetResources) {
        
    }
    
    return 0;
    
}

- (int) retrieveGeocode {
    if ([self placemarks] != nil) {
        return 0;
    }
    CLLocation* assetLocation = [[self asset] location];
    CLGeocoder* geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation: assetLocation
                   completionHandler: ^(NSArray<CLPlacemark*>* placemarks, NSError* error) {
        [self setPlacemarks: placemarks];
        if ([self retrieved]) {
            [self retrieveHandler]();
        }
    }];
 
    return 0;
}

- (id) initWithPHAsset: (PHAsset*) asset {
    if (self = [super init]) {
        [self setAsset: asset];
    }
    return self;
}

- (void) retrieve: (void(^)(void)) retrieveHandler {
    [self setRetrieveHandler: retrieveHandler];
    [self retrieveImage];
    [self retrieveGeocode];
}

- (NSString*) description {
    return [NSString stringWithFormat: @"%@: [%@], %ldx%ld, %@",
             [self resources], [[self asset] creationDate],
             [[self asset] pixelWidth], [[self asset] pixelHeight],
             [[self placemarks] objectAtIndex: 0]];
}

- (BOOL) retrieved {
    if ([self resources] != nil && [self placemarks] != nil) {
        return YES;
    }
    return NO;
}

@end
