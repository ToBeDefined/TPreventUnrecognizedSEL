//
//  NSObject+TPrevent.h
//  TPreventUnrecognizedSEL
//
//  Created by TBD on 2017/11/23.
//  Copyright © 2017年 TBD. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, UnrecognizedMethodType) {
    UnrecognizedMethodTypeClassMethod       = 1,
    UnrecognizedMethodTypeInstanceMethod    = 2,
};

typedef void (^ __nullable HandleUnrecognizedSELErrorBlock)(Class cls, SEL selector, UnrecognizedMethodType methodType);

@interface NSObject (TPrevent)

+ (void)setHandleUnrecognizedSELErrorBlock:(HandleUnrecognizedSELErrorBlock)handleBlock;

@end

NS_ASSUME_NONNULL_END
