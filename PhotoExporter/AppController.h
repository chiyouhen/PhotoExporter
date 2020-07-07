//
//  AppController.h
//  PhotoExporter
//
//  Created by henkzhang(张珩) on 2020/7/7.
//  Copyright © 2020 chiyouhen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppController : NSObject
{
    IBOutlet NSDatePicker* dpBegin;
    IBOutlet NSDatePicker* dpEnd;
    IBOutlet NSTextField* txtDirectoryPath;
    IBOutlet NSTextField* txtSummary;
    IBOutlet NSWindow* window;
}

- (IBAction) btnSelectDirectory: (id) sender;
- (IBAction) btnSubmit: (id) sender;


@end

NS_ASSUME_NONNULL_END
