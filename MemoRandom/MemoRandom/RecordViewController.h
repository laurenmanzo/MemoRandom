//
//  FirstViewController.h
//  MemoRandom
//
//  Created by Lauren Manzo on 26/10/14.
//  Copyright (c) 2014 Lauren Manzo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpeechKit/SpeechKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Memo.h"

@interface RecordViewController : UIViewController <SpeechKitDelegate, SKRecognizerDelegate, AVAudioRecorderDelegate, UITextFieldDelegate, UIAlertViewDelegate>

//For state
@property (nonatomic) BOOL recordingAudio;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSDate* startTime;
@property (nonatomic) NSTimeInterval elapsedTime;
@property (nonatomic, strong) NSString *soundFilePath;
@property (nonatomic, strong) NSString *result;
//For user interface
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *recordStopButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
//For data persistance
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Memo *memo;
@property (nonatomic, strong) NSEntityDescription *memoEntityDescription;
//For voice recording
@property (nonatomic, strong) SKRecognizer *voiceSearch;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;

- (IBAction)recordButtonPressed:(id)sender;
- (NSString*)formatTimeString:(NSTimeInterval)time;
- (void)timeTick:(NSTimer*)timer;
- (void)setupAVAudioRecorder;
- (void)deleteFile:(NSString*)filePath;
@end
