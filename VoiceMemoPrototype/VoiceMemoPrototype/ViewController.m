//
//  ViewController.m
//  VoiceMemoPrototype
//
//  Created by Ben Pankhurst on 6/10/14.
//  Copyright (c) 2014 Ben Pankhurst. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

const unsigned char SpeechKitApplicationKey[] = {
	0x26, 0xe1, 0x97, 0xe0, 0x04, 0x73, 0x24, 0x19,0x7b, 0x7a, 0x2a, 0x1c, 0x4d, 0x5a, 0x4c, 0xfd, 0x8a, 0x35, 0xc9, 0x61, 0x0e, 0x19, 0x78, 0x3c, 0x4c, 0x20, 0x7d, 0x85, 0xba, 0xc6, 0xae, 0xe0, 0xa8, 0x45, 0xc0, 0xac, 0xb8, 0xe4, 0xc5, 0x33, 0x5e, 0xef, 0x4f, 0xac, 0x49, 0x9b, 0xa9, 0xd4, 0xd1, 0x73, 0x35, 0xdf, 0x8c, 0xad, 0x1b, 0xd8, 0xce, 0x99, 0x5e, 0x88, 0x5f, 0x0c, 0x68, 0x07
};

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [VoiceMemoPrototypeAppDelegate setupSpeechKitConnection];
	[self setupAVAudioRecorder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)recordButtonPressed:(id)sender {
	self.recordButton.selected = !self.recordButton.isSelected;
	
    // This will initialize a new speech recognizer instance
    if (self.recordButton.isSelected) {
        self.voiceSearch = [[SKRecognizer alloc] initWithType:SKDictationRecognizerType
                                                    detection:SKNoEndOfSpeechDetection
                                                     language:@"en_US"
                                                     delegate:self];
    }
	
    // This will stop existing speech recognizer processes
    else {
        if (self.voiceSearch) {
            [self.voiceSearch stopRecording];
            //[self.voiceSearch cancel];
        }
		if (self.isSpeaking) {
			[self.vocalizer cancel];
			self.isSpeaking = NO;
		}
    }
}

- (IBAction)recordToAudioButtonPressed:(id)sender {
	if (!self.audioRecorder.recording)
	{
		self.playbackButton.enabled = NO;
		[self.audioRecorder record];
	} else {
		self.playbackButton.enabled = YES;
		self.recordButton.enabled = YES;
		
		if (self.audioRecorder.recording)
		{
            [self.audioRecorder stop];
		}
	}
}

- (IBAction)playbackButtonPressed:(id)sender {
	if (!self.audioRecorder.recording)
    {
		if (!self.audioPlayer.playing) {
        	NSError *error;
			
			self.audioPlayer = [[AVAudioPlayer alloc]
								initWithContentsOfURL:self.audioRecorder.url
								error:&error];
			
			self.audioPlayer.delegate = self;
			
			if (error)
				NSLog(@"Error: %@",
					  [error localizedDescription]);
			else
				[self.audioPlayer play];
		} else {
            [self.audioPlayer stop];
		}
	}
}

- (IBAction)readbackButtonPressed:(id)sender {
	if (self.isSpeaking) {
		[self.vocalizer cancel];
	}
	
	self.isSpeaking = YES;
	
	self.vocalizer = [[SKVocalizer alloc] initWithLanguage:@"en_US" delegate:self];
	
	[self.vocalizer speakString:self.textView.text];
}

# pragma mark - SKRecognizer Delegate Methods

- (void)recognizerDidBeginRecording:(SKRecognizer *)recognizer {
	self.messageLabel.text = @"Listening..";
}

- (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer {
	self.messageLabel.text = @"Done Listening..";
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results {
	long numOfResults = [results.results count];
	
	if (numOfResults > 0) {
		// update the text of text field with best result from SpeechKit
		if ([self.textView.text isEqualToString:@""]) {
			self.textView.text = [results firstResult];
		} else {
			self.textView.text = [NSString stringWithFormat:@"%@\n%@", self.textView.text, [results firstResult]];
		}
	}
	
	if (self.voiceSearch) {
		[self.voiceSearch cancel];
	}
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion {
	self.recordButton.selected = NO;
	self.messageLabel.text = @"Connection error";

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
													message:[error localizedDescription]
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
}

# pragma mark - SKVocalizer Delegate Methods

- (void)vocalizer:(SKVocalizer *)vocalizer willBeginSpeakingString:(NSString *)text {
    self.isSpeaking = YES;
}

- (void)vocalizer:(SKVocalizer *)vocalizer didFinishSpeakingString:(NSString *)text withError:(NSError *)error {
	if (error != nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:[error localizedDescription]
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		
		if (self.isSpeaking) {
			[self.vocalizer cancel];
		}
    }
	
    self.isSpeaking = NO;
}

# pragma mark - AVAudioRecorder Delegate methods

- (void)setupAVAudioRecorder {
	_playbackButton.enabled = NO;
	NSArray *dirPaths;
	NSString *docsDir;
	
	dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	docsDir = [dirPaths firstObject];
	
	NSString *soundFilePath = [docsDir stringByAppendingString:@"sound.caf"];
	
	NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
	
	NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey,
									[NSNumber numberWithInt:16], AVEncoderBitRateKey,
									[NSNumber numberWithInt:2], AVNumberOfChannelsKey,
									[NSNumber numberWithFloat:44100.0], AVSampleRateKey,
									nil];
	
	NSError *error = nil;
	
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	[audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
	
	_audioRecorder = [[AVAudioRecorder alloc]initWithURL:soundFileURL settings:recordSettings error:&error];
	
	if (error) {
		NSLog(@"error: %@", [error localizedDescription]);
	} else {
		[_audioRecorder prepareToRecord];
	}
}

# pragma mark AVAudioPlayer delegate methods

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	_recordButton.enabled = YES;
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
	NSLog(@"Decode Error occurred");
}

# pragma mark AVAudioRecorder Delegate methods

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
	NSLog(@"Encode Error occurred");
}

@end
