//
//  SoundSamplesViewController.m
//  FoundationFun
//
//  Created by Brennan Cleveland on 5/30/14.
//  Copyright (c) 2014 Brennan Cleveland. All rights reserved.
//

#import "SoundSamplesViewController.h"
#import "RecordingManager.h"

@interface SoundSamplesViewController ()

@property (nonatomic, strong) NSMutableArray *files;
@property (nonatomic, strong) NSMutableArray *audioPlayers;

@end

@implementation SoundSamplesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.files = [[NSMutableArray alloc] initWithArray: [self sampleFiles]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    for(AVAudioPlayer *player in self.audioPlayers)
    {
        [player stop];
    }
    [self.audioPlayers removeAllObjects];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.files.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SampleCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.files objectAtIndex:indexPath.row];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSError *error = nil;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if(error)
    {
        NSLog(@"%@", error);
        return;
    }
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if(error)
    {
        NSLog(@"%@", error);
        return;
    }
    
    NSString *file = [NSString stringWithFormat:@"%@/%@", [RecordingManager sharedInstance].url.path, [self.files objectAtIndex:indexPath.row]];
    
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:file] error:&error];
    
    if(error)
    {
        NSLog(@"%@", error);
        return;
    }
    
    player.delegate = self;
    
    if(!self.audioPlayers)
    {
        self.audioPlayers = [[NSMutableArray alloc] initWithObjects:player, nil];
    }
    else
    {
        [self.audioPlayers addObject:player];
    }
    
    BOOL success = [player prepareToPlay];
    if(!success)
    {
        NSLog(@"Could not prepare to play file!");
    }
    
    success = [player play];
    if(!success)
    {
        NSLog(@"Could not play file!");
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if([self deleteFileAtIndex:indexPath.row])
        {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            [self showAlertWithMessage: NSLocalizedString(@"SAMPLES_DELETE_FAILED", @"Deletion failed")];
        }
    }
}

#pragma mark - AVAudioPlayerDelegate methods

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if(flag)
    {
        NSLog(@"Succuessfully played");
    }
    else
    {
        NSLog(@"Playback failed");
    }
    
    [self.audioPlayers removeObject:player];
}

- (void) audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"%@", error);
    [self.audioPlayers removeObject:player];
}

#pragma mark - private methods

- (BOOL) deleteFileAtIndex: (NSInteger) index
{
    NSError *error = nil;
    BOOL success = NO;
    
    NSString *file = [NSString stringWithFormat:@"%@/%@", [[RecordingManager sharedInstance].url path], [self.files objectAtIndex:index]];
    success = [[NSFileManager defaultManager] removeItemAtPath:file error:&error];
    if(success)
    {
        [self.files removeObjectAtIndex:index];
    }
    else
    {
        NSLog(@"%@", error);
    }

    return success;
}

- (NSArray *) sampleFiles
{
    NSArray *sampleFiles = nil;
    NSError *error = nil;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[RecordingManager sharedInstance].url path] error:&error];
    if(error)
    {
        NSLog(@"%@", error);
        return sampleFiles;
    }
    
    NSIndexSet *indexSet = [files indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        NSRange range = [obj rangeOfString:@"sample_"];
        if(range.location == NSNotFound || range.location != 0)
        {
            return NO;
        }
        
        return YES;
    }];
    
    sampleFiles = [NSArray arrayWithArray:[files objectsAtIndexes:indexSet]];
    
    return sampleFiles;
}

- (void) showAlertWithMessage: (NSString *) message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

@end
