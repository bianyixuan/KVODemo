
一、前言

Objective-C 中的键(key)-值(value)观察(KVO)并不是什么新鲜事物，它来源于设计模式中的观察者模式，其基本思想就是：

	一个目标对象管理所有依赖于它的观察者对象，并在它自身的状态改变时主动通知观察者对象。这个主动通知通常是通过调用各观察者对象所提供的接口方法来实现的。观察者模式较完美地将目标对象与观察者对象解耦。
	
在 Objective-C 中有两种使用键值观察的方式：手动或自动，此外还支持注册依赖键（即一个键依赖于其他键，其他键的变化也会作用到该键）。下面将一一讲述这些，并会深入 Objective-C 内部一窥键值观察是如何实现的。

### 二，运用键值观察

#### 1，注册与解除注册

如果我们已经有了包含可供键值观察属性的类，那么就可以通过在该类的对象（被观察对象）上调用名为 NSKeyValueObserverRegistration 的 category 方法将观察者对象与被观察者对象注册与解除注册：

	- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
	- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;
	
这两个方法的定义在 Foundation/NSKeyValueObserving.h 中，NSObject，NSArray，NSSet均实现了以上方法，因此我们不仅可以观察普通对象，还可以观察数组或结合类对象。在该头文件中，我们还可以看到 NSObject 还实现了 NSKeyValueObserverNotification 的 category 方法（更多类似方法，请查看该头文件）：

	- (void)willChangeValueForKey:(NSString *)key;
	- (void)didChangeValueForKey:(NSString *)key;
	
这两个方法在手动实现键值观察时会用到。

值得注意的是：不要忘记解除注册，否则会导致资源泄露。

#### 2，设置属性

将观察者与被观察者注册好之后，就可以对观察者对象的属性进行操作，这些变更操作就会被通知给观察者对象。注意，只有遵循 KVO 方式来设置属性，观察者对象才会获取通知，也就是说遵循使用属性的 setter 方法，或通过 key-path 来设置：

    testModel.age=@"25";
    [testModel setValue:@"25" forKey:@"age"];
	
#### 3，处理变更通知
观察者需要实现名为 NSKeyValueObserving 的 category 方法来处理收到的变更通知：

	- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
	
在这里，change 这个字典保存了变更信息，具体是哪些信息取决于注册时的 NSKeyValueObservingOptions。

####4，下面来看看一个完整的使用示例：
观察者类：

	-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
	{
	    if ([keyPath isEqualToString:@"age"]) {
	        Class cls=(__bridge Class)context;
	        NSString *className=[NSString stringWithCString:object_getClassName(cls) encoding:NSUTF8StringEncoding];
	        NSLog(@"className: %@>>>> , age changed",className);
	        
	        NSLog(@"old age is : %@",[change objectForKey:@"old"]);
	        
	        NSLog(@"new age is : %@",[change objectForKey:@"new"]);
	        
	    }else if ([keyPath isEqualToString:@"information"]){
	        Class cls=(__bridge Class)context;
	        NSString *className=[NSString stringWithCString:object_getClassName(cls) encoding:NSUTF8StringEncoding];
	        NSLog(@"className: %@>>>> , information changed",className);
	        
	        NSLog(@"old information is : %@",[change objectForKey:@"old"]);
	        
	        NSLog(@"new information is : %@",[change objectForKey:@"new"]);
	    }
	    else{
	        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	    }
	}

	
注意：在实现处理变更通知方法 observeValueForKeyPath 时，要将不能处理的 key 转发给 super 的 observeValueForKeyPath 来处理。

使用示例：
	
	    TestModel *testModel=[[TestModel alloc] init];
 
	    [testModel addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:(__bridge void * _Nullable)([testModel class])];
	    
	    testModel.age=@"25";
	//  [testModel setValue:@"25" forKey:@"age"];
	    
		[testModel removeObserver:self forKeyPath:@"age"];
	
在这里 observer 观察 testModel 的 age 属性变化，运行结果如下：
	
	  class: TestModel>>>>, age changed
	
	  old age is 10
	
	  new age is 25
	  
### 三 、键值观察依赖键
有时候一个属性的值依赖于另一对象中的一个或多个属性，如果这些属性中任一属性的值发生变更，被依赖的属性值也应当为其变更进行标记。因此，object 引入了依赖键。

#### 1，观察依赖键
观察依赖键的方式与前面描述的一样，下面先在 Observer 的 observeValueForKeyPath:ofObject:change:context: 中添加处理变更通知的代码：

	-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
	{
	    if ([keyPath isEqualToString:@"age"]) {
	        Class cls=(__bridge Class)context;
	        NSString *className=[NSString stringWithCString:object_getClassName(cls) encoding:NSUTF8StringEncoding];
	        NSLog(@"className: %@>>>> , age changed",className);
	        
	        NSLog(@"old age is : %@",[change objectForKey:@"old"]);
	        
	        NSLog(@"new age is : %@",[change objectForKey:@"new"]);
	        
	    }else if ([keyPath isEqualToString:@"information"]){
	        Class cls=(__bridge Class)context;
	        NSString *className=[NSString stringWithCString:object_getClassName(cls) encoding:NSUTF8StringEncoding];
	        NSLog(@"className: %@>>>> , information changed",className);
	        
	        NSLog(@"old information is : %@",[change objectForKey:@"old"]);
	        
	        NSLog(@"new information is : %@",[change objectForKey:@"new"]);
	    }
	    else{
	        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	    }
	}


