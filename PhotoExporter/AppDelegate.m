//
//  AppDelegate.m
//  PhotoExporter
//
//  Created by henkzhang(张珩) on 2020/7/7.
//  Copyright © 2020 chiyouhen. All rights reserved.
//

#import <Photos/Photos.h>
#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        if (status != PHAuthorizationStatusAuthorized) {
            NSLog(@"Authorized status [%ld]", status);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSAlert* alert = [[NSAlert alloc] init];
                [alert setAlertStyle: NSAlertStyleCritical];
                [alert setMessageText: NSLocalizedString(@"Please grant the permission of photo album access", @"")];
                [alert runModal];
                [[NSApplication sharedApplication] terminate: nil];
            });
        }
    }];
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction) about: (id) sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert* alert = [[NSAlert alloc] init];
        [alert setAlertStyle: NSAlertStyleInformational];
        [alert setMessageText: @"PhotoExporter by chiyouhen"];
        [alert runModal];
    });
}


@end
