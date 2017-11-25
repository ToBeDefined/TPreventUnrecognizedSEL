//
//  NSObject+TPUSELFastForwarding.m
//  TPUSELFastForwarding
//
//  Created by 邵伟男 on 2017/11/24.
//  Copyright © 2017年 TBD. All rights reserved.
//

#import "NSObject+TPUSELFastForwarding.h"
#import <objc/runtime.h>
#import "TUndertakeObject.h"

void __c_t_resolveLostedMethod(id self, SEL _cmd, ...) {}

@implementation NSObject (TPUSELFastForwarding)

#pragma mark - HandleUnrecognizedSELErrorBlock

+ (void)setHandleUnrecognizedSELErrorBlock:(HandleUnrecognizedSELErrorBlock)handleBlock {
    objc_setAssociatedObject(self, @selector(handleUnrecognizedSELErrorBlock), handleBlock, OBJC_ASSOCIATION_RETAIN);
}

+ (HandleUnrecognizedSELErrorBlock)handleUnrecognizedSELErrorBlock {
    return objc_getAssociatedObject(self, @selector(handleUnrecognizedSELErrorBlock));
}

#pragma mark - FastForwarding

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class metaClass = objc_getMetaClass(class_getName(self));
        method_exchangeImplementations(class_getInstanceMethod(self, @selector(forwardingTargetForSelector:)),
                                       class_getInstanceMethod(self, @selector(__t_forwardingTargetForSelector:)));
        method_exchangeImplementations(class_getInstanceMethod(metaClass, @selector(forwardingTargetForSelector:)),
                                       class_getInstanceMethod(metaClass, @selector(__t_forwardingTargetForSelector:)));
    });
}

- (id)__t_forwardingTargetForSelector:(SEL)aSelector {
    if ([self respondsToSelector:aSelector]) {
        return self;
    }
    
    if (![[TUndertakeObject sharedInstance] respondsToSelector:aSelector]) {
        class_addMethod([TUndertakeObject class],
                        aSelector,
                        (IMP)__c_t_resolveLostedMethod,
                        "v@:");
    }
    
    HandleUnrecognizedSELErrorBlock handleBlock = [NSObject handleUnrecognizedSELErrorBlock];
    if (handleBlock != nil) {
        handleBlock([self class], aSelector, UnrecognizedMethodTypeInstanceMethod);
    }
    
    return [TUndertakeObject sharedInstance];
}

+ (id)__t_forwardingTargetForSelector:(SEL)aSelector {
    if ([self respondsToSelector:aSelector]) {
        return self;
    }
    
    if (![TUndertakeObject respondsToSelector:aSelector]) {
        class_addMethod(objc_getMetaClass(class_getName([TUndertakeObject class])),
                        aSelector,
                        (IMP)__c_t_resolveLostedMethod,
                        "v@:");
    }
    
    HandleUnrecognizedSELErrorBlock handleBlock = [NSObject handleUnrecognizedSELErrorBlock];
    if (handleBlock != nil) {
        handleBlock([self class], aSelector, UnrecognizedMethodTypeClassMethod);
    }
    
    return [TUndertakeObject class];
}

@end
