//
//  NSObject+TPUSELNormalForwarding.m
//  TPUSELFastForwarding
//
//  Created by 邵伟男 on 2017/11/24.
//  Copyright © 2017年 TBD. All rights reserved.
//

#import "NSObject+TPUSELNormalForwarding.h"
#import <objc/runtime.h>

@implementation NSObject (TPUSELNormalForwarding)

#pragma mark - HandleUnrecognizedSELErrorBlock

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
        method_exchangeImplementations(class_getInstanceMethod(self, @selector(methodSignatureForSelector:)),
                                       class_getInstanceMethod(self, @selector(__t_methodSignatureForSelector:)));
        method_exchangeImplementations(class_getInstanceMethod(self, @selector(forwardInvocation:)),
                                       class_getInstanceMethod(self, @selector(__t_forwardInvocation:)));
        method_exchangeImplementations(class_getClassMethod(self, @selector(methodSignatureForSelector:)),
                                       class_getClassMethod(self, @selector(__t_methodSignatureForSelector:)));
        method_exchangeImplementations(class_getClassMethod(self, @selector(forwardInvocation:)),
                                       class_getClassMethod(self, @selector(__t_forwardInvocation:)));
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

