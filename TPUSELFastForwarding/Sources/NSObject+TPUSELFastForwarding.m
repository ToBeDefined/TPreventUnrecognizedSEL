//
//  NSObject+TPUSELFastForwarding.m
//  TPUSELFastForwarding
//
//  Created by 邵伟男 on 2017/11/24.
//  Copyright © 2017年 TBD. All rights reserved.
//

#import "NSObject+TPUSELFastForwarding.h"
#import <objc/runtime.h>

void __c_t_resolveLostedMethod(id self, SEL _cmd, ...) {}

@implementation NSObject (TPUSELFastForwarding)

#pragma mark - HandleUnrecognizedSELErrorBlock



+ (void)setJustForwardClassArray:(NSArray *)forwardClassArray
 handleUnrecognizedSELErrorBlock:(HandleUnrecognizedSELErrorBlock)handleBlock {
    objc_setAssociatedObject(self,
                             @selector(handleUnrecognizedSELErrorBlock),
                             handleBlock,
                             OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(self,
                             @selector(justForwardClassArray),
                             forwardClassArray,
                             OBJC_ASSOCIATION_RETAIN);
}

+ (HandleUnrecognizedSELErrorBlock)handleUnrecognizedSELErrorBlock {
    return objc_getAssociatedObject(self,
                                    _cmd);
}

+ (NSArray *)justForwardClassArray {
    return (NSArray *)objc_getAssociatedObject(self,
                                               _cmd);
}

+ (BOOL)isCanFowardingFor:(Class)cls {
    // is setting justForwardClassArray, will just forward the class(and subclass) inside of the justForwardClassArray
    for (NSObject *element in [NSObject justForwardClassArray]) {
        Class justForwardCls;
        if ([element isKindOfClass:[NSString class]]) {
            justForwardCls = NSClassFromString((NSString *)element);
        } else {
            justForwardCls = (Class)element;
        }
        if ([cls isSubclassOfClass:justForwardCls]) {
            return YES;
        }
    }
    return NO;
}

+ (Class)getProtectorClass {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class protectorCls = objc_allocateClassPair([NSObject class], "__TProtectorClass", 0);
        objc_registerClassPair(protectorCls);
    });
    Class protectorCls = NSClassFromString(@"__TProtectorClass");
    return protectorCls;
}


+ (instancetype)getProtectorInstance {
    static id __t_protector_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __t_protector_instance = [[[self getProtectorClass] alloc] init];
    });
    return __t_protector_instance;
}

#pragma mark - FastForwarding

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        method_exchangeImplementations(class_getInstanceMethod(self, @selector(forwardingTargetForSelector:)),
                                       class_getInstanceMethod(self, @selector(__t_forwardingTargetForSelector:)));
        method_exchangeImplementations(class_getClassMethod(self, @selector(forwardingTargetForSelector:)),
                                       class_getClassMethod(self, @selector(__t_forwardingTargetForSelector:)));
    });
}

- (id)__t_forwardingTargetForSelector:(SEL)aSelector {
    if ([self respondsToSelector:aSelector]) {
        return [self __t_forwardingTargetForSelector:aSelector];
    }
    
    if ([NSObject isCanFowardingFor:[self class]]) {
        class_addMethod([NSObject getProtectorClass],
                        aSelector,
                        (IMP)__c_t_resolveLostedMethod,
                        "v@:");
        HandleUnrecognizedSELErrorBlock handleBlock = [NSObject handleUnrecognizedSELErrorBlock];
        if (handleBlock != nil) {
            NSArray <NSString *>*callStackSymbols = @[@"The system version is too low."];
            if (@available(iOS 4.0, tvOS 9.0, macOS 10.6, watchOS 2.0, *)) {
                callStackSymbols = [NSThread callStackSymbols];
            }
            handleBlock([self class], aSelector, UnrecognizedMethodTypeInstanceMethod, callStackSymbols);
        }
        
        return [NSObject getProtectorInstance];
    }
    return [self __t_forwardingTargetForSelector:aSelector];
}

+ (id)__t_forwardingTargetForSelector:(SEL)aSelector {
    if ([self respondsToSelector:aSelector]) {
        return [self __t_forwardingTargetForSelector:aSelector];
    }
    
    if ([NSObject isCanFowardingFor:self]) {
        class_addMethod(objc_getMetaClass(class_getName([NSObject getProtectorClass])),
                        aSelector,
                        (IMP)__c_t_resolveLostedMethod,
                        "v@:");
        HandleUnrecognizedSELErrorBlock handleBlock = [NSObject handleUnrecognizedSELErrorBlock];
        if (handleBlock != nil) {
            NSArray <NSString *>*callStackSymbols = @[@"The system version is too low."];
            if (@available(iOS 4.0, tvOS 9.0, macOS 10.6, watchOS 2.0, *)) {
                callStackSymbols = [NSThread callStackSymbols];
            }
            handleBlock([self class], aSelector, UnrecognizedMethodTypeClassMethod, callStackSymbols);
        }
        
        return [NSObject getProtectorClass];
    }
    return [self __t_forwardingTargetForSelector:aSelector];
}

@end
