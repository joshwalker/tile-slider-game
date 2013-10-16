//
//  JAWGameBoard.m
//  TileSliderGame
//
//  Created by Joshua Walker on 9/25/13.
//  Copyright (c) 2013 joshwalker. All rights reserved.
//


#import "JAWGameBoard.h"

@interface JAWGameBoard ()

@property (nonatomic, strong) JAWTile *blankTile;

@end

@implementation JAWGameBoard

-(id)initGame {
    self = [super init];
    if (self) {

        _gameImg = [UIImage imageNamed:@"Globe"];
        
        NSMutableArray *randomizeArray = [NSMutableArray array];
        
        CGFloat scale = _gameImg.scale;
        
        int tileWidth = _gameImg.size.width * scale / NUM_ROWS;
        int tileHeight = _gameImg.size.height *scale / NUM_COLS;
        
        // Create tiles and split up image to set tile image view
        
        for (int i = 0; i < NUM_ROWS; i++) {
            for (int j = 0; j < NUM_COLS; j++) {
                JAWTile *tempTile = [[JAWTile alloc] initWithRow:i andColumn:j];
                
                CGImageRef gameBoardImgTile = CGImageCreateWithImageInRect(_gameImg.CGImage, CGRectMake(tileWidth * j, tileHeight * i, tileWidth, tileHeight));
                
                tempTile.image = [UIImage imageWithCGImage:gameBoardImgTile];
                
                CGImageRelease(gameBoardImgTile);
                [randomizeArray addObject:tempTile];
            }
        }
        
        // Run through array one full time, randomly swapping each position
        
        int size = NUM_ROWS * NUM_COLS;
        for (int i=0; i < size; i++) {

            NSInteger n = arc4random() % size;
            [randomizeArray exchangeObjectAtIndex:i withObjectAtIndex:n];
        }
        
        // Get one random tile to blank out
        
        NSInteger n = arc4random() % size;
        JAWTile *tempTile = randomizeArray[n];
        tempTile.blank = YES;
        _blankTile = tempTile;
        
        _tiles = randomizeArray;
        
        // Go through the randomized array to set current positions and add the subviews in correct place
        
        for (int i = 0; i < NUM_ROWS; i++) {

            for (int j = 0; j < NUM_COLS; j++) {
                JAWTile *tempTile = _tiles[(i * NUM_ROWS) + j];
                
                tempTile.currentPosition = [NSIndexPath indexPathForRow:i inSection:j];

                if (!tempTile.blank) {
                    tempTile.frame = CGRectMake(tileHeight/scale *j, tileWidth/scale * i,  tileWidth/scale, tileHeight/scale);
                    [self addSubview:tempTile];
                }else {
                    
                    // Need to add the blank tile or the UIDynamics will fail
                    // Just throw it on out of view
                    
                    tempTile.frame = CGRectMake(400, 400, 10, 10);
                    [self addSubview:tempTile];
                }
                
            }
        }
        
        self.backgroundColor = [UIColor grayColor];
        
    }
    return self;
}



-(CGPoint) centerForTile:(JAWTile *)tile {
    CGPoint center = CGPointMake(tile.currentPosition.section * tile.frame.size.width + tile.frame.size.width / 2,
                                 tile.currentPosition.row * tile.frame.size.height + tile.frame.size.height / 2);
    return center;
}

/*
 * Once we know we can move a tile, get a list of the tiles that will move with it
 * Basically all tiles between target tile, and the blank tile.
 */

-(NSArray *)tilesToMoveFromTile:(JAWTile *)tile inDirection:(int)direction {
    NSMutableArray *tilesToMove = [NSMutableArray array];
    switch (direction) {
        case UP: {
            int numTilesToMove = tile.currentPosition.row - self.blankTile.currentPosition.row;
            
            for (int j = 0; j < numTilesToMove; j++) {
                [tilesToMove addObject:[self tileAtRow:tile.currentPosition.row - j column:tile.currentPosition.section]];
            }
            
            break;
        }
        case DOWN: {
            int numTilesToMove = self.blankTile.currentPosition.row - tile.currentPosition.row;
            for (int j = 0; j < numTilesToMove; j++) {
                [tilesToMove addObject:[self tileAtRow:tile.currentPosition.row + j column:tile.currentPosition.section]];
            }
            break;
            
        }
        case LEFT: {
            int numTilesToMove = tile.currentPosition.section - self.blankTile.currentPosition.section;
            for (int j = 0; j < numTilesToMove; j++) {
                [tilesToMove addObject:[self tileAtRow:tile.currentPosition.row column:tile.currentPosition.section - j]];
            }
            break;
            
        }
        case RIGHT: {
            int numTilesToMove = self.blankTile.currentPosition.section - tile.currentPosition.section;
            for (int j = 0; j < numTilesToMove; j++) {
                [tilesToMove addObject:[self tileAtRow:tile.currentPosition.row column:tile.currentPosition.section + j]];
            }
            break;
            
        }
        default:
            break;
    }
    return tilesToMove;
}

