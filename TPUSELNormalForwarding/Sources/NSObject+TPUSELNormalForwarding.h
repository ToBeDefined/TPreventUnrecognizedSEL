//
//  NSObject+TPUSELNormalForwarding.h
//  TPUSELFastForwarding
//
//  Created by 邵伟男 on 2017/11/24.
//  Copyright © 2017年 TBD. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, UnrecognizedMethodType) {
    UnrecognizedMethodTypeClassMethod       = 1,
    UnrecognizedMethodTypeInstanceMethod    = 2,
};

typedef void (^ __nullable HandleUnrecognizedSELErrorBlock)(Class cls,
                                                            SEL selector,
                                                            UnrecognizedMethodType methodType,
                                                            NSArray<NSString *> *callStackSymbols);

@interface NSObject (TPUSELNormalForwarding)

+ (void)setHandleUnrecognizedSELErrorBlock:(HandleUnrecognizedSELErrorBlock)handleBlock;

// Just Forward Class(and Subclass) inside of the forwardClassArray
// forwardClassArray's Element can be `NSString *` or `Class`
+ (void)setJustForwardClassArray:(NSArray *)forwardClassArray;

// ignore NSNull Class and Subclass
+ (void)setIgnoreForwardNSNullClass:(BOOL)ignoreNSNull;

// ignore Class(and Subclass) inside of the ignoreClassArray
// ignoreClassArray's Element can be `NSString *` or `Class`
+ (void)setIgnoreForwardClassArray:(NSArray *)ignoreClassArray;

@end

NS_ASSUME_NONNULL_END
