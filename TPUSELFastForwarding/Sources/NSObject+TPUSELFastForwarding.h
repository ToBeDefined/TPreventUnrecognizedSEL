//
//  NSObject+TPUSELFastForwarding.h
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

@interface NSObject (TPUSELFastForwarding)

// Just Forward Class(and Subclass) inside of the forwardClassArray
// forwardClassArray's Element can be `NSString *` or `Class`
+ (void)setJustForwardClassArray:(NSArray *)forwardClassArray
 handleUnrecognizedSELErrorBlock:(HandleUnrecognizedSELErrorBlock)handleBlock;

@end

NS_ASSUME_NONNULL_END
