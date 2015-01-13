//
//  CRVSessionUploadTaskWrapper.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 13.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSessionUploadTaskWrapper.h"

@implementation CRVSessionUploadTaskWrapper

- (instancetype)initWithTask:(NSURLSessionUploadTask *)task progress:(CRVSessionTaskProgress)progress completion:(CRVUploadCompletionHandler)completion {
    self = [self initWithProgress:progress];
    if (self) {
        _completion = completion;
        _task = task;
    }
    return self;
}

@end
