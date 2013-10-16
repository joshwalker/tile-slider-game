//
//  JAWGameViewController.m
//  TileSliderGame
//
//  Created by Joshua Walker on 10/1/13.
//  Copyright (c) 2013 joshwalker. All rights reserved.
//

#import "JAWGameViewController.h"

@interface JAWGameViewController ()

@property (nonatomic) int movingDirection;
@property (nonatomic, strong) NSArray *tilesToMove;

@property UIDynamicAnimator * animator;

@end

@implementation JAWGameViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _board = [[JAWGameBoard alloc] initGame];
        _board.delegate = self;
        CGFloat scale = _board.gameImg.scale;
        _board.frame = CGRectMake((self.view.frame.size.width - _board.gameImg.size.width) / scale,
                                  (self.view.frame.size.height - _board.gameImg.size.height) / scale,
                                  _board.gameImg.size.width,
                                  _board.gameImg.size.height);
        [self.view addSubview:_board];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (JAWTile *tile in self.board.tiles) {
        [self addGestures:tile];
    }
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)addGestures:(JAWTile *)tile {
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    tapRecognizer.delegate = self;
    [tile addGestureRecognizer:tapRecognizer];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    panRecognizer.delegate = self;
    [tile addGestureRecognizer:panRecognizer];
    
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return false;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        JAWTile *pannedTile = (JAWTile *)gestureRecognizer.view;
        UIPanGestureRecognizer *panGR = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint velocity = [panGR velocityInView:self.board];
        self.movingDirection = -1;
        self.tilesToMove = nil;
        if (velocity.y > 0) {
            if ([self.board canMoveTile:pannedTile direction:DOWN]) {
                self.tilesToMove = [self.board tilesToMoveFromTile:pannedTile inDirection:DOWN];
                self.movingDirection = 1;
                return true;
            }
        } else if (velocity.y < 0) {
            if ([self.board canMoveTile:pannedTile direction:UP]) {
                self.tilesToMove = [self.board tilesToMoveFromTile:pannedTile inDirection:UP];
                
                self.movingDirection = 0;
                return true;
            }
        }
        else if (velocity.x > 0 ) {
            if ([self.board canMoveTile:pannedTile direction:RIGHT]) {
                self.tilesToMove = [self.board tilesToMoveFromTile:pannedTile inDirection:RIGHT];
                
                self.movingDirection = 3;
                return true;
            }
        } else if (velocity.x < 0) {
            if ([self.board canMoveTile:pannedTile direction:LEFT]) {
                self.tilesToMove = [self.board tilesToMoveFromTile:pannedTile inDirection:LEFT];
                
                self.movingDirection = 2;
                return true;
            }
        }
        return false;
        
    }
    
    return true;
}

#pragma mark - UIGestureRecognizer selector methods

-(void) tapped:(UITapGestureRecognizer *)sender {
    JAWTile *tappedTile = (JAWTile *)sender.view;
    for (int i = 0; i < 4; i++) {
        if ([self.board canMoveTile:tappedTile direction:i]) {
            [UIView animateWithDuration:0.3
                                  delay:0
                                options: UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 [self.board moveTiles:[self.board tilesToMoveFromTile:tappedTile inDirection:i] inDirection:i];
                             } completion:^(BOOL finished) {
                                 
                             }];
            break;
        }
    }
}

