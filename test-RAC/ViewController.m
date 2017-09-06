//
//  ViewController.m
//  test-RAC
//
//  Created by lzh on 2016/12/23.
//  Copyright © 2016年 lzh. All rights reserved.
//

#import "ViewController.h"
#import "BViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self test1];
//    [self test2];
//    [self test3];
//    [self test4];
//    [self test5];
//    [self test6];
//    [self test7];
//    [self test8];
    [self test9];
}

// 第1种: RACSignal 信号类
- (void)test1 {
    
    // 1.创建信号 (冷信号)
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // block什么时候调用:当信号被订阅的时候就会调用
        // block作用:在这里面传递数据出去
        
        // 3.发送数据
        [subscriber sendNext:@1];
        return nil;
    }];
    
    // 2.订阅信号 (热信号)
    // x:信号传递出来的数据
    [signal subscribeNext:^(id x) {
        // block什么时候调用:当信号内部,发送数据的时候,就会调用,并且会把值传递给你
        // block作用:在这个block中处理数据
        
        NSLog(@"%@",x);
    }];
    
    /*
     执行流程:
     1.创建信号RACDynamicSignal
     * 1.1 把didSubscribe保存到RACDynamicSignal
     2.订阅信号
     *  2.1 创建订阅者,把nextBlock保存到订阅者里面去
     *  2.2 就会调用信号的didSubscribe
     3.执行didSubscribe
     *  3.1 拿到订阅者发送订阅者
     * [subscriber sendNext:@1]内部就是拿到订阅者的nextBlock
     * 信号被订阅,就会执行创建信号时didSubscribe
     * 订阅者发送信号,就是调用nextBlock
     */
}

// 第2种: RACDisposable 取消订阅或者清理资源
- (void)test2 {
    
    // 只要订阅者一直在,表示需要一直订阅信号,信号不会自动被取消订阅
    // 1.创建信号
    __block id<RACSubscriber> mSubscriber = nil;
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        // 3.发送信号
        [subscriber sendNext:@1];
        
        // 默认subscriber销毁的时候会触发disposableBlock
        mSubscriber = subscriber;
        
        RACDisposable *disposable = [RACDisposable disposableWithBlock:^{
            // 当信号取消订阅的时候就会调用
            NSLog(@"信号被取消订阅");
        }];
        return disposable;
    }];
    
    // 2.订阅信号
    RACDisposable *disposable = [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // 取消订阅(主动取消)
    [disposable dispose];
}

// 第3种：RACSubject 信号提供者
// 信号提供者:既可以充当信号,也可以充当订阅者,发送数据
// 一个信号允许被多次订阅
- (void)test3 {
    
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    // 2.订阅信号
    [subject subscribeNext:^(id x) {
        
        NSLog(@"订阅者一%@",x);
    }];
    
    [subject subscribeNext:^(id x) {
        
        NSLog(@"订阅者二%@",x);
    }];
     // 3.发送信号
    [subject sendNext:@1];
   
    
    
/*
 执行流程:
 1.创建信号
 2.订阅信号
 * 创建订阅者
 * [self subscribe:o]订阅信号,仅仅是把订阅者保存起来.
 3.发送信号
 * 把所有的订阅者遍历出来,一个一个的调用它们nextBlock
 */
}

// 第4种: RACReplaySubject 重复提供信号类(RACSubject的子类)
// 允许先发送信号,在订阅信号
// 重复信号提供者
- (void)test4 {
    
    // 1.创建信号
    RACReplaySubject *subject = [RACReplaySubject subject];
    
    // 2.发送信号
    [subject sendNext:@"123123"];
    [subject sendNext:@"345"];
    [subject sendNext:@"456456"];
    // 1.把值保存到数组
    // 2.遍历所有的订阅者,调用nextBlock
    
    // 3.订阅信号
    [subject subscribeNext:^(id x) {
        NSLog(@"订阅者一%@",x);
    }];
    // 1.遍历所有值,拿到订阅者去发送
    [subject subscribeNext:^(id x) {
        NSLog(@"订阅者二%@",x);
    }];
    
    /*
     执行流程:
     1.创建信号
     2.订阅信号
     * 创建订阅者,保存nextBlock保存
     * 遍历valuesReceived需要发送的所有值,拿到一个一个值,利用订阅者发送数据
     3.发送信号
     * 把发送的值,保存到数组
     * 把所有的订阅者遍历出来,一个一个的调用它们nextBlock
     */
}

