//
//  GameScene.m
//  3-pongGame
//
//  Created by 浩一 何 on 2016/11/27.
//  Copyright (c) 2016年 me. All rights reserved.
//

#import "GameStart.h"
#import "GameScene.h"
#import "GameOver.h"

static const CGFloat kTrackPointPerSecond = 1000;

//create category
static const uint32_t category_fence  = 0x1 << 3; // 0x00000000000000000000000000001000
static const uint32_t category_paddle = 0x1 << 2; // 0x00000000000000000000000000000100
static const uint32_t category_block  = 0x1 << 1; // 0x00000000000000000000000000000010
static const uint32_t category_ball   = 0x1 << 0; // 0x00000000000000000000000000000001


@interface GameScene () <SKPhysicsContactDelegate>

@property (strong,nonatomic,nullable) UITouch *motivatingTouch;
@property (strong,nonatomic) NSMutableArray *blockFrames;

@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    
    self.physicsWorld.contactDelegate = self; //answer SKPhysicsContactDelegate
    
    //建立邊框
    self.name = @"Fence";
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask = category_fence;
    self.physicsBody.collisionBitMask = 0x0; //當0x0和fence碰撞才通知
    self.physicsBody.contactTestBitMask = 0x0;  //當0x0和fence接觸才通知
    
    //建立背景
    SKSpriteNode *background = (SKSpriteNode *)[self childNodeWithName:@"Background"];
    background.lightingBitMask = 0x1;
    
    //建立光模型
    SKLightNode *light = [SKLightNode new];
    light.categoryBitMask = 0x1;//所有lightingBitMask為0x1的都會被影響到
    light.falloff = 1;//light power
    light.ambientColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    light.lightColor = [UIColor colorWithRed:0.7 green:0.7 blue:1.0 alpha:1.0];
    light.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    light.zPosition = 1;
    
    
    SKSpriteNode *ball1 = [SKSpriteNode spriteNodeWithImageNamed:@"ball.png"];
    ball1.name = @"Ball1";
    ball1.zPosition = 1; //圖層的layer，如果不assign的話系統會隨機assign，可能會發生圖片被背景擋住
    ball1.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball1.size.width/2];
    ball1.physicsBody.dynamic = YES;
    ball1.position = CGPointMake(60,30);
    ball1.physicsBody.friction = 0.0;
    ball1.physicsBody.restitution = 1.0;
    ball1.physicsBody.linearDamping = 0.0;
    ball1.physicsBody.angularDamping = 0.0;
    ball1.physicsBody.allowsRotation = NO;
    ball1.physicsBody.mass = 1.0;
    ball1.physicsBody.velocity = CGVectorMake(200.0,200.0);
    ball1.physicsBody.affectedByGravity = NO;
    ball1.physicsBody.categoryBitMask = category_ball;
    ball1.physicsBody.collisionBitMask = category_ball | category_paddle | category_block | category_fence;
    ball1.physicsBody.contactTestBitMask = category_fence | category_block;
    ball1.physicsBody.usesPreciseCollisionDetection = YES; //畫面會比較靈敏，不會有兩顆球重疊在一起的畫面出現
    [self addChild:ball1];
    [ball1 addChild:light];//這個lightting是ball1的child，因此會跟著ball1移動
    
    
    SKSpriteNode *ball2 = [SKSpriteNode spriteNodeWithImageNamed:@"ball.png"];
    ball2.name = @"Ball2";
    ball2.zPosition = 1;
    ball2.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball2.size.width/2];
    ball2.physicsBody.dynamic = YES;
    ball2.position = CGPointMake(60,75);
    ball2.physicsBody.friction = 0.0;
    ball2.physicsBody.restitution = 1.0;
    ball2.physicsBody.linearDamping = 0.0;
    ball2.physicsBody.angularDamping = 0.0;
    ball2.physicsBody.allowsRotation = NO;
    ball2.physicsBody.mass = 1.0;
    ball2.physicsBody.velocity = CGVectorMake(0.0,0.0);
    ball2.physicsBody.affectedByGravity = NO;
    ball2.physicsBody.categoryBitMask = category_ball;
    ball2.physicsBody.collisionBitMask = category_ball | category_paddle | category_block | category_fence;
    ball2.physicsBody.contactTestBitMask = category_fence | category_block;
    ball2.physicsBody.usesPreciseCollisionDetection = YES;
    [self addChild:ball2];
    
    
    
    SKSpriteNode *paddle = [SKSpriteNode spriteNodeWithImageNamed:@"paddle.png"];
    paddle.name = @"Paddle";
    paddle.zPosition = 1;
    paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(paddle.size.width, paddle.size.height)];
    paddle.physicsBody.dynamic = NO; //not react when interact with other object
    paddle.position = CGPointMake(self.size.width/2,50);
    paddle.physicsBody.friction = 0.0;
    paddle.physicsBody.restitution = 1.0;
    paddle.physicsBody.linearDamping = 0.0;
    paddle.physicsBody.angularDamping = 0.0;
    paddle.physicsBody.allowsRotation = NO;
    paddle.physicsBody.mass = 1.0;
    paddle.physicsBody.velocity = CGVectorMake(0.0,0.0);
    paddle.physicsBody.categoryBitMask = category_paddle;
    paddle.physicsBody.collisionBitMask = 0x0;
    paddle.physicsBody.contactTestBitMask = category_ball;
    paddle.physicsBody.usesPreciseCollisionDetection = YES;
    paddle.lightingBitMask = 0x1;
    [self addChild:paddle];
    
    //將ball1和ball2連結
    CGPoint ball1Anchor = CGPointMake(ball1.position.x, ball1.position.y);
    CGPoint ball2Anchor = CGPointMake(ball2.position.x, ball2.position.y);
    SKPhysicsJointSpring *joint = [SKPhysicsJointSpring jointWithBodyA:ball1.physicsBody bodyB:ball2.physicsBody anchorA:ball1Anchor anchorB:ball2Anchor];
    joint.damping = 0.0;
    joint.frequency = 1.5;
    [self.scene.physicsWorld addJoint:joint];
    
    
    
    // create block frames
    self.blockFrames = [NSMutableArray array];
    SKTextureAtlas *blockAnimation = [SKTextureAtlas atlasNamed:@"block.atlas"];
    unsigned long imageNum = blockAnimation.textureNames.count;
    for ( int i = 1; i < imageNum+1; i++){
        NSString *textureName = [NSString stringWithFormat:@"block%02d",i];
        SKTexture *temp = [blockAnimation textureNamed:textureName];
        [self.blockFrames addObject:temp];
    }
    
    
    
    //Add Blocks to GameScene
