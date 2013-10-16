//
//  JAWGameBoard.h
//  TileSliderGame
//
//  Created by Joshua Walker on 9/25/13.
//  Copyright (c) 2013 joshwalker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JAWTile.h"

@protocol JAWGameBoardProtocol;

@interface JAWGameBoard : UIView  

@property (nonatomic, strong) NSArray *tiles;
@property (nonatomic, strong) UIImage *gameImg;
@property (nonatomic, weak) id<JAWGameBoardProtocol> delegate;

-(id)initGame;

-(BOOL)winningLayout;

-(BOOL) canMoveTile:(JAWTile *)tile direction:(int)direction;
-(NSArray *)tilesToMoveFromTile:(JAWTile *)tile inDirection:(int)direction;
-(void)moveTiles:(NSArray *)tiles inDirection:(int)direction;
-(CGPoint) centerForTile:(JAWTile *)tile;

@end

@protocol JAWGameBoardProtocol <NSObject>

-(void)didWin;

@end