// 第5种：RACMulticastConnection
// 用于当一个信号，被多次订阅时，为了保证创建信号时，避免多次调用创建信号中的block，造成副作用，可以使用这个类处理
// 一个信号即使被订阅多次,也只是发送一次请求 RACMulticastConnection:用于信号中请求数据,避免多次请求数据
- (void)test5 {
    
    // 1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSLog(@"发送请求");
        // 3.发送信号
        [subscriber sendNext:@"网络数据"];
        return nil;
    }];
    
    // 2.把信号转换成连接类
    RACMulticastConnection *connect = [signal publish];
    
    // 3.订阅连接类的信号,注意: 一定是订阅连接类的信号,不再是源信号
    [connect.signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    [connect.signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    [connect.signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // 4.连接
    [connect connect];
    
    /*
     执行流程
     1.创建信号
     * 创建RACDynamicSignal,并且把didSubscribe保存
     2.把信号转换成连接类
     * 创建信号提供者RACSubject
     * [self multicast:subject]:设置原始信号的多点传播subject,本质就是把subject设置为原始信号的订阅者
     * 创建RACMulticastConnection,把原始信号保存到_sourceSignal,把subject保存到_signal
     3.保存订阅者
     4.连接 [connect connect]
     * 订阅_sourceSignal,并且设置订阅者为subject
     5.执行didSubscribe
     6.[subject sendNext]遍历所有的订阅者发送信号
     */
}

// 第6种：RACCommand 用于处理事件的类
// RAC中用于处理事件的类，可以把事件如何处理,事件中的数据如何传递，包装到这个类中，它可以很方便的监控事件的执行过程
// 使用场景:
//      监听按钮点击，网络请求
//      RACCommand使用步骤:创建命令 -> 执行命令
//      RACCommand使用注意点:内部不允许传入一个nil的信号
- (void)test6 {
    
    // 1.创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        // signalBlock调用时刻:只要命令一执行就会调用
        // signalBlock作用:处理事件
        NSLog(@"%@",input);
        
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            NSLog(@"didSubscribe");
            // didSubscribe调用时刻:执行命令过程中,就会调用
            // didSubscribe作用:传递数据
            
            // subscriber -> [RACReplaySubject subject]
            // RACReplaySubject:把值保存起来,遍历所有的订阅者发送这个值
            [subscriber sendNext:@1];
            
            return nil;
        }];
    }];
    
    // 2.执行命令
    RACReplaySubject *replaySubject = (RACReplaySubject *)[command execute:@"执行命令"];
    
    // 3.获取命令中产生的数据,订阅信号
    [replaySubject subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    /*
     执行流程:
     // 1.创建命令
     * 把signalBlock保存到命令中
     // 2.执行命令
     * 调用命令signalBlock
     * 创建多点传播连接类, 订阅源信号,并且设置源信号的订阅者为RACReplaySubject
     * 返回源信号的订阅者
     */
}
- (void)test7 {
// RACTuple: 元组类,类似NSArray,用来包装值.
// RACSequence: RAC中的集合类，用于代替NSArray,NSDictionary,可以使用它来快速遍历数组和字典

    // 包装元组
    RACTuple *tuple = [RACTuple tupleWithObjectsFromArray:@[@"1",@1,@3,@5]];
    RACTuple *tuple2 = RACTuplePack(@1, @2, @3);
    
    // 解包元组
    NSString *str = tuple[0];
    NSString *str2 = tuple.first;
    RACTupleUnpack(NSNumber *n1,NSNumber *n2, NSNumber *n3) = tuple2;
    NSLog(@"%@", n1);
    
    NSArray *arr = @[@"123",@1,@3,@5];
    // ----- OC数组转换成RAC集合 -----
    RACSequence *sequence = arr.rac_sequence;
    // 把集合转换成signal
    RACSignal *signal = sequence.signal;
    
    // 订阅集合类的信号,只要订阅这个信号,就会遍历集合中所有元素
    [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // 也可以写到一起
    [arr.rac_sequence.signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // ----- OC字典转换成RAC集合 -----
    NSDictionary *dict = @{@"name":@"xmg",@"age":@18};
    [dict.rac_sequence.signal subscribeNext:^(RACTuple *x) {
        //        id value = x[1];
        //        id key = x[0];
        // 宏的参数,存放需要生成的变量名
        // 宏会自动生成参数里面的变量
        RACTupleUnpack(id key,id value) = x;
        
        NSLog(@"%@ : %@",key,value);
    }];
}


- (void)test8 {
    
    // 第1种：在调用一个方法后发送订阅
    // RAC方法:可以判断下某个方法有没有调用
    // 只要self调用Selector就会产生一个信号
    // rac_signalForSelector:监听某个对象调用某个方法
    [[self rac_signalForSelector:@selector(didReceiveMemoryWarning)] subscribeNext:^(id x) {
        NSLog(@"控制器调用了didReceiveMemoryWarning");
    }];

    // 第2种：代替代理
    [[self rac_signalForSelector:@selector(scrollViewDidScroll:) fromProtocol:@protocol(UIScrollViewDelegate)] subscribeNext:^(id x) {
        // 打印
    }];
    
    // 第3种：代替KVO
    // rac_valuesAndChangesForKeyPath：用于监听某个对象的属性改变
    [[self.button rac_valuesAndChangesForKeyPath:@keypath(self.button, selected) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld observer:self] subscribeNext:^(id x) {
        // 只要监听的属性一改变调用,
        // observer为self, self.button销毁或者self销毁, 信号就会停止监听
        NSLog(@"按钮状态改变了");
    }];
    
    // KVO:第二种,只监听新值的改变
    [[self.button rac_valuesForKeyPath:@keypath(self.button, selected) observer:nil] subscribeNext:^(id x) {
        // observer为nil, self.button销毁, 信号就会停止监听
        NSLog(@"按钮状态改变了2");
    }];

    // 第4种：监听UIControl事件
    // rac_signalForControlEvents：用于监听某个事件
    // 只要按钮产生这个事件,就会产生一个信号
    [[self.button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSLog(@"按钮被点击%@",x);
    }];
    self.button.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"按钮点击");
        return [RACSignal empty];
    }];
    
    
    // 第5种：代替通知
    // rac_addObserverForName:用于监听某个通知
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // 第6种：监听文本框文字改变
    // rac_textSignal:只要文本框发出改变就会发出这个信号
    [self.textField.rac_textSignal subscribeNext:^(id x) {
        // x:文本框的文字
        NSLog(@"%@",x);
    }];
    
    // 第7种:处理当界面有多次请求时，需要都获取到数据时，才能展示界面

}

// ReactiveCocoa常见宏
- (void)test9 {
    
    // RAC(TARGET, [KEYPATH, [NIL_VALUE]]):用于给某个对象的某个属性绑定
    // 给某个对象的某个属性绑定一个信号,只要产生信号,就会把信号的内容给对象的属性赋值
    RACSignal *s1 = [self.button rac_signalForControlEvents:UIControlEventTouchUpInside];
    RACSignal *s2 = [s1 filter:^BOOL(UIButton *value) {
        if (value.selected) {
            return NO;
        } else {
            return YES;
        }
    }];
    RACSignal *s3 = [s2 map:^id(id value) {
        return @"123";
    }];

    RAC(self.textField, text) = s3;
    
//    // RACObserve(self, name):监听某个对象的某个属性,返回的是信号
//    // 观察某个对象某个属性
//    // 使用RACObserve观察属性时，会立即将属性当前值sendNext.
//    [RACObserve(self.textField, text) subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
}

- (IBAction)action:(UIButton *)sender {
//    self.textField.text = @"123456";
    sender.selected = !sender.selected;
    
//    NSString *storyboardName = @"Main";
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
//    BViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"BViewController"];
//    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
