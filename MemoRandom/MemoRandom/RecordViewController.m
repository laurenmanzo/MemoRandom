//
//  RecordViewController.m
//  MemoRandom
//
//  Created by Lauren Manzo on 26/10/14.
//  Copyright (c) 2014 Lauren Manzo. All rights reserved.
//

#import "RecordViewController.h"
#import "AppDelegate.h"


@interface RecordViewController ()

@end

const unsigned char SpeechKitApplicationKey[] = {
	0x26, 0xe1, 0x97, 0xe0, 0x04, 0x73, 0x24, 0x19,0x7b, 0x7a, 0x2a, 0x1c, 0x4d, 0x5a, 0x4c, 0xfd, 0x8a, 0x35, 0xc9, 0x61, 0x0e, 0x19, 0x78, 0x3c, 0x4c, 0x20, 0x7d, 0x85, 0xba, 0xc6, 0xae, 0xe0, 0xa8, 0x45, 0xc0, 0xac, 0xb8, 0xe4, 0xc5, 0x33, 0x5e, 0xef, 0x4f, 0xac, 0x49, 0x9b, 0xa9, 0xd4, 0xd1, 0x73, 0x35, 0xdf, 0x8c, 0xad, 0x1b, 0xd8, 0xce, 0x99, 0x5e, 0x88, 0x5f, 0x0c, 0x68, 0x07
};

@implementation RecordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//Setup the managed object context
	self.managedObjectContext = MemoRandomAppDelegate.managedObjectContext;
	self.memoEntityDescription = [NSEntityDescription entityForName:@"Memo" inManagedObjectContext:self.managedObjectContext];
	
	//Set recordingJourney to NO until they press the start button.
	self.recordingAudio = NO;
	
	self.recognizerError = NO;
	
	[MemoRandomAppDelegate setupSpeechKitConnection];
	
	[self setupAVAudioRecorder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)recordButtonPressed:(id)sender {
	if (!self.recordingAudio) { //Start
		
		self.recordStopButton.title = @"Stop";
		self.recordingAudio = YES;
		
		//Start timer
		self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timeTick:) userInfo:nil repeats:YES];
		
		//Store start time
		self.startTime = [NSDate date];
		
		//Initialize a new speech recognizer instance
		self.voiceSearch = [[SKRecognizer alloc] initWithType:SKDictationRecognizerType
													detection:SKNoEndOfSpeechDetection
													 language:@"en_US"
													 delegate:self];
		
		//Start the AVAudioRecorder
		[self.audioRecorder record];
		
	} else { //Stop
		self.recordStopButton.title = @"Record";
		self.recordingAudio = NO;
		
		//Stop timer
		[self.timer invalidate];
		self.timer = nil;
		
		//Store the elapsedTime
		self.elapsedTime = [self.startTime timeIntervalSinceNow] * -1;
		
		// This will stop existing speech recognizer processes
		if (self.voiceSearch) {
			[self.voiceSearch stopRecording];
			//[self.voiceSearch cancel];
		}
		
		//Stop the AVAudioRecorder
		[self.audioRecorder stop];
		
		if (self.recognizerError) {
			//Modal popup
			UIAlertView *save = [[UIAlertView alloc] initWithTitle:@"Save Memo" message:@"Please enter a name" delegate:self cancelButtonTitle:@"Discard" otherButtonTitles:@"Save", nil];
			save.alertViewStyle = UIAlertViewStylePlainTextInput;
			[save textFieldAtIndex:0].delegate = self;
			[save show];
		}
	}
}

- (NSString*)formatTimeString:(NSTimeInterval)time {
	//Assumes the time is no greater than 59:59.9 minutes.
	int mins = time/60;
	double seconds = time - (mins * 60);
	
	return [NSString stringWithFormat:@"%02d:%04.1f", mins, seconds];
}

- (void)timeTick:(NSTimer*)timer {
	//Calculate elapsed time
	NSTimeInterval elapsedTime = [self.startTime timeIntervalSinceNow] * -1;
	
	//Update the current time labels
	NSString *elapsedTimeString = [self formatTimeString:elapsedTime];
	self.timeLabel.text = elapsedTimeString;
}

# pragma mark - SKRecognizer Delegate Methods

- (void)recognizerDidBeginRecording:(SKRecognizer *)recognizer {
}

- (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer {
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results {
	long numOfResults = [results.results count];
	
	if (numOfResults > 0) {
		self.result = [results firstResult];
	}
	
	//Modal popup
	UIAlertView *save = [[UIAlertView alloc] initWithTitle:@"Save Memo" message:@"Please enter a name" delegate:self cancelButtonTitle:@"Discard" otherButtonTitles:@"Save", nil];
	save.alertViewStyle = UIAlertViewStylePlainTextInput;
	[save textFieldAtIndex:0].delegate = self;
	[save show];
	
	if (self.voiceSearch) {
		[self.voiceSearch cancel];
	}
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion {
	NSLog(@"Recognizer Error: %@", [error localizedDescription]);
	self.recognizerError = YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		//Cancel
		self.result = nil;
		self.startTime = nil;
		self.elapsedTime = 0;
		[self deleteFile:self.soundFilePath];
		self.result = nil;
	} else if (buttonIndex == 1) {
		//Save button
		//Store the Memo
		//Setup data persistence
		Memo* memo = (Memo*)[[NSManagedObject alloc] initWithEntity:self.memoEntityDescription insertIntoManagedObjectContext:self.managedObjectContext];
		memo.date = self.startTime;
		memo.name = [alertView textFieldAtIndex:0].text;
		memo.text =  self.result;
		memo.audioFilePath = self.soundFilePath;
		memo.length = (NSString*)[self formatTimeString:self.elapsedTime];
		
		//Save the journey
		NSError *error = nil;
		
		if (![memo.managedObjectContext save:&error]) {
			NSLog(@"Unable to save managed object context.");
			NSLog(@"%@, %@", error, error.localizedDescription);
		}
	}
	self.recognizerError = NO;
	[self setupAVAudioRecorder];
}

# pragma mark - AVAudioRecorder methods

- (void)setupAVAudioRecorder {
	NSArray *dirPaths;
	NSString *docsDir;
	
	dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	docsDir = [dirPaths firstObject];
	
	//Create a file name using the current date.
	NSDate *now = [NSDate date];
	NSString *dateString = now.description;
	NSString *soundFilePath = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf", dateString]];
	self.soundFilePath = soundFilePath;
	
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

# pragma mark AVAudioRecorder Delegate methods

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
	NSLog(@"Encode Error occurred");
	[self deleteFile:self.soundFilePath];
}

- (void)deleteFile:(NSString*)filePath {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	BOOL success = [fileManager removeItemAtPath:filePath error:&error];
	if (!success) {
		NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
	}
}



@end
