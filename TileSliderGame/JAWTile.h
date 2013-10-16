//
//  JAWTile.h
//  TileSliderGame
//
//  Created by Joshua Walker on 9/25/13.
//  Copyright (c) 2013 joshwalker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAWTile : UIImageView 

@property (nonatomic, strong) NSIndexPath *currentPosition;
@property (nonatomic, strong) NSIndexPath *winningPosition;
@property (nonatomic, assign) BOOL blank;

-(id) initWithRow:(int)row andColumn:(int)column;

@end
