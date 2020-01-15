//
//  main.m
//  Example
//
//  Created by TBD on 2017/11/24.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TPUSELNormalForwarding/TPUSELNormalForwarding.h>

@interface TestNormalForwardingOBJ: NSObject
@end

@implementation TestNormalForwardingOBJ
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"Begin Test Fast Forwarding");
        [NSObject setHandleUnrecognizedSELErrorBlock:^(Class  _Nonnull __unsafe_unretained cls, SEL  _Nonnull selector, UnrecognizedMethodType methodType, NSArray<NSString *> * _Nonnull callStackSymbols) {
            NSString *typeStr = @"Lost Class    Method";
            if (methodType == UnrecognizedMethodTypeInstanceMethod) {
                typeStr = @"Lost Instance Method";
            }
            NSLog(@"CLASS: %@, %@ ==> %@", NSStringFromClass(cls), typeStr, NSStringFromSelector(selector));
            NSLog(@"%@", callStackSymbols);
        }];
        
        
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [[[TestNormalForwardingOBJ alloc] init] performSelector:@selector(losted:instance:method:)];
        [TestNormalForwardingOBJ performSelector:@selector(losted:class:method:)];
#pragma clang diagnostic pop
        
        NSLog(@"Test Normal Forwarding Success");
    }
    return 0;
}

