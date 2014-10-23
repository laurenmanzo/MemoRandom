//
//  ViewController.h
//  VoiceMemoPrototype
//
//  Created by Ben Pankhurst on 6/10/14.
//  Copyright (c) 2014 Ben Pankhurst. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpeechKit/SpeechKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <UITextViewDelegate, SpeechKitDelegate, SKRecognizerDelegate, SKVocalizerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *recordToAudioButton;
@property (weak, nonatomic) IBOutlet UIButton *playbackButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) SKRecognizer *voiceSearch;
@property (nonatomic, strong) SKVocalizer *vocalizer;
@property BOOL isSpeaking;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

- (IBAction)recordButtonPressed:(id)sender;
- (IBAction)recordToAudioButtonPressed:(id)sender;
- (IBAction)playbackButtonPressed:(id)sender;
- (IBAction)readbackButtonPressed:(id)sender;
- (void)setupAVAudioRecorder;

@end
