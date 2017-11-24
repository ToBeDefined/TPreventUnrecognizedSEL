//
//  NSObject+TPUSELNormalForwarding.m
//  TPUSELFastForwarding
//
//  Created by 邵伟男 on 2017/11/24.
//  Copyright © 2017年 TBD. All rights reserved.
//

#import "NSObject+TPUSELNormalForwarding.h"
#import <objc/runtime.h>

void __c_t_resolveLostedMethod(id self, SEL _cmd, ...) {}

@implementation NSObject (TPUSELNormalForwarding)

#pragma mark - HandleUnrecognizedSELErrorBlock

+ (void)setHandleUnrecognizedSELErrorBlock:(HandleUnrecognizedSELErrorBlock)handleBlock {
    objc_setAssociatedObject(self, @selector(handleUnrecognizedSELErrorBlock), handleBlock, OBJC_ASSOCIATION_RETAIN);
}

+ (HandleUnrecognizedSELErrorBlock)handleUnrecognizedSELErrorBlock {
    return objc_getAssociatedObject(self, @selector(handleUnrecognizedSELErrorBlock));
}


#pragma mark - ForwardInvocation

+ (void)load {
    Class metaClass = objc_getMetaClass(class_getName(self));
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(methodSignatureForSelector:)),
                                   class_getInstanceMethod(self, @selector(__t_methodSignatureForSelector:)));
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(forwardInvocation:)),
                                   class_getInstanceMethod(self, @selector(__t_forwardInvocation:)));
    method_exchangeImplementations(class_getInstanceMethod(metaClass, @selector(methodSignatureForSelector:)),
                                   class_getInstanceMethod(metaClass, @selector(__t_methodSignatureForSelector:)));
    method_exchangeImplementations(class_getInstanceMethod(metaClass, @selector(forwardInvocation:)),
                                   class_getInstanceMethod(metaClass, @selector(__t_forwardInvocation:)));
}

- (NSMethodSignature *)__t_methodSignatureForSelector:(SEL)aSelector {
    if (![self respondsToSelector:aSelector]) {
        class_addMethod([self class],
                        aSelector,
                        (IMP)__c_t_resolveLostedMethod,
                        "v@:");
        HandleUnrecognizedSELErrorBlock handleBlock = [NSObject handleUnrecognizedSELErrorBlock];
        if (handleBlock != nil) {
            handleBlock([self class], aSelector, UnrecognizedMethodTypeInstanceMethod);
        }
    }
    return [self __t_methodSignatureForSelector:aSelector];
}

- (void)__t_forwardInvocation:(NSInvocation *)anInvocation {
    SEL selector = [anInvocation selector];
    if ([self respondsToSelector:selector]) {
        [anInvocation invokeWithTarget:self];
    } else {
        [self __t_forwardInvocation:anInvocation];
    }
}

+ (NSMethodSignature *)__t_methodSignatureForSelector:(SEL)aSelector {
    if (![self respondsToSelector:aSelector]) {
        class_addMethod(objc_getMetaClass(class_getName(self)),
                        aSelector,
                        (IMP)__c_t_resolveLostedMethod,
                        "v@:");
        HandleUnrecognizedSELErrorBlock handleBlock = [NSObject handleUnrecognizedSELErrorBlock];
        if (handleBlock != nil) {
            handleBlock([self class], aSelector, UnrecognizedMethodTypeClassMethod);
        }
    }
    return [self __t_methodSignatureForSelector:aSelector];
}

+ (void)__t_forwardInvocation:(NSInvocation *)anInvocation {
    SEL selector = [anInvocation selector];
    if ([self respondsToSelector:selector]) {
        [anInvocation invokeWithTarget:self];
    } else {
        [self __t_forwardInvocation:anInvocation];
    }
}

@end
