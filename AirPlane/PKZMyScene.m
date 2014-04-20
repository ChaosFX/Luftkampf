//
//  PKZMyScene.m
//  AirPlane
//
//  Created by Dominik Lingnau on 03.04.14.
//  Copyright (c) 2014 Dominik Lingnau. All rights reserved.
//

#import "PKZMyScene.h"
#import "PKZPlane.h"

@implementation PKZMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        // init several sizes used in all scene
        screenRect = [[UIScreen mainScreen] bounds];
        screenHeight = screenRect.size.height;
        screenWidth = screenRect.size.width;
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        _plane = [[PKZPlane alloc] init];
        _plane.scale = 0.4;
        _plane.zPosition = 2;
        _plane.position = CGPointMake(screenWidth / 2, 15 + _plane.size.height / 2);
        [self addChild:_plane];
        
        // adding the background
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"airPlanesBackground"];
        background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:background];
        
        SKAction *wait = [SKAction waitForDuration:1];
        SKAction *callEnemies = [SKAction runBlock:^{
            [self enemiesAndClouds];
        }];
        SKAction *updateEnimies = [SKAction sequence:@[wait, callEnemies]];
        [self runAction:[SKAction repeatActionForever:updateEnimies]];
        
        // load explosion atlas
        SKTextureAtlas *explosionAtlas = [SKTextureAtlas atlasNamed:@"explosion"];
        NSArray *textureNames = [explosionAtlas textureNames];
        _explosionFrames = [NSMutableArray new];
        for (NSString *name in textureNames) {
            SKTexture *texture = [explosionAtlas textureNamed:name];
            [_explosionFrames addObject:texture];
        }
        
        // CoreMotion
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.accelerometerUpdateInterval = 0.2;
        
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                                 withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                     [self outputAccelertionData:accelerometerData.acceleration];
                                                     if (error) {
                                                         NSLog(@"%@", error);
                                                     }
                                                 }];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint location = [_plane position];
    SKSpriteNode *bullet = [SKSpriteNode spriteNodeWithImageNamed:@"B 2"];
    bullet.position = CGPointMake(location.x, location.y + _plane.size.height / 2);
    bullet.zPosition = 1;
    bullet.scale = 0.4;
    bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bullet.size];
    bullet.physicsBody.dynamic = NO;
    bullet.physicsBody.categoryBitMask = bulletCategory;
    bullet.physicsBody.contactTestBitMask = enemyCategory;
    bullet.physicsBody.collisionBitMask = 0;
    
    SKAction *action = [SKAction moveToY:self.frame.size.height + bullet.size.height duration:2];
    SKAction *remove = [SKAction removeFromParent];
    [bullet runAction:[SKAction sequence:@[action, remove]]];
    
    [self addChild:bullet];
}

-(void)update:(CFTimeInterval)currentTime {
    // NSLog(@"one second");
    
    float maxX = screenHeight - _plane.size.height / 2;
    float minX = _plane.size.height / 2;
    
    float maxY = screenWidth - _plane.size.width / 2;
    float minY = _plane.size.width / 2;
    
    float newX = 0;
    float newY = 0;
    
    if (currentMaxAccelX > 0.05) {
        newX = currentMaxAccelX * 10;
        _plane.texture = [SKTexture textureWithImageNamed:@"PLANE 8 R"];
    } else if (currentMaxAccelX < -0.05) {
        newX = currentMaxAccelX * 10;
        _plane.texture = [SKTexture textureWithImageNamed:@"PLANE 8 L"];
    } else {
        newX = currentMaxAccelX * 10;
        _plane.texture = [SKTexture textureWithImageNamed:@"PLANE 8 N"];
    }
    
    newY = 6.0 + currentMaxAccelY * 10;
    newX = MIN(MAX(newX + _plane.position.x, minY), maxY);
    newY = MIN(MAX(newY + _plane.position.y, minX), maxX);
    
    _plane.position = CGPointMake(newX, newY);
}

