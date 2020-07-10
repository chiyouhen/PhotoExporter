//
//  Image.m
//  PhotoExporter
//
//  Created by henkzhang(张珩) on 2020/7/10.
//  Copyright © 2020 chiyouhen. All rights reserved.
//

#import "Image.h"

@implementation Image

- (int) retrieveImage {
    
}

- (id) initWithPHAsset: (PHAsset*) asset dispatchGroup: (dispatch_group_t) group {
    if (self = [super init]) {
        [self setAsset: asset];
    }
    return self;
}

@end
