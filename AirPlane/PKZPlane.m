//
//  PKZPlane.m
//  AirPlane
//
//  Created by Dominik Lingnau on 03.04.14.
//  Copyright (c) 2014 Dominik Lingnau. All rights reserved.
//

#import "PKZPlane.h"

@implementation PKZPlane

- (instancetype)init
{
    self = [super initWithImageNamed:@"PLANE 2 N"];
    
    if (self) {
        
        // add a shadow to the plane
        SKSpriteNode *shadow = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE 8 SHADOW"];
        shadow.scale = 0.8;
        shadow.zPosition = 1;
        shadow.position = CGPointMake(30, -self.size.height / 2);
        [self addChild:shadow];
        
        // add the propeller to the plan
        SKSpriteNode *propeller = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE PROPELLER 1"];
        propeller.scale = 0.8;
        propeller.zPosition = 1;
        propeller.position = CGPointMake(0, self.size.height / 2 - 5);
        
        SKTexture *propeller1 = [SKTexture textureWithImageNamed:@"PLANE PROPELLER 1"];
        SKTexture *propeller2 = [SKTexture textureWithImageNamed:@"PLANE PROPELLER 2"];
        
        SKAction *spin = [SKAction animateWithTextures:@[propeller1, propeller2] timePerFrame:0.1];
        SKAction *spinForever = [SKAction repeatActionForever:spin];
        [propeller runAction:spinForever];
        
        [self addChild:propeller];
        
        // add a smoke trail to the plane
        NSString *smokePath = [[NSBundle mainBundle] pathForResource:@"trail" ofType:@"sks"];
        SKEmitterNode *smokeTrail = [NSKeyedUnarchiver unarchiveObjectWithFile:smokePath];
        smokeTrail.position = CGPointMake(0, -130);
        smokeTrail.zPosition = 2;
        [self addChild:smokeTrail];
    }
    
    return self;
}

@end
