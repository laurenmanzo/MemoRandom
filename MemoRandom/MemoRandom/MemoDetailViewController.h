//
//  MemoDetailViewController.h
//  MemoRandom
//
//  Created by Lauren Manzo on 26/10/14.
//  Copyright (c) 2014 Lauren Manzo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Memo.h"

@interface MemoDetailViewController : UIViewController

//Data
@property (nonatomic, strong) Memo *memo;

- (void)setMemo:(Memo *)memo;

@end
