//
//  JAWAppDelegate.h
//  TileSliderGame
//
//  Created by Joshua Walker on 9/25/13.
//  Copyright (c) 2013 joshwalker. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JAWGameViewController;

@interface JAWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) JAWGameViewController *mainViewController;
@end
