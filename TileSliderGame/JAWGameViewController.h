//
//  JAWGameViewController.h
//  TileSliderGame
//
//  Created by Joshua Walker on 10/1/13.
//  Copyright (c) 2013 joshwalker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAWGameBoard.h"

@interface JAWGameViewController : UIViewController <UIGestureRecognizerDelegate, JAWGameBoardProtocol>

@property (nonatomic, strong) JAWGameBoard *board;

@end
