//
//  RecordingManager.h
//  FoundationFun
//
//  Created by Brennan Cleveland on 5/31/14.
//  Copyright (c) 2014 Brennan Cleveland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface RecordingManager : NSObject <AVAudioSessionDelegate, AVAudioRecorderDelegate>

@property (nonatomic, weak) id delegate;
@property (nonatomic, copy) NSURL *url;
@property (atomic) NSTimeInterval recordingDuration;

+ (RecordingManager *) sharedInstance;

- (void) record;
- (void) stop;

@end

@protocol RecordingManagerDelegate <NSObject>

@optional
- (void) recordingManagerWillStartRecording: (RecordingManager *) manager;
- (void) recordingManagerDidStartRecording:(RecordingManager *)manager;
- (void) recordingManager: (RecordingManager *) manager recordingFailedWithError: (NSError *) error;
- (void) recordingManager: (RecordingManager *) manager recordingFinishedWithData: (id) data;

@end