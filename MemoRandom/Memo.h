//
//  Memo.h
//  MemoRandom
//
//  Created by Lauren Manzo on 28/10/14.
//  Copyright (c) 2014 Lauren Manzo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Memo : NSManagedObject

@property (nonatomic, retain) NSString * audioFilePath;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * length;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * text;

@end
