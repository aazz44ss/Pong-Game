//
//  GameStart.m
//  3-pongGame
//
//  Created by 浩一 何 on 2016/11/27.
//  Copyright © 2016年 me. All rights reserved.
//

#import "GameStart.h"
#import "GameScene.h"

@implementation GameStart


-(void)didMoveToView:(SKView *)view{
    NSLog(@"GameStart");
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    
    if(touches){
        SKView * skView = (SKView *)self.view;
        [self removeFromParent];
        GameScene *scene = [GameScene nodeWithFileNamed:@"GameScene"];
        scene.scaleMode = SKSceneScaleModeAspectFit;
        [skView presentScene:scene];
    }
    
    

}


@end
