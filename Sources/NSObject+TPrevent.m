//
//  NSObject+TPrevent.m
//  TPreventUnrecognizedSEL
//
//  Created by TBD on 2017/11/23.
//  Copyright © 2017年 TBD. All rights reserved.
//

#import "NSObject+TPrevent.h"
#import <objc/runtime.h>

#import "TUndertakeObject.h"

void __c_t_resolveLostedMethod(id self, SEL _cmd, ...) {}

@implementation NSObject (TPrevent)

#pragma mark - HandleUnrecognizedSELErrorBlock
+ (void)setHandleUnrecognizedSELErrorBlock:(HandleUnrecognizedSELErrorBlock)handleBlock {
    objc_setAssociatedObject(self, @selector(handleUnrecognizedSELErrorBlock), handleBlock, OBJC_ASSOCIATION_RETAIN);
}

+ (HandleUnrecognizedSELErrorBlock)handleUnrecognizedSELErrorBlock {
    return objc_getAssociatedObject(self, @selector(handleUnrecognizedSELErrorBlock));
}

#pragma mark - FastForwarding

+ (void)load {
    Class metaClass = objc_getMetaClass(class_getName(self));
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(forwardingTargetForSelector:)),
                                   class_getInstanceMethod(self, @selector(__t_forwardingTargetForSelector:)));
    method_exchangeImplementations(class_getInstanceMethod(metaClass, @selector(forwardingTargetForSelector:)),
                                   class_getInstanceMethod(metaClass, @selector(__t_forwardingTargetForSelector:)));
}

- (id)__t_forwardingTargetForSelector:(SEL)aSelector {
    class_addMethod([TUndertakeObject class],
                    aSelector,
                    (IMP)__c_t_resolveLostedMethod,
                    "v@:");
    HandleUnrecognizedSELErrorBlock handleBlock = [NSObject handleUnrecognizedSELErrorBlock];
    if (handleBlock != nil) {
        handleBlock([self class], aSelector, UnrecognizedMethodTypeInstanceMethod);
    }
    return [TUndertakeObject sharedInstance];
}

+ (id)__t_forwardingTargetForSelector:(SEL)aSelector {
    class_addMethod(objc_getMetaClass(class_getName([TUndertakeObject class])),
                    aSelector,
                    (IMP)__c_t_resolveLostedMethod,
                    "v@:");
    HandleUnrecognizedSELErrorBlock handleBlock = [NSObject handleUnrecognizedSELErrorBlock];
    if (handleBlock != nil) {
        handleBlock([self class], aSelector, UnrecognizedMethodTypeClassMethod);
    }
    return [TUndertakeObject class];
}


#pragma mark - ForwardInvocation

//+ (void)load {
//    method_exchangeImplementations(class_getInstanceMethod(self, @selector(methodSignatureForSelector:)),
//                                   class_getInstanceMethod(self, @selector(__t_methodSignatureForSelector:)));
//    method_exchangeImplementations(class_getInstanceMethod(self, @selector(forwardInvocation:)),
//                                   class_getInstanceMethod(self, @selector(__t_forwardInvocation:)));
//    Class metaClass = objc_getMetaClass(class_getName(self));
//    method_exchangeImplementations(class_getInstanceMethod(metaClass, @selector(methodSignatureForSelector:)),
//                                   class_getInstanceMethod(metaClass, @selector(__t_methodSignatureForSelector:)));
//    method_exchangeImplementations(class_getInstanceMethod(metaClass, @selector(forwardInvocation:)),
//                                   class_getInstanceMethod(metaClass, @selector(__t_forwardInvocation:)));
//}
//
//- (NSMethodSignature *)__t_methodSignatureForSelector:(SEL)aSelector {
//    if (![self respondsToSelector:aSelector]) {
//        class_addMethod([self class],
//                        aSelector,
//                        (IMP)__c_t_resolveLostedMethod,
//                        "v@:");
//    }
//    return [self __t_methodSignatureForSelector:aSelector];
//}
//
//- (void)__t_forwardInvocation:(NSInvocation *)anInvocation {
//    SEL selector = [anInvocation selector];
//    if ([self respondsToSelector:selector]) {
//        [anInvocation invokeWithTarget:self];
//    } else {
//        [self __t_forwardInvocation:anInvocation];
//    }
//}
//
//+ (NSMethodSignature *)__t_methodSignatureForSelector:(SEL)aSelector {
//    if (![self respondsToSelector:aSelector]) {
//        class_addMethod(objc_getMetaClass(class_getName(self)),
//                        aSelector,
//                        (IMP)__c_t_resolveLostedMethod,
//                        "v@:");
//    }
//    return [self __t_methodSignatureForSelector:aSelector];
//}
//
//+ (void)__t_forwardInvocation:(NSInvocation *)anInvocation {
//    SEL selector = [anInvocation selector];
//    if ([self respondsToSelector:selector]) {
//        [anInvocation invokeWithTarget:self];
//    } else {
//        [self __t_forwardInvocation:anInvocation];
//    }
//}

@end
