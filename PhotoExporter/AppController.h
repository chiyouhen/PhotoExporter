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


@property IBOutlet NSDatePicker* dpBegin;
@property IBOutlet NSDatePicker* dpEnd;
@property IBOutlet NSTextField* txtDirectoryPath;
@property IBOutlet NSTextField* txtSummary;
@property (atomic) NSUInteger currentCount;
@property (atomic) NSUInteger totalCount;

- (IBAction) btnSelectDirectory: (id) sender;
- (IBAction) btnSubmit: (id) sender;
- (BOOL) isFinished;
- (void) finished;

@end

NS_ASSUME_NONNULL_END