//    SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:@"block.png"];
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithTexture:self.blockFrames[0]];
    node.scale = 0.1;
    
    CGFloat kBlockWidth = node.size.width;
    CGFloat kBlockHeight = node.size.height;
    CGFloat kBlockHorizSpace = 20.0f;
    
    int kBlocksPerRow = self.size.width/(kBlockWidth+kBlockHorizSpace);
    
    for (int j =0 ; j <5 ; j++) {
        for (int i =0 ; i < kBlocksPerRow ; i++){
//            node = [SKSpriteNode spriteNodeWithImageNamed:@"block"];
            SKSpriteNode *node = [SKSpriteNode spriteNodeWithTexture:self.blockFrames[0]];
            node.scale = 0.1;
            node.name = @"Block";
            node.zPosition = 1;
            node.position = CGPointMake(kBlockWidth/2+kBlockHorizSpace/2+i*kBlockWidth+i*kBlockHorizSpace, self.size.height-80.0-j*1.5*kBlockHeight);
            node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:node.size center:CGPointMake(0, 0)];
            node.physicsBody.dynamic = NO;
            node.physicsBody.friction = 0.0;
            node.physicsBody.restitution = 1.0;
            node.physicsBody.linearDamping = 0.0;
            node.physicsBody.angularDamping = 0.0;
            node.physicsBody.allowsRotation = NO;
            node.physicsBody.mass = 1.0;
            node.physicsBody.velocity = CGVectorMake(0.0,0.0);
            node.physicsBody.categoryBitMask = category_block;
            node.physicsBody.collisionBitMask = 0x0;
            node.physicsBody.contactTestBitMask = category_ball;
            node.physicsBody.usesPreciseCollisionDetection = NO;
            node.lightingBitMask = 0x1;
            [self addChild:node];
            
        }
    }
    
    
    
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    const CGRect touchRegion = CGRectMake(0, 0, self.size.width, self.size.height*0.3);
    for (UITouch *touch in touches){
        CGPoint p = [touch locationInNode:self];
        if(CGRectContainsPoint(touchRegion, p)){
            self.motivatingTouch = touch;//motivatingTouch會一直追蹤這個touch，因為是指定位址進來
        }
    }
    
    [self trackPaddlesToMotivatingTouches];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self trackPaddlesToMotivatingTouches];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if([touches containsObject:self.motivatingTouch]){
        self.motivatingTouch = nil;
    }
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if([touches containsObject:self.motivatingTouch]){
        self.motivatingTouch = nil;
    }
}

-(void)trackPaddlesToMotivatingTouches{
    SKNode *node = [self childNodeWithName:@"Paddle"];//從self這個scene內找childNode
    
    UITouch *touch = self.motivatingTouch;
    if(!touch){
        return;
    }
    
    CGFloat xPos = [touch locationInNode:self].x;
    NSTimeInterval duration = ABS(xPos - node.position.x)/kTrackPointPerSecond;
    [node runAction:[SKAction moveToX:xPos duration:duration]];
}