-(void)panned:(UIPanGestureRecognizer *)sender {
    JAWTile *pannedTile = (JAWTile *)sender.view;
    CGPoint translation;
    
    CGPoint originalCenter = [self.board centerForTile:pannedTile];
    
    if (sender.state == UIGestureRecognizerStateChanged ) {
        translation = [sender translationInView:self.board];
        CGPoint currentCenter = CGPointMake(pannedTile.frame.origin.x + pannedTile.frame.size.height /2, pannedTile.frame.origin.y + pannedTile.frame.size.width / 2);
        switch (self.movingDirection) {
            case UP: {
                if (currentCenter.y <= originalCenter.y && currentCenter.y > originalCenter.y-pannedTile.frame.size.height) {
                    for (JAWTile *tile in self.tilesToMove) {
                        tile.center = CGPointMake(tile.center.x, tile.center.y + translation.y);
                    }
                }
                break;
            }
            case DOWN: {
                if (currentCenter.y >= originalCenter.y && currentCenter.y < originalCenter.y+pannedTile.frame.size.height) {
                    for (JAWTile *tile in self.tilesToMove) {
                        tile.center = CGPointMake(tile.center.x, tile.center.y + translation.y);
                    }
                }
                break;
            }
            case LEFT: {
                if (currentCenter.x <= originalCenter.x && currentCenter.x > originalCenter.x - pannedTile.frame.size.width) {
                    for (JAWTile *tile in self.tilesToMove) {
                        tile.center = CGPointMake(tile.center.x + translation.x, tile.center.y);
                    }
                }
                break;
            }
            case RIGHT: {
                if (currentCenter.x >= originalCenter.x && currentCenter.x < originalCenter.x+pannedTile.frame.size.width) {
                    for (JAWTile *tile in self.tilesToMove) {
                        tile.center = CGPointMake(tile.center.x + translation.x, tile.center.y);
                    }
                }
                break;
            }
            default:
                break;
        }
        [sender setTranslation:CGPointMake(0, 0) inView:self.board];
        
    }
    else if (sender.state == UIGestureRecognizerStateEnded) {
        
        [UIView animateWithDuration:0.3
                              delay:0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             if (self.movingDirection < 2) {
                                 if (abs(pannedTile.center.y - originalCenter.y) > pannedTile.frame.size.height / 2) {
                                     [self.board moveTiles:self.tilesToMove inDirection:self.movingDirection];
                                 } else {
                                     
                                     for (JAWTile *tile in self.tilesToMove) {
                                         CGPoint originalOrigin = CGPointMake(tile.currentPosition.section * tile.frame.size.width, tile.currentPosition.row * tile.frame.size.height);
                                         tile.frame = CGRectMake(originalOrigin.x , originalOrigin.y, tile.frame.size.width, tile.frame.size.height);
                                     }
                                     
                                     
                                 }
                             } else {
                                 if (abs(pannedTile.center.x - originalCenter.x) > pannedTile.frame.size.width / 2) {
                                     [self.board moveTiles:self.tilesToMove inDirection:self.movingDirection];
                                 } else {
                                     
                                     for (JAWTile *tile in self.tilesToMove) {
                                         CGPoint originalOrigin = CGPointMake(tile.currentPosition.section * tile.frame.size.width, tile.currentPosition.row * tile.frame.size.height);
                                         tile.frame = CGRectMake(originalOrigin.x , originalOrigin.y, tile.frame.size.width, tile.frame.size.height);
                                     }
                                 }
                             }
                         } completion:nil];
    }
    
}

#pragma mark - JAWGameBoardProtocol delegate methods

/*
 * A little bit of fun UIDynamics when the game is over
 */

-(void)didWin {
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:self.board.tiles];
    [self.animator addBehavior:gravity];
    
    int y = 0;
    for (JAWTile *tile in self.board.tiles) {
        y++;
        UIAttachmentBehavior *hinge = [[UIAttachmentBehavior alloc] initWithItem:tile offsetFromCenter:UIOffsetMake(-tile.frame.size.width / 2, -tile.frame.size.height / 2) attachedToAnchor:tile.frame.origin];
        hinge.damping = 1 / y;
        [self.animator addBehavior:hinge];
        
        double delayInSeconds = y * 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            [self.animator removeBehavior:hinge];
        });
    }
    
    UILabel *winLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 200) / 2, (self.view.frame.size.height - 100) / 2, 200, 50)];
    winLabel.text = @"YOU WIN";
    winLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:winLabel];
}


@end
