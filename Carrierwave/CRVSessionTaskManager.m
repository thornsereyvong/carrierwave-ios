//
//  CRVTaskManager.m
//  Carrierwave
//
//  Created by Patryk Kaczmarek on 10.01.2015.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

#import "CRVSessionTaskManager.h"
#import "NSURLSessionTask+Category.h"

@interface CRVSessionTaskManager ()

@property (strong, nonatomic, readwrite) NSMutableArray *downloadTaskWrappers;
@property (strong, nonatomic, readwrite) NSMutableArray *uploadTaskWrappers;

@end

@implementation CRVSessionTaskManager

#pragma mark - Public Methods

- (instancetype)init {
    self = [super init];
    if (self) {
        _downloadTaskWrappers = [NSMutableArray array];
        _uploadTaskWrappers = [NSMutableArray array];
    }
    return self;
}

- (void)addDownloadTask:(NSURLSessionDownloadTask *)task progress:(CRVSessionTaskProgress)progress completion:(CRVDownloadCompletionHandler)completion {
    CRVSessionDownloadTaskWrapper *wrapper = [[CRVSessionDownloadTaskWrapper alloc] initWithTask:task progress:progress completion:completion];
    [self.downloadTaskWrappers addObject:wrapper];
}

- (void)addUploadTask:(NSURLSessionUploadTask *)task progress:(CRVSessionTaskProgress)progress completion:(CRVUploadCompletionHandler)completion {
    CRVSessionUploadTaskWrapper *wrapper = [[CRVSessionUploadTaskWrapper alloc] initWithTask:task progress:progress completion:completion];
    [self.uploadTaskWrappers addObject:wrapper];
}

- (NSSet *)taskWrappers {
    NSMutableSet *wrappers = [NSMutableSet setWithArray:self.downloadTaskWrappers];
    [wrappers addObjectsFromArray:self.uploadTaskWrappers];
    return [wrappers copy];
}

- (void)removeDowloadTaskWrapper:(CRVSessionDownloadTaskWrapper *)taskWrapper {
    [self.downloadTaskWrappers removeObject:taskWrapper];
}

- (void)removeUploadTaskWrapper:(CRVSessionUploadTaskWrapper *)taskWrapper {
    [self.uploadTaskWrappers removeObject:taskWrapper];
}

- (void)invokeProgressForDownloadTask:(NSURLSessionTask *)task {
    CRVSessionTaskProgress progressBlock = [self wrapperForTask:task].progress;
    if (progressBlock != NULL) progressBlock([task crv_dowloadProgress]);
}

- (void)invokeCompletionForDownloadTaskWrapper:(CRVSessionDownloadTaskWrapper *)wrapper data:(NSData *)data error:(NSError *)error {
    if (wrapper.completion != NULL) wrapper.completion(data, error);
    [self removeDowloadTaskWrapper:wrapper];
}

- (CRVSessionDownloadTaskWrapper *)downloadWrapperForTask:(NSURLSessionDownloadTask *)task {
    return [[self.downloadTaskWrappers filteredArrayUsingPredicate:[self predicateForTask:task]] firstObject];
}

- (CRVSessionUploadTaskWrapper *)uploadWrapperForTask:(NSURLSessionTask *)task {
    return [[self.uploadTaskWrappers filteredArrayUsingPredicate:[self predicateForTask:task]] firstObject];
}

- (void)cancelAllTasks {
    for (CRVSessionDownloadTaskWrapper *wrapper in self.downloadTaskWrappers) {
        [wrapper.task cancel];
    }
    
    for (CRVSessionUploadTaskWrapper *wrapper in self.uploadTaskWrappers) {
        [wrapper.task cancel];
    }
    [self.downloadTaskWrappers removeAllObjects];
    [self.uploadTaskWrappers removeAllObjects];
}

#pragma mark - Private Methods

- (CRVSessionTaskWrapper *)wrapperForTask:(NSURLSessionTask *)task {
    NSSet *set = [self.taskWrappers filteredSetUsingPredicate:[self predicateForTask:task]];
    return [set.allObjects firstObject];
}

- (NSPredicate *)predicateForTask:(NSURLSessionTask *)task {
    return [NSPredicate predicateWithFormat:@"SELF.task == %@", task];
}

@end
