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
#import "Image.h"

@implementation AppController
- (void) incCurrentCount {
    @synchronized (self) {
        [self setCurrentCount: [self currentCount] + 1];
    }
}
- (void) appendExportedURL: (NSURL*) url {
    @synchronized (self) {
        if ([[self exportedURLs] containsObject: url]) {
            return;
        }
        [[self exportedURLs] addObject: url];
    }
}
- (void) awakeFromNib {
    [super awakeFromNib];
    NSDate* now = [NSDate date];
    [[self dpBegin] setDateValue: now];
    [[self dpEnd] setDateValue: now];
    [[self txtProgress] setStringValue: @""];
    [[self progressBar] setDoubleValue: 0.0];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSURL* downloadsURL = [fm URLForDirectory:NSDownloadsDirectory
                                     inDomain:NSUserDomainMask
                            appropriateForURL:nil
                                       create:YES error:nil];
    [self setDirectoryURL: downloadsURL];
    [self setExportedURLs: [[NSMutableArray alloc] init]];
    NSLog(@"now %@", now);
}

- (IBAction) btnSubmit: (id) sender {
    [[self exportedURLs] removeAllObjects];
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDir;
    NSString* dirPath = [[self directoryURL] path];
    if (! ([fm fileExistsAtPath: dirPath isDirectory: &isDir] && isDir)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSAlert* alert = [[NSAlert alloc] init];
            [alert setAlertStyle: NSAlertStyleCritical];
            [alert setMessageText: [NSString stringWithFormat: @"No directory %@", dirPath]];
            
            [alert runModal];
        });
        return;
    }
    
    PHFetchOptions* fetchOptions = [[PHFetchOptions alloc] init];
    [fetchOptions setPredicate: [NSPredicate predicateWithFormat: @"(creationDate >= %@) AND (creationDate <= %@)", [[self dpBegin] dateValue], [[self dpEnd] dateValue]]];
    PHFetchResult<PHAsset*>* fetchResult = [PHAsset fetchAssetsWithOptions: fetchOptions];
    NSLog(@"got %ld items", [fetchResult count]);
    [self setTotalCount: [fetchResult count]];
    [self setCurrentCount: 0];
    [self setCurrentImage: nil];
    [self updateProgress];
    
    [fetchResult enumerateObjectsUsingBlock: ^(PHAsset* asset, NSUInteger idx, BOOL* stop) {
        Image* image = [[Image alloc] initWithPHAsset: asset];
        dispatch_semaphore_t parallel = dispatch_semaphore_create(1);
        [image setParallel: parallel];
        [image retrieve: ^{
            NSArray* pathComponents = [NSArray arrayWithObjects: dirPath, [image categoryKey], nil];
            NSString* path = [NSString pathWithComponents: pathComponents];
            [image save: path];
            [self incCurrentCount];
            [self setCurrentImage: image];
            [self updateProgress];
            NSURL* currentURL = [[self directoryURL] URLByAppendingPathComponent: [image categoryKey]];
            [self appendExportedURL: currentURL];
            if ([self isFinished]) {
                [self finished];
            }
        }
           errorHandler: ^{
            NSLog(@"An error occured while retrieve %@", [image name]);
        }];
    }];
}

- (void) updateProgress {
    Image* currentImage = [self currentImage];
    NSString* progressText;
    if (currentImage == nil) {
        progressText = @"";
    } else {
        progressText = [NSString stringWithFormat: @"%d/%d %@/%@", [self currentCount], [self totalCount], [currentImage categoryKey], [currentImage name]];
    }
    NSLog(@"progress text: %@", progressText);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self txtProgress] setStringValue: progressText];
        [[self progressBar] setDoubleValue: [self currentCount] * 100.0 / [self totalCount]];
    });
}

- (BOOL) isFinished {
    NSLog(@"currentCount: %ld, totalCount: %ld", [self currentCount], [self totalCount]);
    return [self totalCount] == [self currentCount];
}

- (void) finished {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert* alert = [[NSAlert alloc] init];
        [alert setAlertStyle: NSAlertStyleInformational];
        [alert setMessageText: NSLocalizedString(@"Finished", @"")];
        
        [alert runModal];
        NSLog(@"%@", [self exportedURLs]);
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs: [self exportedURLs]];
    });

}

@end
