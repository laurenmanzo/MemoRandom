//
//  MemoDetailViewController.m
//  MemoRandom
//
//  Created by Lauren Manzo on 26/10/14.
//  Copyright (c) 2014 Lauren Manzo. All rights reserved.
//

#import "MemoDetailViewController.h"

@interface MemoDetailViewController ()

@end

@implementation MemoDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	[self setTitle:self.memo.name];
	self.textView.text = self.memo.text;
	self.textView.delegate = self;
	
	//Create the Edit Button
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(beginEndEditing)];
	self.navigationItem.rightBarButtonItem = editButton;
	
	self.isEditing = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playPauseButtonPressed:(id)sender {
	if (!self.audioPlayer.playing) {
		[sender setSelected:YES]; //Change button to pause
		
		if (!self.audioPlayer) {
			NSError *error;
			
			self.audioPlayer = [[AVAudioPlayer alloc]
								initWithContentsOfURL:[NSURL fileURLWithPath:self.memo.audioFilePath]
								error:&error];
			
			self.audioPlayer.delegate = self;
			
			self.slider.minimumValue = 0;
			self.slider.maximumValue = self.audioPlayer.duration;
			
			if (error) {
				NSLog(@"Error: %@",
					  [error localizedDescription]);
			}
		}

		[self.audioPlayer play];
		self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];

	} else {
		[sender setSelected:NO]; //Change the button to play
		[self.audioPlayer pause];
		[self.updateTimer invalidate];
		self.updateTimer = nil;
	}
}


- (NSString*)formatTimeString:(float)time {
	//Assumes the time is no greater than 59:59.9 minutes.
	int mins = time/60;
	double seconds = time - (mins * 60);
	
	return [NSString stringWithFormat:@"%02d:%02.0f", mins, seconds];
}

- (void)updateTime {
	float progress = self.audioPlayer.currentTime;
	[self.slider setValue:progress animated:YES];
	self.timeLabel.text = [self formatTimeString:progress];
}

- (IBAction)seekTime:(id)sender {
	self.audioPlayer.currentTime = self.slider.value;
}

# pragma mark AVAudioPlayer delegate methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	[self.playPauseButton setSelected:NO];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
	NSLog(@"Decode Error occurred");
}

# pragma mark UITextView delegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	return self.isEditing;
}

- (void)beginEndEditing {
	if(self.isEditing) {
		//End editing
		//Change button to 'Edit'
		self.navigationItem.rightBarButtonItem.title = @"Edit";
		//Resign first responder
		[self.textView resignFirstResponder];
		//Save text
		NSError *error = nil;
		self.memo.text = self.textView.text;
		if (![self.memo.managedObjectContext save:&error]) {
			NSLog(@"Unable to save managed object context.");
			NSLog(@"%@, %@", error, error.localizedDescription);
		}
		self.isEditing = NO;
	} else {
		//Begin editing
		//Change button to 'Done'
		self.navigationItem.rightBarButtonItem.title = @"Done";
		//Become first responder
		[self.textView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.1f];
		self.isEditing = YES;
	}
}


@end
