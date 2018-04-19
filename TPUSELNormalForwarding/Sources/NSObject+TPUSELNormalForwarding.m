//
//  NSObject+TPUSELNormalForwarding.m
//  TPUSELFastForwarding
//
//  Created by 邵伟男 on 2017/11/24.
//  Copyright © 2017年 TBD. All rights reserved.
//

#import "NSObject+TPUSELNormalForwarding.h"
#import <objc/runtime.h>


#pragma mark - Safe Exchange Method
#pragma mark -

static inline
void __tp_normal_forward_exchange_instance_method(Class cls, SEL originalSel, SEL swizzledSel) {
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
void __tp_normal_forward_exchange_class_method(Class cls, SEL originalSel, SEL swizzledSel) {
    __tp_normal_forward_exchange_instance_method(objc_getMetaClass(object_getClassName(cls)),
                                              originalSel,
                                              swizzledSel);
}


#pragma mark - Implementation Replace
#pragma mark -

@implementation NSObject (TPUSELNormalForwarding)

#pragma mark - HandleUnrecognizedSELErrorBlock & Setting

+ (void)setHandleUnrecognizedSELErrorBlock:(HandleUnrecognizedSELErrorBlock)handleBlock {
    objc_setAssociatedObject(self,
                             @selector(handleUnrecognizedSELErrorBlock),
                             handleBlock,
                             OBJC_ASSOCIATION_RETAIN);
}

+ (HandleUnrecognizedSELErrorBlock)handleUnrecognizedSELErrorBlock {
    return objc_getAssociatedObject(self,
                                    _cmd);
}

+ (void)setJustForwardClassArray:(NSArray<NSString *> *)forwardClassArray; {
    objc_setAssociatedObject(self,
                             @selector(justForwardClassArray),
                             forwardClassArray,
                             OBJC_ASSOCIATION_RETAIN);
}

+ (NSArray *)justForwardClassArray {
    return (NSArray<NSString *> *)objc_getAssociatedObject(self,
                                                           _cmd);
}

+ (void)setIgnoreForwardNSNullClass:(BOOL)ignoreNSNull {
    objc_setAssociatedObject(self,
                             @selector(ignoreForwardNSNullClass),
                             [NSNumber numberWithBool:ignoreNSNull],
                             OBJC_ASSOCIATION_RETAIN);
}

+ (BOOL)ignoreForwardNSNullClass {
    return [(NSNumber *)objc_getAssociatedObject(self,
                                                 _cmd)
            boolValue];
}

+ (void)setIgnoreForwardClassArray:(NSArray<NSString *> *)ignoreClassArray {
    objc_setAssociatedObject(self,
                             @selector(ignoreForwardClassArray),
                             ignoreClassArray,
                             OBJC_ASSOCIATION_RETAIN);
}

+ (NSArray *)ignoreForwardClassArray {
    return (NSArray *)objc_getAssociatedObject(self,
                                               _cmd);
}

+ (BOOL)isCanFowardingFor:(Class)cls {
    if ([NSObject ignoreForwardNSNullClass] && [cls isSubclassOfClass:[NSNull class]]) {
        return NO;
    }
    
    for (NSObject *element in [NSObject ignoreForwardClassArray]) {
        Class ignoreCls;
        if ([element isKindOfClass:[NSString class]]) {
            ignoreCls = NSClassFromString((NSString *)element);
        } else {
            ignoreCls = (Class)element;
        }
        if ([cls isSubclassOfClass:ignoreCls]) {
            return NO;
        }
    }
    
    // is setting justForwardClassArray, will just forward the class(and subclass) inside of the justForwardClassArray
    NSArray *justForwardClassArray = [NSObject justForwardClassArray];
    if (justForwardClassArray.count > 0) {
        for (NSObject *element in justForwardClassArray) {
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
    return YES;
}


#pragma mark - ForwardInvocation

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __tp_normal_forward_exchange_instance_method(self,
                                                     @selector(methodSignatureForSelector:),
                                                     @selector(__t_methodSignatureForSelector:));
        __tp_normal_forward_exchange_instance_method(self,
                                                     @selector(forwardInvocation:),
                                                     @selector(__t_forwardInvocation:));
        __tp_normal_forward_exchange_class_method(self,
                                                  @selector(methodSignatureForSelector:),
                                                  @selector(__t_methodSignatureForSelector:));
        __tp_normal_forward_exchange_class_method(self,
                                                  @selector(forwardInvocation:),
                                                  @selector(__t_forwardInvocation:));
    });
}

- (NSMethodSignature *)__t_methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *signature = [self __t_methodSignatureForSelector:aSelector];
    if (signature || [self respondsToSelector:aSelector]) {
        return signature;
    }
    
    if (![NSObject isCanFowardingFor:[self class]]) {
        return signature;
    }
    
    HandleUnrecognizedSELErrorBlock handleBlock = [NSObject handleUnrecognizedSELErrorBlock];
    if (handleBlock != nil) {
        NSArray <NSString *>*callStackSymbols = @[@"The system version is too low."];
        if (@available(iOS 4.0, tvOS 9.0, macOS 10.6, watchOS 2.0, *)) {
            callStackSymbols = [NSThread callStackSymbols];
        }
        handleBlock([self class], aSelector, UnrecognizedMethodTypeInstanceMethod, callStackSymbols);
    }
    
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

- (void)__t_forwardInvocation:(NSInvocation *)anInvocation {
    if (![NSObject isCanFowardingFor:[self class]]) {
        return [self __t_forwardInvocation:anInvocation];
    }
    
    SEL selector = [anInvocation selector];
    if ([self respondsToSelector:selector]) {
        [anInvocation invokeWithTarget:self];
    }
}

+ (NSMethodSignature *)__t_methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *signature = [self __t_methodSignatureForSelector:aSelector];
    if (signature || [self respondsToSelector:aSelector]) {
        return signature;
    }
    
    if (![NSObject isCanFowardingFor:self]) {
        return signature;
    }
    
    HandleUnrecognizedSELErrorBlock handleBlock = [NSObject handleUnrecognizedSELErrorBlock];
    if (handleBlock != nil) {
        NSArray <NSString *>*callStackSymbols = @[@"The system version is too low."];
        if (@available(iOS 4.0, tvOS 9.0, macOS 10.6, watchOS 2.0, *)) {
            callStackSymbols = [NSThread callStackSymbols];
        }
        handleBlock([self class], aSelector, UnrecognizedMethodTypeClassMethod, callStackSymbols);
    }
    
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

+ (void)__t_forwardInvocation:(NSInvocation *)anInvocation {
    if (![NSObject isCanFowardingFor:self]) {
        return [self __t_forwardInvocation:anInvocation];
    }
    
    SEL selector = [anInvocation selector];
    if ([self respondsToSelector:selector]) {
        [anInvocation invokeWithTarget:self];
    }
}

@end

