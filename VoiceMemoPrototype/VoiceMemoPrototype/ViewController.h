//
//  ViewController.h
//  VoiceMemoPrototype
//
//  Created by Ben Pankhurst on 6/10/14.
//  Copyright (c) 2014 Ben Pankhurst. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpeechKit/SpeechKit.h>

@interface ViewController : UIViewController <UITextViewDelegate, SpeechKitDelegate, SKRecognizerDelegate, SKVocalizerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) SKRecognizer *voiceSearch;
@property (nonatomic, strong) SKVocalizer *vocalizer;
@property BOOL isSpeaking;

- (IBAction)recordButtonPressed:(id)sender;
- (IBAction)playbackButtonPressed:(id)sender;
- (IBAction)readbackButtonPressed:(id)sender;

@end
