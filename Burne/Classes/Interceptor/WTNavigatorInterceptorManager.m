//
//  WTNavigatorInterceptorManager.m
//  Pods
//
//  Created by hongru qi on 2017/5/30.
//
//

#import "WTNavigatorInterceptorManager.h"
#import <Aspects/Aspects.h>
#import "WTNavigatorInterceptor.h"

static NSMutableArray *interceptArray;
static BOOL isInterceptoring = NO;

@implementation WTNavigatorInterceptorManager

+ (instancetype)instance {
    static dispatch_once_t oncePredicate;
    static WTNavigatorInterceptorManager *instance;
    dispatch_once(&oncePredicate, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

// register
+ (void)initialize {
    if (self == [WTNavigatorInterceptorManager class]) {
        //初始化成员
        interceptArray = [NSMutableArray array];
    }
}

+ (BOOL)registerClass:(Class)invocationClass {
    [interceptArray addObject:invocationClass];
    return YES;
}

+ (void)unregisterClass:(Class)invocationClass {
    [interceptArray removeObject:invocationClass];
}

- (BOOL)processInterceptor:(NSInvocation *)invocation
            viewController:(UIViewController *)viewController
                  animated:(BOOL)animated
                showVCMode:(WTShowVCMode)showVCMode {
    if (isInterceptoring == YES) {
        return NO;
    }
    __block BOOL intercept = NO;
    //组装配置
    WTControllerInvocation *controlInvocation = [WTNavigatorInterceptorManager createControllerInvocation:invocation viewController:viewController animated:animated showVCMode:showVCMode];
    
    [interceptArray enumerateObjectsUsingBlock:^(Class ProtocolClass, NSUInteger idx, BOOL * _Nonnull stop) {
        isInterceptoring = YES;
         WTNavigatorInterceptor *interceptor = [[ProtocolClass alloc] init];
        //开始找当前的视图控制器
        UIViewController *visibleViewController;
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        visibleViewController = window.rootViewController;
        while (visibleViewController.presentedViewController) {
            visibleViewController = visibleViewController.presentedViewController;
        }
        if ([visibleViewController isKindOfClass:[UINavigationController class]]) {
            visibleViewController = ((UINavigationController *)visibleViewController)
            .viewControllers.lastObject;
        }
        
        [interceptor setCurrentViewControler:visibleViewController];
        BOOL canNext = [interceptor intercept:controlInvocation];
        isInterceptoring = NO;
        if (canNext == NO) {
            *stop = YES;
            intercept = YES;
        }
    }];

    return intercept;
}

+ (WTControllerInvocation *)createControllerInvocation:(NSInvocation *)invocation
                                        viewController:(UIViewController *)viewController
                                              animated:(BOOL)animated
                                            showVCMode:(WTShowVCMode)showVCMode {
    WTControllerInvocation *controllerInvocation = [[WTControllerInvocation alloc] init];
    controllerInvocation.showViewControllerMode = showVCMode;
    controllerInvocation.viewController = viewController;
    controllerInvocation.animation = animated;
    return controllerInvocation;
}

@end
