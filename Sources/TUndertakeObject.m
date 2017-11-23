//
//  TUndertakeObject.m
//  TPreventUnrecognizedSEL
//
//  Created by TBD on 2017/11/23.
//  Copyright © 2017年 TBD. All rights reserved.
//

#import "TUndertakeObject.h"

static TUndertakeObject *__instance;

@implementation TUndertakeObject

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    //输入dispatch_once snippet
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [super allocWithZone:zone];
    });
    return __instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [[self.class alloc] init];
    });
    return __instance;
}

@end