/*
 * Find if the blank tile is in same row/column as referenced tile
 * 
 * Instead of looping through row, could just compare with position of _blankTile
 * 
 */

-(BOOL) canMoveTile:(JAWTile *)tile direction:(int)direction {
    int tileCol = tile.currentPosition.section;
    int tileRow = tile.currentPosition.row;
    switch (direction) {
        case UP:
        {
            for (int i = tileRow-1; i >= 0; i--) {
                JAWTile *tempTile = [self tileAtRow:i column:tileCol];
                if (tempTile.blank) {
                    return true;
                }
            }
            break;
        }
        case DOWN: {
            for (int i = tileRow +1; i < NUM_ROWS; i++) {
                JAWTile *tempTile = [self tileAtRow:i column:tileCol];
                if (tempTile.blank) {
                    return true;
                }
            }
            break;

        }
        case LEFT: {
            for (int i = tileCol-1; i >= 0; i--) {
                JAWTile *tempTile = [self tileAtRow:tileRow column:i];
                if (tempTile.blank) {
                    return true;
                }
            }
            break;
            
        }
        case RIGHT: {
            for (int i = tileCol +1; i < NUM_ROWS; i++) {
                JAWTile *tempTile = [self tileAtRow:tileRow column:i];
                if (tempTile.blank) {
                    return true;
                }
            }
            break;
            
        }
        default:
            break;
    }
    return false;
}

/*
 * Actually do the move of the tiles
 * This updates the currentPosition and the frame
 *
 * Check for winning position after each move
 */

-(void)moveTiles:(NSArray *)tiles inDirection:(int)direction {
    
    JAWTile *firstTile = tiles[0];
    self.blankTile.currentPosition = firstTile.currentPosition;
    
    switch (direction) {
        case UP:
        {
            
            for (JAWTile *tile in tiles) {
                CGPoint originalOrigin = CGPointMake(tile.currentPosition.section * tile.frame.size.width, tile.currentPosition.row * tile.frame.size.height);
                
                tile.currentPosition = [NSIndexPath indexPathForRow:tile.currentPosition.row - 1 inSection:tile.currentPosition.section];
                tile.frame = CGRectMake(originalOrigin.x , originalOrigin.y - tile.frame.size.height, tile.frame.size.width, tile.frame.size.height);
            }
            break;
        }
        case DOWN: {
            for (JAWTile *tile in tiles) {
                CGPoint originalOrigin = CGPointMake(tile.currentPosition.section * tile.frame.size.width, tile.currentPosition.row * tile.frame.size.height);
                tile.currentPosition = [NSIndexPath indexPathForRow:tile.currentPosition.row + 1 inSection:tile.currentPosition.section];
                tile.frame = CGRectMake(originalOrigin.x , originalOrigin.y + tile.frame.size.height, tile.frame.size.width, tile.frame.size.height);
            }
            break;
            
        }
        case LEFT: {
            for (JAWTile *tile in tiles) {
                CGPoint originalOrigin = CGPointMake(tile.currentPosition.section * tile.frame.size.width, tile.currentPosition.row * tile.frame.size.height);
                tile.currentPosition = [NSIndexPath indexPathForRow:tile.currentPosition.row inSection:tile.currentPosition.section -1];
                tile.frame = CGRectMake(originalOrigin.x - tile.frame.size.width, originalOrigin.y , tile.frame.size.width, tile.frame.size.height);
            }
            break;
            
        }
        case RIGHT: {
            for (JAWTile *tile in tiles) {
                CGPoint originalOrigin = CGPointMake(tile.currentPosition.section * tile.frame.size.width, tile.currentPosition.row * tile.frame.size.height);
                tile.currentPosition = [NSIndexPath indexPathForRow:tile.currentPosition.row inSection:tile.currentPosition.section +1];
                tile.frame = CGRectMake(originalOrigin.x + tile.frame.size.width, originalOrigin.y , tile.frame.size.width, tile.frame.size.height);
            }
            break;
        }
        default:
            break;
    }
    
    if ([self winningLayout]) {
        NSLog(@"You win");
        [self.delegate didWin];
    }
    
}

-(BOOL)winningLayout {
    for (JAWTile *tile in self.tiles) {
        if ([tile.currentPosition compare:tile.winningPosition] != NSOrderedSame) {
            return false;
        }
    }
    return true;
}

- (JAWTile *) tileAtRow:(int)row column:(int)col
{
    for (JAWTile *tile in self.tiles) {
        if (tile.currentPosition.row == row && tile.currentPosition.section == col) {
            return tile;
        }
    }
    
    [NSException raise:@"Index out of Bounds" format:@"The values given are outside bounds  %i, %i", row,col];
    return nil;
}
@end