/* Called before each frame is rendered */
-(void)update:(CFTimeInterval)currentTime {
    
    
    /* adjust ball speed */
    static const int kMaxSpeed = 650;
    static const int kMinSpeed = 550;
    
    SKNode *ball1 = [self childNodeWithName:@"Ball1"];
    SKNode *ball2 = [self childNodeWithName:@"Ball2"];
    
    float ball1Speed = sqrt(ball1.physicsBody.velocity.dx*ball1.physicsBody.velocity.dx+ball1.physicsBody.velocity.dy*ball1.physicsBody.velocity.dy);
    float dx = (ball1.physicsBody.velocity.dx+ball2.physicsBody.velocity.dx)/2;
    float dy = (ball1.physicsBody.velocity.dy+ball2.physicsBody.velocity.dy)/2;
    float speed = sqrt(dx*dx+dy*dy);
    
    if (ball1Speed > kMaxSpeed || speed > kMaxSpeed){
        ball1.physicsBody.linearDamping += 0.1f;
        ball2.physicsBody.linearDamping += 0.1f;
    } else if (ball1Speed < kMinSpeed || speed > kMinSpeed){
        ball1.physicsBody.linearDamping -= 0.03f;
        ball2.physicsBody.linearDamping -= 0.03f;
    } else {
        ball1.physicsBody.linearDamping = 0.0f;
        ball2.physicsBody.linearDamping = 0.0f;
    }
    
}




-(void)didBeginContact:(SKPhysicsContact *)contact{
    
    NSString *nameA = contact.bodyA.node.name;
    NSString *nameB = contact.bodyB.node.name;
    
    if(([nameA containsString:@"Ball"] && [nameB containsString:@"Fence"]) || ([nameA containsString:@"Fence" ] && [nameB containsString:@"Ball"])){
        
        // Lose condition
        if(contact.contactPoint.y < 10){
            SKView *skView = (SKView *)self.view;
            [self removeFromParent];
            
            GameOver *scene = [GameOver nodeWithFileNamed:@"GameOver"];
            scene.scaleMode = SKSceneScaleModeAspectFit;
            [skView presentScene:scene];
        }
        
        SKAction *fenceAudio = [SKAction playSoundFileNamed:@"ballHitFence" waitForCompletion:NO];
        [self runAction:fenceAudio];
    }
    
    else if (([nameA containsString:@"Ball"] && [nameB containsString:@"Paddle"]) || ([nameA containsString:@"Paddle" ] && [nameB containsString:@"Ball"])){
        
        SKAction *paddleAudio = [SKAction playSoundFileNamed:@"ballHitPaddle" waitForCompletion:NO];
        [self runAction:paddleAudio];
    }
    
    else if (([nameA containsString:@"Ball"] && [nameB containsString:@"Block"]) || ([nameA containsString:@"Block" ] && [nameB containsString:@"Ball"])){
        
        SKNode *block;
        if([nameA containsString:@"Block"]){
            block = contact.bodyA.node;
        } else {
            block = contact.bodyB.node;
        }
        
        
        //ball hit block
        
        // 1. block broken
        SKAction *audioBlock = [SKAction playSoundFileNamed:@"ballHitBlocks" waitForCompletion:NO];
        
        SKAction *actionRamp = [SKAction animateWithTextures:self.blockFrames timePerFrame:0.04f resize:NO restore:NO];
        
        NSString *particleRampPath = [[NSBundle mainBundle] pathForResource:@"ramp" ofType:@"sks"];
        SKEmitterNode *particleRamp = [NSKeyedUnarchiver unarchiveObjectWithFile:particleRampPath];
        particleRamp.position = CGPointMake(0, 0);
        particleRamp.zPosition = 0;
        SKAction *actionParticleRamp = [SKAction runBlock:^{
            [block addChild:particleRamp];
        }];
        //group
        SKAction *actionRampSequence = [SKAction group:@[audioBlock,actionRamp,actionParticleRamp]];//一起執行
        
        
        // 2. block explode
        SKAction *audioExplode = [SKAction playSoundFileNamed:@"blockExplode" waitForCompletion:NO];
        
        NSString *particleExplodePath = [[NSBundle mainBundle] pathForResource:@"explode" ofType:@"sks"];
        SKEmitterNode *particleExplode = [NSKeyedUnarchiver unarchiveObjectWithFile:particleExplodePath];
        particleExplode.position = CGPointMake(0, 0);
        particleExplode.zPosition = 2;
        SKAction *actionParticleExplode = [SKAction runBlock:^{
            [block addChild:particleExplode];
        }];
        
        SKAction *actionRemoveBlock = [SKAction removeFromParent];
        //sequence
        SKAction *actionExplodeSequence = [SKAction sequence:@[audioExplode,actionParticleExplode,[SKAction fadeInWithDuration:0.5],actionRemoveBlock]];//照順序執行
        
        // 3. 檢查遊戲是否結束
        SKAction *checkGameOver = [SKAction runBlock:^{
            BOOL blockRemain = ([self childNodeWithName:@"Block"] != nil);
            if(!blockRemain){
                SKView * skView = (SKView *)self.view;
                [self removeFromParent];
                GameStart *scene = [GameStart nodeWithFileNamed:@"GameStart"];
                scene.scaleMode = SKSceneScaleModeAspectFit;
                [skView presentScene:scene];
            }
        }];
        
        [block runAction:[SKAction sequence:@[actionRampSequence,actionExplodeSequence,checkGameOver]]];
        
    }
    
}




@end
