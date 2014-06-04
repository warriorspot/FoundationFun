//
//  RecordingManager.m
//  FoundationFun
//
//  Created by Brennan Cleveland on 5/31/14.
//  Copyright (c) 2014 Brennan Cleveland. All rights reserved.
//

#import "RecordingManager.h"

@interface RecordingManager()

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSURL * filePath;

@end


@implementation RecordingManager

#pragma mark - class methods

+ (RecordingManager *) sharedInstance
{
    static RecordingManager *recordingManager = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        recordingManager = [[RecordingManager alloc] init];
    });
    
    return recordingManager;
}

#pragma mark - instance methods

- (id) init
{
    self = [super init];
    if(self)
    {
        self.url = [[NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory
                                                     inDomains:(NSUserDomainMask)] objectAtIndex:0];
        self.recordingDuration = 5.0;
    }

    return self;
}

- (void) record
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    [session requestRecordPermission:^(BOOL granted) {
        if(!granted)
        {
            NSDictionary *info = @{NSLocalizedDescriptionKey: NSLocalizedString(@"ERROR_ACCESS_DENIED", @"Access denied")};
            NSError *error = [NSError errorWithDomain:@"app" code:1 userInfo:info];
            [self informDelegateOfError:error];
            return;
        }
    }];
    
    [self informDelegateWillBegin];
    
    NSError *error = nil;
    [session setCategory:AVAudioSessionCategoryRecord error:&error];
    [session setActive:YES error:&error];
    if(error)
    {
        [self informDelegateOfError:error];
        return;
    }
    
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    
    [settings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [settings setValue :[NSNumber numberWithFloat:22050.0] forKey:AVSampleRateKey];
    [settings setValue :[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    [settings setValue :[NSNumber numberWithInt:8] forKey:AVLinearPCMBitDepthKey];
    [settings setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [settings setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];

    NSString *filename = [NSString stringWithFormat:@"%@/sample_%ld.caf", [self.url path], (long)[NSDate timeIntervalSinceReferenceDate]];
    self.filePath = [NSURL fileURLWithPath:filename isDirectory:NO];
    self.recorder = [[AVAudioRecorder alloc] initWithURL:self.filePath settings:settings error:&error];
    if(error)
    {
        [self informDelegateOfError:error];
        return;
    }
    self.recorder.delegate = self;
    
    if(!session.inputAvailable)
    {
        error = [NSError errorWithDomain:@"app" code:2 userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"ERROR_NO_INPUT", @"Recording input not available")}];
        [self informDelegateOfError:error];
    }

    BOOL result = [self.recorder prepareToRecord];
    if(!result)
    {
        error = [NSError errorWithDomain:@"app" code:3 userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"ERROR_PREPARE_FAILED", @"Could not prepare to record")}];
        [self informDelegateOfError:error];
        return;
    }
    result = [self.recorder recordForDuration:self.recordingDuration];
    if(!result)
    {
        error = [NSError errorWithDomain:@"app" code:3 userInfo:@{NSLocalizedDescriptionKey : NSLocalizedString(@"ERROR_RECORD_FAILED", @"Could not record")}];
        [self informDelegateOfError:error];
        return;
    }
    [self informDelegateDidBegin];
}

- (void) stop
{
    [self.recorder stop];
    [self informDelegateDidEnd];
}

#pragma mark - AVAudioRecorderDelegate methods

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if(flag)
    {
        [self informDelegateDidEnd];
    }
    else
    {
        NSLog(@"Recording failed");
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"%@", error);
    [self.recorder stop];
    [self informDelegateOfError:error];
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder
{
    NSLog(@"AVAudioRecorder interrupted");
    [self.recorder stop];
    [self informDelegateDidEnd];
}

- (void) audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags
{
    NSLog(@"AVAudioRecorder end interruption");
}

#pragma mark - AVAudioSessionDelegate methods

- (void) beginInterruption
{
    
}

- (void) endInterruption
{
    
}

- (void) endInterruptionWithFlags:(NSUInteger)flags
{
    
}

- (void) inputIsAvailableChanged:(BOOL)isInputAvailable
{
    
}

#pragma mark - private methods

- (void) informDelegateWillBegin
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(recordingManagerWillStartRecording:)])
    {
        [self.delegate recordingManagerWillStartRecording:self];
    }
}

- (void) informDelegateDidBegin
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(recordingManagerDidStartRecording:)])
    {
        [self.delegate recordingManagerDidStartRecording:self];
    }
}

- (void) informDelegateDidEnd
{
    NSError *error = nil;
    NSData *audioData = [NSData dataWithContentsOfFile:[self.filePath path] options: 0 error:&error];
    if(!audioData)
    {
        [self informDelegateOfError:error];
        return;
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(recordingManager:recordingFinishedWithData:)])
    {
        [self.delegate recordingManager:self recordingFinishedWithData:audioData];
    }
}

- (void) informDelegateOfError: (NSError *) error
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(recordingManager:recordingFailedWithError:)])
    {
        [self.delegate recordingManager:self recordingFailedWithError:error];
    }
}

@end
