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
- (void) awakeFromNib {
    [super awakeFromNib];
    NSDate* now = [NSDate date];
    [[self dpBegin] setDateValue: now];
    [[self dpEnd] setDateValue: now];
    [[self txtDirectoryPath] setStringValue: @""];
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
        NSLog(@"%@", path);
        [[self txtDirectoryPath] setStringValue: path];
    }
}

- (IBAction) btnSubmit: (id) sender {
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDir;
    NSString* dirPath = [[self txtDirectoryPath] stringValue];
    if (! ([fm fileExistsAtPath: dirPath isDirectory: &isDir] && isDir)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSAlert* alert = [[NSAlert alloc] init];
            [alert setAlertStyle: NSAlertStyleCritical];
            [alert setMessageText: [NSString stringWithFormat: @"No directory %@", dirPath]];
            
            [alert runModal];
        });
        return;
    }
    
    [[self txtSummary] setStringValue: [NSString stringWithFormat: @"from %@ to %@ under %@", [[self dpBegin] dateValue], [[self dpEnd] dateValue], [[self txtDirectoryPath] stringValue]]];
    PHFetchOptions* fetchOptions = [[PHFetchOptions alloc] init];
    [fetchOptions setPredicate: [NSPredicate predicateWithFormat: @"(creationDate >= %@) AND (creationDate <= %@)", [[self dpBegin] dateValue], [[self dpEnd] dateValue]]];
    PHFetchResult<PHAsset*>* fetchResult = [PHAsset fetchAssetsWithOptions: fetchOptions];
    NSLog(@"got %ld items", [fetchResult count]);
    [self setTotalCount: [fetchResult count]];
    [self setCurrentCount: 0];
    
    [fetchResult enumerateObjectsUsingBlock: ^(PHAsset* asset, NSUInteger idx, BOOL* stop) {
        Image* image = [[Image alloc] initWithPHAsset: asset];
        dispatch_semaphore_t parallel = dispatch_semaphore_create(1);
        [image setParallel: parallel];
        [image retrieve: ^{
            NSArray* pathComponents = [NSArray arrayWithObjects: dirPath, [image categoryKey], nil];
            NSString* path = [NSString pathWithComponents: pathComponents];
            [image save: path];
            [self incCurrentCount];
            if ([self isFinished]) {
                [self finished];
            }
        }
           errorHandler: ^{
            NSLog(@"An error occured while retrieve %@", [image name]);
        }];
    }];
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
    });
}

@end
