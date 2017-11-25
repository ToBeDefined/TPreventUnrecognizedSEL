<div align="center">

TPreventUnrecognizedSEL
------

</div>

<div align="center">

![platform](https://img.shields.io/badge/Platform-iOS%20%7C%20tvOS%20%7C%20macOS%20%7C%20watchOS-brightgreen.svg)&nbsp;
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)&nbsp;
[![CocoaPods](https://img.shields.io/badge/Cocoapods-compatible-brightgreen.svg?style=flat)](http://cocoapods.org/)&nbsp;
[![Build Status](https://travis-ci.org/tobedefined/TPreventUnrecognizedSEL.svg?branch=master)](https://travis-ci.org/tobedefined/TPreventUnrecognizedSEL)&nbsp;
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/tobedefined/TPreventUnrecognizedSEL/blob/master/LICENSE)

</div>

<div align="center">

[中文文档](README_CN.md)

[Instructions and Principle](http://tbd.ink/2017/11/25/iOS/170112501.TPreventUnrecognizedSEL%E4%BD%BF%E7%94%A8%E6%96%B9%E6%B3%95%E4%BB%A5%E5%8F%8A%E5%AE%9E%E7%8E%B0%E5%8E%9F%E7%90%86/index/)

</div>

### Features

- Using runtime to dynamically add methods to prevent `Unrecognized Selector` errors prevents the app from crashing due to missing object and class methods.
- Can get the specific information of the missing method, including: 
    - The class name of the missing class method or object method; 
    - The name of the missing method; 
    - The missing object method or class method.

### Installation

#### Source File

The source file contains two module directories: `TPUSELFastForwarding` and `TPUSELNormalForwarding`; Drag all the files inside the `Sources` folder in the corresponding module directory into you project.

**Note: you can only use one of the modules to use, the module directory corresponding to all the files inside the Sources file can be dragged into the project.**

#### CocoaPods

[`CocoaPods`](https://cocoapods.org/) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate `TPreventUnrecognizedSEL` into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'TPreventUnrecognizedSEL/FastForwarding'
```

or this:

```ruby
pod 'TPreventUnrecognizedSEL/NormalForwarding'
```

Then, run the following command:

```bash
$ pod install
```

**Note: you can only use one of the subspec, `NormalForwarding` or `FastForwarding`**
**Use `pod 'TPreventUnrecognizedSEL` default is `pod'TPreventUnrecognizedSEL/FastForwarding`**

#### Carthage

[`Carthage`](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [`Homebrew`](https://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate `TPreventUnrecognizedSEL` into your Xcode project using Carthage, specify it in your `Cartfile`:

```ruby
github "tobedefined/TPreventUnrecognizedSEL"
```

Run `carthage update` to build the framework and drag the built `TPUSELFastForwarding.framework` or `TPUSELNormalForwarding.framework` into your Xcode project.

**Note: You can only use one of the two frameworks, `TPUSELFastForwarding.framework` or `TPUSELNormalForwarding.framework`.**

### How to use

#### Simple Use

Import into the project without any action to take effect

#### Get Run error message 

##### Import Header

| Module and lang \ Import module mode |            Source File             |                            CocoaPods                             |                            Carthage                             |
| :----------------------------------: | :--------------------------------: | :--------------------------------------------------------------: | :-------------------------------------------------------------: |
|     TPUSELFastForwarding & ObjC      |  #import "TPUSELFastForwarding.h"  |  #import &lt;TPreventUnrecognizedSEL/TPUSELFastForwarding.h&gt;  |   #import &lt;TPUSELFastForwarding/TPUSELFastForwarding.h&gt;   |
|     TPUSELFastForwarding & Swift     |      add ⤴ in Bridging-Header     |                  import TPreventUnrecognizedSEL                  |                   import TPUSELFastForwarding                   |
|    TPUSELNormalForwarding & ObjC     | #import "TPUSELNormalForwarding.h" | #import &lt;TPreventUnrecognizedSEL/TPUSELNormalForwarding.h&gt; | #import &lt;TPUSELNormalForwarding/TPUSELNormalForwarding.h&gt; |
|    TPUSELNormalForwarding & Swift    |     add ⤴ in Bridging-Header      |                  import TPreventUnrecognizedSEL                  |                  import TPUSELNormalForwarding                  |

##### Set Block

In the  **`main()` function of the APP's `main.m` file**  or  **in the APP's `didFinishLaunching` method**  add the following code to get the specific information about the missing method:
```objc
[NSObject setHandleUnrecognizedSELErrorBlock:^(Class  _Nonnull __unsafe_unretained cls, SEL  _Nonnull selector, UnrecognizedMethodType methodType) {
    // DO SOMETHING
    // like upload to server or print log or others
}];
```

```swift
NSObject.setHandleUnrecognizedSELErrorBlock { (cls, selector, methodType) in
    // DO SOMETHING
    // like upload to server or print log or others
}
```

For some definitions: The following definitions and methods are in `NSObject+TPUSELFastForwarding.h` or `NSObject+TPUSELNormalForwarding.h`

```objc
typedef NS_ENUM(NSUInteger, UnrecognizedMethodType) {
    UnrecognizedMethodTypeClassMethod       = 1,
    UnrecognizedMethodTypeInstanceMethod    = 2,
};

typedef void (^ __nullable HandleUnrecognizedSELErrorBlock)(Class cls, SEL selector, UnrecognizedMethodType methodType);

@interface NSObject (TPUSELFastForwarding) // or (TPUSELNormalForwarding)

+ (void)setHandleUnrecognizedSELErrorBlock:(HandleUnrecognizedSELErrorBlock)handleBlock;

@end
```

- `cls`: `Class` type; the Class of missing instance method or class method, `NSStringFromClass(cls)` can be used to return the NSString for the class name
- `selector`: `SEL` type; the missing method name, `NSStringFromSelector(selector)` can be used to return the NSString for the method name
- `methodType`: `UnrecognizedMethodType` type; for the missing method type (class method or object method)

