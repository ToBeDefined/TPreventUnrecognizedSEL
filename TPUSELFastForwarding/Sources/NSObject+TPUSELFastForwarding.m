//
//  NSObject+TPUSELFastForwarding.m
//  TPUSELFastForwarding
//
//  Created by 邵伟男 on 2017/11/24.
//  Copyright © 2017年 TBD. All rights reserved.
//

#import "NSObject+TPUSELFastForwarding.h"
#import <objc/runtime.h>

#pragma mark - Safe Exchange Method
#pragma mark -

static inline
void __tp_fast_forward_exchange_instance_method(Class cls, SEL originalSel, SEL swizzledSel) {
    Method originalMethod = class_getInstanceMethod(cls, originalSel);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSel);
    
    // 交换实现进行添加函数
    BOOL addOriginSELSuccess = class_addMethod(cls,
                                               originalSel,
                                               method_getImplementation(swizzledMethod),
                                               method_getTypeEncoding(swizzledMethod));
    BOOL addSwizzlSELSuccess = class_addMethod(cls,
                                               swizzledSel,
                                               method_getImplementation(originalMethod),
                                               method_getTypeEncoding(originalMethod));
    // 全都添加成功，返回
    if (addOriginSELSuccess && addSwizzlSELSuccess) {
        return;
    }
    // 全都添加失败，已经添加过了方法，交换
    if (!addOriginSELSuccess && !addSwizzlSELSuccess) {
        method_exchangeImplementations(originalMethod,
                                       swizzledMethod);
        return;
    }
    // addOriginSELSuccess 成功，addSwizzlSELSuccess 失败，replace SwizzlSel
    if (addOriginSELSuccess && !addSwizzlSELSuccess) {
        class_replaceMethod(cls,
                            swizzledSel,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
        return;
    }
    // addSwizzlSELSuccess 成功，addOriginSELSuccess 失败，replace originSEL
    if (!addOriginSELSuccess && addSwizzlSELSuccess) {
        class_replaceMethod(cls,
                            originalSel,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod));
        return;
    }
}

static inline
void __tp_fast_forward_exchange_class_method(Class cls, SEL originalSel, SEL swizzledSel) {
    __tp_fast_forward_exchange_instance_method(objc_getMetaClass(object_getClassName(cls)),
                                               originalSel,
                                               swizzledSel);
}


#pragma mark - Implementation Replace
#pragma mark -

static inline
void __c_t_resolveLostedMethod(id self, SEL _cmd, ...) {}

@implementation NSObject (TPUSELFastForwarding)

#pragma mark - HandleUnrecognizedSELErrorBlock & Setting

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
        __tp_fast_forward_exchange_instance_method(self,
                                                   @selector(forwardingTargetForSelector:),
                                                   @selector(__t_forwardingTargetForSelector:));
        __tp_fast_forward_exchange_class_method(self,
                                                @selector(forwardingTargetForSelector:),
                                                @selector(__t_forwardingTargetForSelector:));
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
