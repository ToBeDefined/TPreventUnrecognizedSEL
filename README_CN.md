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

[English Document](README.md)
[使用方法以及原理](http://tbd.ink/2017/11/25/iOS/170112501.TPreventUnrecognizedSEL%E4%BD%BF%E7%94%A8%E6%96%B9%E6%B3%95%E4%BB%A5%E5%8F%8A%E5%AE%9E%E7%8E%B0%E5%8E%9F%E7%90%86/index/)

</div>

### 特点

- 使用runtime动态添加方法防止产生`Unrecognized Selector`错误，可以防止因为对象方法和类方法缺失所产生的APP崩溃。
- 可以获取缺失方法的具体信息，包括：
    - 缺失类方法或对象方法的类名；
    - 所缺失的方法名；
    - 缺失的是对象方法还是类方法。

### 如何导入

#### 源文件

源文件中包含两个模块目录： `TPUSELFastForwarding` 和 `TPUSELNormalForwarding`；将对应模块目录中的`Sources`文件夹内部的所有文件拖入项目中即可
**注意：你只可以使用其中一个模块进行使用，将对应模块目录中的Sources文件内部的所有文件拖入项目中即可**

#### CocoaPods

[`CocoaPods`](https://cocoapods.org/)是一个Cocoa项目管理器。你可以使用以下命令去安装`CocoaPods`:

```bash
$ gem install cocoapods
```

要使用CocoaPods将`TPreventUnrecognizedSEL`集成到您的Xcode项目中，请在`Podfile`中加入：

```ruby
pod 'TPreventUnrecognizedSEL/FastForwarding'
```

或者加入

```ruby
pod 'TPreventUnrecognizedSEL/NormalForwarding'
```

然后运行一下命令:

```bash
$ pod install
```

**注意：你只可以使用其中一个subspec，`NormalForwarding`和`FastForwarding`二者只能选其一** 
**使用`pod 'TPreventUnrecognizedSEL`默认是`pod'TPreventUnrecognizedSEL/FastForwarding`**

#### Carthage


[`Carthage`](https://github.com/Carthage/Carthage)是一个去中心化的依赖管理器，它构建并提供所使用的库的framework。

你可以使用 [`Homebrew`](https://brew.sh/)并运行下面的命令安装Carthage

```bash
$ brew update
$ brew install carthage
```

要将`TPreventUnrecognizedSEL`集成到使用Carthage的Xcode项目中，请在`Cartfile`中加入：

```ruby
github "tobedefined/TPreventUnrecognizedSEL"
```

运行`carthage update`构建framework，并将编译的对应平台的`TPUSELFastForwarding.framework`或者`TPUSELNormalForwarding.framework`拖入Xcode项目中。

**注意：你只可以使用其中一个framework，`TPUSELFastForwarding.framework`和`TPUSELNormalForwarding.framework`二者选一**

### 使用方法

#### 简单使用

导入项目之后不用处理任何操作即可生效

#### 运行错误信息获取

##### 导入头文件

|   模块和语言 \ 导入模块方式        |               源文件               |                            CocoaPods                             |                            Carthage                             |
| :----------------------------: | :--------------------------------: | :--------------------------------------------------------------: | :-------------------------------------------------------------: |
|  TPUSELFastForwarding & ObjC   |  #import "TPUSELFastForwarding.h"  |  #import &lt;TPreventUnrecognizedSEL/TPUSELFastForwarding.h&gt;  |   #import &lt;TPUSELFastForwarding/TPUSELFastForwarding.h&gt;   |
|  TPUSELFastForwarding & Swift  |      add ⤴ in Bridging-Header     |                  import TPreventUnrecognizedSEL                  |                   import TPUSELFastForwarding                   |
| TPUSELNormalForwarding & ObjC  | #import "TPUSELNormalForwarding.h" | #import &lt;TPreventUnrecognizedSEL/TPUSELNormalForwarding.h&gt; | #import &lt;TPUSELNormalForwarding/TPUSELNormalForwarding.h&gt; |
| TPUSELNormalForwarding & Swift |     add ⤴ in Bridging-Header      |                  import TPreventUnrecognizedSEL                  |                  import TPUSELNormalForwarding                  |

##### 设置Block

在APP的 **`main.m`文件的`main()`函数中** 或者 **在APP的`didFinishLaunching`方法中** 加入以下代码可以获得缺失方法的具体信息：

```objc
[NSObject setHandleUnrecognizedSELErrorBlock:^(Class  _Nonnull __unsafe_unretained cls, SEL  _Nonnull selector, UnrecognizedMethodType methodType) {
    // 在这里写你要做的事情
    // 比如上传到服务器或者打印log等
}];
```

```swift
NSObject.setHandleUnrecognizedSELErrorBlock { (cls, selector, methodType) in
    // 在这里写你要做的事情
    // 比如上传到服务器或者打印log等
}
```

关于一些定义：在`NSObject+TPUSELFastForwarding.h`或者`NSObject+TPUSELNormalForwarding.h`中有以下定义和方法

```objc
typedef NS_ENUM(NSUInteger, UnrecognizedMethodType) {
    UnrecognizedMethodTypeClassMethod       = 1,
    UnrecognizedMethodTypeInstanceMethod    = 2,
};

typedef void (^ __nullable HandleUnrecognizedSELErrorBlock)(Class cls, SEL selector, UnrecognizedMethodType methodType);

@interface NSObject (TPUSELFastForwarding) // 或(TPUSELNormalForwarding)

+ (void)setHandleUnrecognizedSELErrorBlock:(HandleUnrecognizedSELErrorBlock)handleBlock;

@end
```

- `cls`: `Class`类型；为缺失方法的类或对象的Class，可使用`NSStringFromClass(cls)`返回类名字符串
- `selector`: `SEL`类型；为所缺失的方法名，可使用`NSStringFromSelector(selector)`返回方法名的字符串
- `methodType`: `UnrecognizedMethodType`类型；为所缺失的方法类型（类方法or对象方法）


