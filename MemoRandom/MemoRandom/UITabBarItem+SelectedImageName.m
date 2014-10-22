//
//  UITabBarItem+SetSelectedImageName.m
//  Assignment2
//
//  Created by Lauren Manzo on 13/09/14.
//  Copyright (c) 2014 Lauren Manzo. All rights reserved.
//

#import "UITabBarItem+SelectedImageName.h"

@implementation UITabBarItem (UITabBarItemSelectedImageName)

- (void)setSelectedImageName:(NSString *)selectedImageName {
    self.selectedImage = [UIImage imageNamed:selectedImageName];
}

@end
