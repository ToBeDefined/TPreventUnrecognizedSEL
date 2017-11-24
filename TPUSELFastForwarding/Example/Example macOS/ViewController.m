//
//  ViewController.m
//  Example macOS
//
//  Created by TBD on 2017/11/24.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self performSelector:@selector(macOS:losted:Instance:Method:inVC:)];
    [[self class] performSelector:@selector(macOS:losted:Class:MethodInVCClass:)];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
