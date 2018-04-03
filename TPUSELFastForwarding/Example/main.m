//
//  main.m
//  Example
//
//  Created by TBD on 2017/11/24.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TPUSELFastForwarding/TPUSELFastForwarding.h>

@interface TestFastForwardingOBJ: NSObject

@end

@implementation TestFastForwardingOBJ

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"Begin Test Fast Forwarding");
        [NSObject setJustForwardClassArray:@[@"TestFastForwardingOBJ"]
           handleUnrecognizedSELErrorBlock:^(Class  _Nonnull __unsafe_unretained cls, SEL  _Nonnull selector, UnrecognizedMethodType methodType, NSArray<NSString *> * _Nonnull callStackSymbols) {
               NSString *typeStr = @"Lost Class    Method";
               if (methodType == UnrecognizedMethodTypeInstanceMethod) {
                   typeStr = @"Lost Instance Method";
               }
               NSLog(@"CLASS: %@, %@ ==> %@", NSStringFromClass(cls), typeStr, NSStringFromSelector(selector));
               // NSLog(@"%@", callStackSymbols);
           }];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [[[TestFastForwardingOBJ alloc] init] performSelector:@selector(losted:instance:method:)];
        [TestFastForwardingOBJ performSelector:@selector(losted:class:method:)];
#pragma clang diagnostic pop
        
        NSLog(@"Test Fast Forwarding Success");
    }
    return 0;
}
