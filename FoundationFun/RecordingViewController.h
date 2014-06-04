//
//  RecordingViewController.h
//  FoundationFun
//
//  Created by Brennan Cleveland on 5/30/14.
//  Copyright (c) 2014 Brennan Cleveland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecordingManager.h"

@interface RecordingViewController : UIViewController <RecordingManagerDelegate>

@property (nonatomic, weak) IBOutlet UIButton *recordButton;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *recordingIndicator;

- (IBAction)didSelectRecord:(id)sender;

@end
