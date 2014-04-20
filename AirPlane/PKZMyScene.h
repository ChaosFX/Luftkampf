//
//  PKZMyScene.h
//  AirPlane
//

//  Copyright (c) 2014 Dominik Lingnau. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <CoreMotion/CoreMotion.h>

@class PKZPlane;

static const int bulletCategory = 1;
static const int enemyCategory = 2;
static const int playerCategory = 4;

@interface PKZMyScene : SKScene <UIAccelerometerDelegate, SKPhysicsContactDelegate>
{
    CGRect screenRect;
    CGFloat screenHeight;
    CGFloat screenWidth;
    double currentMaxAccelX;
    double currentMaxAccelY;    
}

@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) PKZPlane *plane;

@property (strong, nonatomic) NSMutableArray *explosionFrames;

@end
