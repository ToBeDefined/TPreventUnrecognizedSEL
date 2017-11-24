//
//  main.m
//  Example macOS
//
//  Created by TBD on 2017/11/24.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TPUSELFastForwarding/TPUSELFastForwarding.h>

int main(int argc, const char * argv[]) {
    
    [NSObject setHandleUnrecognizedSELErrorBlock:^(Class  _Nonnull __unsafe_unretained cls, SEL  _Nonnull selector, UnrecognizedMethodType methodType) {
        NSString *typeStr = @"ClassMethod\t";
        if (methodType == UnrecognizedMethodTypeInstanceMethod) {
            typeStr = @"InstanceMethod";
        }
        NSLog(@"%@ \t ==> %@ ==> %@", typeStr, NSStringFromClass(cls), NSStringFromSelector(selector));
    }];
    return NSApplicationMain(argc, argv);
}
