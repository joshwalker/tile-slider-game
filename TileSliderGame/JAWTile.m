//
//  JAWTile.m
//  TileSliderGame
//
//  Created by Joshua Walker on 9/25/13.
//  Copyright (c) 2013 joshwalker. All rights reserved.
//

#import "JAWTile.h"

@implementation JAWTile

-(id) initWithRow:(int)row andColumn:(int)column {
    self = [super init];
    if (self) {
        _winningPosition = [NSIndexPath indexPathForRow:row inSection:column];
        _blank = NO;
        
        self.userInteractionEnabled = YES;
        
    }
    return self;
}


@end
