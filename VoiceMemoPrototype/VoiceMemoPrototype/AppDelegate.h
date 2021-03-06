//
//  AppDelegate.h
//  VoiceMemoPrototype
//
//  Created by Ben Pankhurst on 6/10/14.
//  Copyright (c) 2014 Ben Pankhurst. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpeechKit/SpeechKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)setupSpeechKitConnection;

@end