- (void)enemiesAndClouds
{
    int goOrNot = [self getRandomNumberBetween:0 to:1];
    
    if (goOrNot) {
        
        SKSpriteNode *enemy;
        
        int randomEnemy = [self getRandomNumberBetween:0 to:1];
        if (randomEnemy) {
            enemy = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE 1 N"];
        } else {
            enemy = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE 2 N"];
        }
        
        enemy.scale = 0.3;
        enemy.position = CGPointMake(screenWidth / 2, screenHeight / 2);
        enemy.zPosition = 1;
        enemy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:enemy.size];
        enemy.physicsBody.dynamic = YES;
        enemy.physicsBody.categoryBitMask = enemyCategory;
        enemy.physicsBody.contactTestBitMask = bulletCategory | playerCategory;
        enemy.physicsBody.collisionBitMask = 0;
        
        CGMutablePathRef cgPath = CGPathCreateMutable();
        
        // random values
        float xStart = [self getRandomNumberBetween:0 to:screenWidth];
        float xEnd = [self getRandomNumberBetween:0 + enemy.size.width to:screenWidth - enemy.size.width];
        
        //ControlPoint1
        float controlPoint1X = [self getRandomNumberBetween:0+enemy.size.width to:screenRect.size.width-enemy.size.width ];
        float controlPoint1Y = [self getRandomNumberBetween:0+enemy.size.width to:screenRect.size.width-enemy.size.height ];
        
        //ControlPoint2
        float controlPoint2X = [self getRandomNumberBetween:0+enemy.size.width to:screenRect.size.width-enemy.size.width ];
        float controlPoint2Y = [self getRandomNumberBetween:0 to:controlPoint1Y];
        
        CGPoint s = CGPointMake(xStart, 600);
        CGPoint e = CGPointMake(xEnd, -100);
        CGPoint controlPoint1 = CGPointMake(controlPoint1X, controlPoint1Y);
        CGPoint controlPoint2 = CGPointMake(controlPoint2X, controlPoint2Y);
        CGPathMoveToPoint(cgPath, NULL, s.x, s.y);
        CGPathAddCurveToPoint(cgPath, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, e.x, e.y);
        
        SKAction *planeDestroy = [SKAction followPath:cgPath asOffset:NO orientToPath:YES duration:5];
        [self addChild:enemy];
        SKAction *remove = [SKAction removeFromParent];
        [enemy runAction:[SKAction sequence:@[planeDestroy, remove]]];
        
        CGPathRelease(cgPath);
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody;
    SKPhysicsBody *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & bulletCategory) != 0) {
        SKNode *projectile = (contact.bodyA.categoryBitMask & bulletCategory) ? contact.bodyA.node : contact.bodyB.node;
        SKNode *enemy = (contact.bodyA.categoryBitMask & bulletCategory) ? contact.bodyB.node : contact.bodyA.node;
        
        SKSpriteNode *explosion = [SKSpriteNode spriteNodeWithTexture:[_explosionFrames objectAtIndex:0]];
        explosion.position = contact.bodyA.node.position;
        explosion.zPosition = 2;
        explosion.scale = 0.4;
        [self addChild:explosion];
        
        SKAction *explosionAction = [SKAction animateWithTextures:_explosionFrames timePerFrame:0.08 resize:YES restore:NO];
        SKAction *remove = [SKAction removeFromParent];
        [explosion runAction:[SKAction sequence:@[explosionAction, remove]]];
        
        [projectile runAction:[SKAction removeFromParent]];
        [enemy runAction:[SKAction removeFromParent]];
    }
}

- (void)outputAccelertionData:(CMAcceleration)acceleration
{
    currentMaxAccelX = 0;
    currentMaxAccelY = 0;
    
    if (fabs(acceleration.x) > fabs(currentMaxAccelX)) {
        currentMaxAccelX = acceleration.x;
    }
    if (fabs(acceleration.y) > fabs(currentMaxAccelY)) {
        currentMaxAccelY = acceleration.y;
    }
}

- (int)getRandomNumberBetween:(int)from to:(int)to
{
    return (int)from + arc4random() % (to - from + 1);
}

@end
