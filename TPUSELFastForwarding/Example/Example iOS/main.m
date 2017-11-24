//
//  main.m
//  Example
//
//  Created by 邵伟男 on 2017/11/24.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <TPUSELFastForwarding/TPUSELFastForwarding.h>

int main(int argc, char * argv[]) {
    @autoreleasepool {
        [NSObject setHandleUnrecognizedSELErrorBlock:^(Class  _Nonnull __unsafe_unretained cls, SEL  _Nonnull selector, UnrecognizedMethodType methodType) {
            NSString *typeStr = @"ClassMethod\t";
            if (methodType == UnrecognizedMethodTypeInstanceMethod) {
                typeStr = @"InstanceMethod";
            }
            NSLog(@"%@ \t ==> %@ ==> %@", typeStr, NSStringFromClass(cls), NSStringFromSelector(selector));
        }];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
