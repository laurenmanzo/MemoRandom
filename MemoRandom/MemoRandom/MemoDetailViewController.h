//
//  MemoDetailViewController.h
//  MemoRandom
//
//  Created by Lauren Manzo on 26/10/14.
//  Copyright (c) 2014 Lauren Manzo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Memo.h"

@interface MemoDetailViewController : UIViewController <AVAudioPlayerDelegate, UITextViewDelegate>

//Data
@property (nonatomic, strong) Memo *memo;

//User Interface
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSTimer *updateTimer;

//For state
@property (nonatomic) BOOL isEditing;


- (void)setMemo:(Memo *)memo;
- (IBAction)playPauseButtonPressed:(id)sender;
- (NSString*)formatTimeString:(float)time;
- (void)updateTime;
- (IBAction)seekTime:(id)sender;
- (void)beginEndEditing;
@end