#### 2，实现依赖键
在这里，观察的是 TestWrapperModel 类的 information 属性，该属性是依赖于 TestModel 类的 age 和 name 属性

	@interface TestModel : NSObject
	
	@property (nonatomic,copy) NSString *name;
	
	@property (nonatomic,copy) NSString *age;
	
	@end
	
下面来看看 TestWrapperModel 中的依赖键属性是如何实现的。

####TestWrapperModel.h
---
	@class TestModel;
	@interface TestWrapperModel : NSObject
	
	
	@property (nonatomic,strong) TestModel *testModel;
	
	@property (nonatomic,copy) NSString *information;
	
	@end
	
	
####TestWrapper.m
----
	#import "TestWrapperModel.h"
	#import "TestModel.h"
	@implementation TestWrapperModel
	
	-(NSString *)information
	{
	    return [NSString stringWithFormat:@"%@-%@",[self.testModel name],[self.testModel age]];
	}
	
	-(void)setInformation:(NSString *)information
	{
	    NSArray * array = [information componentsSeparatedByString:@"-"];
	    [self.testModel setName:[array objectAtIndex:0]];
	    [self.testModel setAge:[array objectAtIndex:1]];
	}
	
	+(NSSet *)keyPathsForValuesAffectingInformation
	{
	    NSSet *keyPaths=[NSSet setWithObjects:@"testModel.name",@"testModel.age",nil];
	    return keyPaths;
	}
	
	-(void)dealloc
	{
	    self.testModel=nil;
	}
	
	@end

	
首先，要手动实现属性 information 的 setter/getter 方法，在其中使用 TestModel 的属性来完成其 setter 和 getter。

其次，要实现 keyPathsForValuesAffectingInformation  或 keyPathsForValuesAffectingValueForKey: 方法来告诉系统 information 属性依赖于哪些其他属性，这两个方法都返回一个key-path 的集合。在这里要多说几句，如果选择实现 keyPathsForValuesAffectingValueForKey，要先获取 super 返回的结果 set，然后判断 key 是不是目标 key，如果是就将依赖属性的 key-path 结合追加到 super 返回的结果 set 中，否则直接返回 super的结果。
在这里，information 属性依赖于 testModel 的 age 和 name 属性，testModel 的 age/name 属性任一发生变化，information 的观察者都会得到通知。

#### 3，使用示例：

    TestModel *testModel=[[TestModel alloc] init];
    
    TestWrapperModel *testWrapperModel=[[TestWrapperModel alloc] init];
    testWrapperModel.testModel=testModel;
    
    [testWrapperModel addObserver:self forKeyPath:@"information" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:(__bridge void * _Nullable)([testWrapperModel class])];
       
    testModel.name=@"byx";
    testModel.age=@"25";
     
    [testWrapperModel removeObserver:self forKeyPath:@"information"];
输出结果：

	2016-03-29 16:05:33.649 KVODemo[17003:856411] className: TestWrapperModel>>>> , information changed
	2016-03-29 16:05:33.649 KVODemo[17003:856411] old information is : bianyixuan-24
	2016-03-29 16:05:33.649 KVODemo[17003:856411] new information is : byx-24
	2016-03-29 16:05:33.649 KVODemo[17003:856411] className: TestWrapperModel>>>> , information changed
	2016-03-29 16:05:33.650 KVODemo[17003:856411] old information is : byx-24
	2016-03-29 16:05:33.650 KVODemo[17003:856411] new information is : byx-25
	  
###四，键值观察是如何实现的
####1，实现机理
键值观察用处很多，Core Binding 背后的实现就有它的身影，那键值观察背后的实现又如何呢？想一想在上面的自动实现方式中，我们并不需要在被观察对象 Target 中添加额外的代码，就能获得键值观察的功能，这很好很强大，这是怎么做到的呢？答案就是 Objective C 强大的 runtime 动态能力，下面我们一起来窥探下其内部实现过程。

当某个类的对象第一次被观察时，系统就会在运行期动态地创建该类的一个派生类，在这个派生类中重写基类中任何被观察属性的 setter 方法。

派生类在被重写的 setter 方法实现真正的通知机制，就如前面手动实现键值观察那样。这么做是基于设置属性会调用 setter 方法，而通过重写就获得了 KVO 需要的通知机制。当然前提是要通过遵循 KVO 的属性设置方式来变更属性值，如果仅是直接修改属性对应的成员变量，是无法实现 KVO 的。

同时派生类还重写了 class 方法以“欺骗”外部调用者它就是起初的那个类。然后系统将这个对象的 isa 指针指向这个新诞生的派生类，因此这个对象就成为该派生类的对象了，因而在该对象上对 setter 的调用就会调用重写的 setter，从而激活键值通知机制。此外，派生类还重写了 dealloc 方法来释放资源。

### 五，总结
KVO 并不是什么新事物，换汤不换药，它只是观察者模式在 Objective C 中的一种运用，这是 KVO 的指导思想所在。其他语言实现中也有“KVO”，如 WPF 中的 binding。而在 Objective C 中又是通过强大的 runtime 来实现自动键值观察的。至此，对 KVO 的使用以及注意事项，内部实现都介绍完毕，对 KVO 的理解又深入一层了。Objective 中的 KVO 虽然可以用，但却非完美，有兴趣的了解朋友请查看《KVO 的缺陷》 以及改良实现 MAKVONotificationCenter 。

### 六、引用
- 参考：http://blog.csdn.net/kesalin/article/details/8194240