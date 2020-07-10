//
//  AppController.m
//  PhotoExporter
//
//  Created by henkzhang(张珩) on 2020/7/7.
//  Copyright © 2020 chiyouhen. All rights reserved.
//

#import <Photos/Photos.h>
#import <CoreLocation/CoreLocation.h>
#import <Contacts/Contacts.h>
#import "AppController.h"
#import "AppDelegate.h"
void handlePHAsset(PHAsset* asset, NSUInteger idx, BOOL* stop) {
    NSLog(@"idx %ld, creationDate: %@", idx, [asset creationDate]);
    CLLocation* assetLocation = [asset location];
    CLGeocoder* geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation: assetLocation
                  completionHandler:^(NSArray<CLPlacemark*>* placemarks, NSError* error) {
        for (CLPlacemark* placemark in placemarks) {
            NSLog(@"stop %d, index %ld, creationDate: %@, location: (%f,%f)%@[%@-%@-%@-%@-%@-%@]", stop, idx, [asset creationDate],
                  [assetLocation coordinate].latitude, [assetLocation coordinate].longitude,
                  [placemark name], [placemark country], [placemark administrativeArea], [placemark subAdministrativeArea], [placemark locality], [placemark subLocality], [placemark thoroughfare]);
        }
        *stop = NO;
    }];
}
@implementation AppController

- (void) awakeFromNib {
    [super awakeFromNib];
    NSDate* now = [NSDate date];
    [dpBegin setDateValue: now];
    [dpEnd setDateValue: now];
    NSLog(@"now %@", now);
}
- (IBAction) btnSelectDirectory: (id) sender {
    NSOpenPanel* dirDlg = [NSOpenPanel openPanel];
    [dirDlg setCanChooseFiles: NO];
    [dirDlg setCanChooseDirectories: YES];
    [dirDlg setAllowsMultipleSelection: NO];

    if ([dirDlg runModal] == NSModalResponseOK)
    {
        NSArray* directories = [dirDlg URLs];
        NSLog(@"%@", directories);
        NSString* path = [directories[0] path];
        NSLog(@"%s", path);
        [txtDirectoryPath setStringValue: path];
    }
}

- (IBAction) btnSubmit: (id) sender {
    AppDelegate* appDelegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
    NSLog(@"%@", appDelegate);
    [appDelegate setTmp: @"test"];
    
    [txtSummary setStringValue: [NSString stringWithFormat: @"from %@ to %@ under %@", [dpBegin dateValue], [dpEnd dateValue], [txtDirectoryPath stringValue]]];
    PHFetchOptions* fetchOptions = [[PHFetchOptions alloc] init];
    [fetchOptions setPredicate: [NSPredicate predicateWithFormat: @"(creationDate >= %@) AND (creationDate <= %@)", [dpBegin dateValue], [dpEnd dateValue]]];
    PHFetchResult<PHAsset*>* fetchResult = [PHAsset fetchAssetsWithOptions: fetchOptions];
    NSLog(@"got %ld items", [fetchResult count]);
    
    PHImageManager* phImageManager = [PHImageManager defaultManager];

    [fetchResult enumerateObjectsUsingBlock: ^(PHAsset* asset, NSUInteger idx, BOOL* stop) {
        NSLog(@"idx %ld, creationDate: %@", idx, [asset creationDate]);
        CLLocation* assetLocation = [asset location];
        CLGeocoder* geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation: assetLocation
                         preferredLocale: [NSLocale localeWithLocaleIdentifier: @"zh_CN"]
                       completionHandler: ^(NSArray<CLPlacemark*>* placemarks, NSError* error) {
            NSLog(@"geocoder, idx %ld, error: %@", idx, error);
            for (CLPlacemark* placemark in placemarks) {
                /*
                NSLog(@"stop %d, index %ld, creationDate: %@, location: (%f,%f)%@[%@-%@-%@-%@-%@-%@]", stop, idx, [asset creationDate],
                      [assetLocation coordinate].latitude, [assetLocation coordinate].longitude,
                      [placemark name], [placemark country], [placemark administrativeArea], [placemark subAdministrativeArea], [placemark locality], [placemark subLocality], [placemark thoroughfare]);
                 */
                CNPostalAddress* postalAddress = [placemark postalAddress];
                NSLog(@"stop %d, index %ld, creationDate: %@, location: (%f,%f)[%@][%@]", stop, idx, [asset creationDate],
                      [assetLocation coordinate].latitude, [assetLocation coordinate].longitude,
                      postalAddress, placemark);
            }
        }];
        
        if ([asset mediaType] != PHAssetMediaTypeImage) {
            NSLog(@"idx: %ld, not image", idx);
            return;
        }
        CGSize imageSize;
        imageSize.height = [asset pixelHeight];
        imageSize.width = [asset pixelWidth];
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
            NSData* imageData = [result TIFFRepresentation];
            NSBitmapImageRep* imageRep = [NSBitmapImageRep imageRepWithData: imageData];
            NSColorSpace* colorSpace = [imageRep colorSpace];
            NSLog(@"idx: %ld, colorSpace: %@", idx, colorSpace);
            
        }];
        

    }];
}

@end
