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
@synthesize placemark;
@synthesize retrievedHandler;
@synthesize retrieveErrorHandler;
@synthesize name;
@synthesize error;
@synthesize cancelled;

- (int) retrieveImage {
    if ([self image] != nil) {
        dispatch_semaphore_signal([self parallel]);
        if ([self retrieved]) {
            [self retrievedHandler]();
        }
        return 0;
    }
    
    PHImageManager* phImageManager = [PHImageManager defaultManager];
    CGSize imageSize;
    imageSize.height = [[self asset] pixelHeight];
    imageSize.width = [[self asset] pixelWidth];
    PHImageRequestOptions* imageRequestOptions = [[PHImageRequestOptions alloc] init];
    [imageRequestOptions setSynchronous: YES];
    [imageRequestOptions setVersion: PHImageRequestOptionsVersionCurrent];
    [imageRequestOptions setDeliveryMode: PHImageRequestOptionsDeliveryModeHighQualityFormat];
    [imageRequestOptions setNetworkAccessAllowed: YES];
    
    dispatch_semaphore_wait([self parallel], DISPATCH_TIME_FOREVER);
    [phImageManager requestImageForAsset: asset
                              targetSize: imageSize
                             contentMode: PHImageContentModeDefault
                                 options: imageRequestOptions
                           resultHandler: ^(NSImage* result, NSDictionary* info){
        dispatch_semaphore_signal([self parallel]);
        
        NSError* error = info[PHImageErrorKey];
        if (error != nil) {
            [self setError: error];
            NSLog(@"An error occured while requestImage for %@, %@", [self name], error);
            [self retrieveErrorHandler]();
            return;
        }
        
        BOOL cancelled = [info[PHImageCancelledKey] boolValue];
        if (cancelled) {
            [self setCancelled: YES];
            NSLog(@"Request for %@ cancelled", [self name]);
            [self retrieveErrorHandler]();
            return;
        }
        
        [self setImage: result];

        if ([self retrieved]) {
            [self retrievedHandler]();
        }
    }];

    return 0;
    
}

- (void) geocodeRetrieved {
    [self categoryKeyGen];
    if ([self retrieved]) {
        [self retrievedHandler]();
    }
}

- (int) retrieveGeocode {
    if ([self placemark] != nil) {
        dispatch_semaphore_signal([self parallel]);
        [self geocodeRetrieved];
        return 0;
    }
    CLLocation* assetLocation = [[self asset] location];
    if (assetLocation == nil) {
        dispatch_semaphore_signal([self parallel]);
        [self setPlacemark: nil];
        [self geocodeRetrieved];
        return 0;
    }
    CLGeocoder* geocoder = [[CLGeocoder alloc] init];
    
    dispatch_semaphore_wait([self parallel], DISPATCH_TIME_FOREVER);
    [geocoder reverseGeocodeLocation: assetLocation
                   completionHandler: ^(NSArray<CLPlacemark*>* placemarks, NSError* error) {
        dispatch_semaphore_signal([self parallel]);
        
        if (error != nil) {
            [self setError: error];
            NSLog(@"An error occured while retrieveGeocode for %@, %@", [self name], error);
            [self retrieveErrorHandler]();
            return;
        }
        
        [self setPlacemark: [placemarks objectAtIndex: 0]];
        [self geocodeRetrieved];
    }];
    return 0;
}

- (id) initWithPHAsset: (PHAsset*) asset {
    if (self = [super init]) {
        [self setAsset: asset];
        if ([self parallel] == nil) {
            [self setParallel: dispatch_semaphore_create(1)];
        }
        NSArray<PHAssetResource*>* phAssetResources = [PHAssetResource assetResourcesForAsset: [self asset]];
        for (PHAssetResource* res in phAssetResources) {
            if ([res type] == PHAssetResourceTypePhoto) {
                NSString* imageName = [[res originalFilename] stringByDeletingPathExtension];
                [self setName: imageName];
                break;
            }
        }
    }
    return self;
}

- (void) retrieve: (void(^)(void)) retrieveHandler errorHandler: (void(^)(void)) retrieveErrorHandler {
    [self setImage: nil];
    [self setPlacemark: nil];
    [self setError: nil];
    [self setCancelled: NO];
    [self setRetrievedHandler: retrieveHandler];
    [self setRetrieveErrorHandler: retrieveErrorHandler];
    [self retrieveImage];
    [self retrieveGeocode];
}

- (NSString*) description {
    return [NSString stringWithFormat: @"%@: [%@], %ldx%ld, %@",
             [self name], [[self asset] creationDate],
             [[self asset] pixelWidth], [[self asset] pixelHeight],
             [self categoryKey]];
}

- (void) categoryKeyGen {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle: NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle: NSDateFormatterNoStyle];
    NSMutableString* address = [NSMutableString stringWithCapacity: 64];
    CLPlacemark* placemark = [self placemark];
    if (placemark != nil) {
        if ([placemark country] != nil) {
            [address appendFormat: @"%@", [placemark country]];
        }
        if ([placemark administrativeArea] != nil) {
            [address appendFormat: @" - %@", [placemark administrativeArea]];
        }
        if ([placemark locality] != nil) {
            [address appendFormat: @" - %@", [placemark locality]];
        }
        if ([placemark subLocality] != nil) {
            [address appendFormat: @" - %@", [placemark subLocality]];
        }
        if ([placemark thoroughfare] != nil) {
            [address appendFormat: @" - %@", [placemark thoroughfare]];
        }
    } else {
        [address appendFormat: @"Unknown"];
    }
    NSString* key = [NSString stringWithFormat: @"%@, %@",
                     [dateFormatter stringFromDate: [[self asset] creationDate]],
                     address];
    [self setCategoryKey: key];
                     
}

- (BOOL) retrieved {
    if ([self image] != nil && [self categoryKey] != nil) {
        return YES;
    }
    return NO;
}

- (int) save: (NSString*) path {
    if (! [self retrieved]) {
        return 1;
    }
    NSData* data = [[self image] TIFFRepresentation];
    NSBitmapImageRep* imageRep = [NSBitmapImageRep imageRepWithData: data];
    NSDictionary* properties = @{
        NSImageCompressionFactor: [NSNumber numberWithFloat: 1.0],
    };
    data = [imageRep representationUsingType: NSBitmapImageFileTypeJPEG
                                  properties: properties];
    NSFileManager* fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath: path]) {
        BOOL isDir;
        [fm fileExistsAtPath: path
                 isDirectory: &isDir];
        if (! isDir) {
            NSLog(@"path %@ exits, but not a directory", path);
            return 1;
        }
    } else {
        NSError* error;
        BOOL created = [fm createDirectoryAtPath: path
                     withIntermediateDirectories:YES
                                      attributes: nil
                                           error: &error];
        if (! created) {
            NSLog(@"error occured while create directory %@, %@", path, error);
            return 1;
        }
    }
    NSString* imageName = [self name];
    NSArray* pathComponents = [NSArray arrayWithObjects: path, [NSString stringWithFormat: @"%@.jpg", imageName], nil];
    NSString* filePath = [NSString pathWithComponents: pathComponents];
    [data writeToFile: filePath
           atomically: YES];
    NSLog(@"attempt to write file to %@", filePath);
    return 0;
}

@end
