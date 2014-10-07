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
    }
}

- (IBAction)playbackButtonPressed:(id)sender {
}

- (IBAction)readbackButtonPressed:(id)sender {
}

- (IBAction)playButtonPressed:(id)sender {
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


@end
