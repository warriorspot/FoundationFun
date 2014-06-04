//
//  RecordingViewController.m
//  FoundationFun
//
//  Created by Brennan Cleveland on 5/30/14.
//  Copyright (c) 2014 Brennan Cleveland. All rights reserved.
//

#import "RecordingViewController.h"
#import "RecordingManager.h"

@implementation RecordingViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.recordButton.layer.cornerRadius = 6.0;
    self.recordButton.layer.borderWidth = 1.0;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(didSelectShowSamples:)];
    
    [self updateStatus:NSLocalizedString(@"STATUS_WAITING", @"Ready to record")];
}

#pragma mark - RecordingManagerDelegate methods

- (void) recordingManagerWillStartRecording:(RecordingManager *)manager
{
    [self updateUIForRecordingStatus:YES];
}

- (void) recordingManagerDidStartRecording:(RecordingManager *)manager
{
    [self updateStatus:NSLocalizedString(@"STATUS_RECORDING_ACTIVE", @"Recording")];
}

- (void) recordingManager:(RecordingManager *)manager recordingFinishedWithData:(id)data
{
    [self updateStatus:NSLocalizedString(@"STATUS_RECORDING_ENDED", @"Recording finished")];
    [self updateUIForRecordingStatus:NO];
}

- (void) recordingManager:(RecordingManager *)manager recordingFailedWithError:(NSError *)error
{
    NSString *errorString = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"STATUS_RECORDING_ERROR", @"Recording error"),  error.localizedDescription];
    [self updateStatus: errorString];
    [self updateUIForRecordingStatus:NO];
}

#pragma mark - actions

- (IBAction)didSelectRecord:(id)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [RecordingManager sharedInstance].delegate = self;
    [[RecordingManager sharedInstance] record];
}

- (void) didSelectShowSamples: (id) sender
{
    [self performSegueWithIdentifier:@"show_samples" sender:self];
}

#pragma mark - private methods

- (void) updateUIForRecordingStatus: (BOOL) recording
{
    if(recording)
    {
        [self.recordingIndicator startAnimating];
        self.recordButton.enabled = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.recordButton.alpha = 0.3;
        }];
    }
    else
    {
        [self.recordingIndicator stopAnimating];
        self.recordButton.enabled = YES;
        [UIView animateWithDuration:0.3 animations:^{
            self.recordButton.alpha = 1.0;
        }];
        [self performSelector:@selector(updateStatus:) withObject:NSLocalizedString(@"STATUS_WAITING", @"Ready to record") afterDelay:3.0];
    }
}

- (void) updateStatus: (NSString *) message
{
    [UIView animateWithDuration:0.3 animations:^{
        self.statusLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.statusLabel.text = message;
        [UIView animateWithDuration:0.3 animations:^{
            self.statusLabel.alpha = 1.0;
        }];
    }];
}

@end
