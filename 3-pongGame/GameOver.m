//
//  GameOver.m
//  3-pongGame
//
//  Created by 浩一 何 on 2016/11/27.
//  Copyright © 2016年 me. All rights reserved.
//

#import "GameOver.h"
#import "GameScene.h"

@implementation GameOver


-(void)didMoveToView:(SKView *)view{
    NSLog(@"GameOver");
}



-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    SKView *skView = (SKView *)self.view;
    [self removeFromParent];
    
    GameScene *scene = [GameScene nodeWithFileNamed:@"GameScene"];
    scene.scaleMode = SKSceneScaleModeAspectFit;
    [skView presentScene:scene];
    
}



@end
