//
//  Memo.m
//  MemoRandom
//
//  Created by Lauren Manzo on 28/10/14.
//  Copyright (c) 2014 Lauren Manzo. All rights reserved.
//

#import "Memo.h"


@implementation Memo

@dynamic date;
@dynamic length;
@dynamic audioFilePath;
@dynamic name;
@dynamic text;

- (void)deleteAudioFile {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	BOOL success = [fileManager removeItemAtPath:self.audioFilePath error:&error];
	if (!success) {
		NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
	}
}


@end
