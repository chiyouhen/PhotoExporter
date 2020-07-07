//
//  AppController.m
//  PhotoExporter
//
//  Created by henkzhang(张珩) on 2020/7/7.
//  Copyright © 2020 chiyouhen. All rights reserved.
//

#import <Photos/Photos.h>
#import "AppController.h"

@implementation AppController
- (IBAction) btnSelectDirectory: (id) sender
{
    NSOpenPanel* dirDlg = [NSOpenPanel openPanel];
    [dirDlg setCanChooseFiles: NO];
    [dirDlg setCanChooseDirectories: YES];
    [dirDlg setAllowsMultipleSelection: NO];

    if ([dirDlg runModal] == NSModalResponseOK)
    {
        NSArray* directories = [dirDlg URLs];
        NSLog(@"%@", directories);
        NSString* path = [directories[0] path];
        NSLog(path);
        [txtDirectoryPath setStringValue: path];
    }
}

- (IBAction) btnSubmit: (id) sender
{
    [txtSummary setStringValue: [NSString stringWithFormat: @"from %@ to %@ under %@", [dpBegin dateValue], [dpEnd dateValue], [txtDirectoryPath stringValue]]];


}

@end
