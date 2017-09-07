//
//  WTPageSafeNavigation.m
//  Pods
//
//  Created by hongru qi on 2017/5/25.
//
//

#import "WTPageSafeNavigation.h"
#import <objc/runtime.h>
#import "WTPageNavigator.h"


@interface WTPageSafeNavigation()<UINavigationControllerDelegate>

@property (nonatomic, strong) NSOperationQueue *safeNavigationQueue;

@end


@implementation WTPageSafeNavigation

+ (instancetype)instance{
    static dispatch_once_t oncePredicate;
    static WTPageSafeNavigation *instance;
    dispatch_once(&oncePredicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init{
    if (self = [super init]) {
        self.safeNavigationQueue = [[NSOperationQueue alloc] init];
        [self.safeNavigationQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

- (void)processSafePushWithInfo:(_Nonnull id<AspectInfo>)info showVCMode:(WTShowVCMode)showVCMode animated:(BOOL)animated completion:(void (^ __nullable)(BOOL animated))completion
{
    __weak typeof(self) weakSelf = self;
    
    if(showVCMode == WTShowVCModePush || showVCMode == WTShowVCModePop) {
        id vc = [info instance];
        if([vc isKindOfClass:[WTPageNavigator class]]) {
            vc = [WTPageNavigator instance].navigationControllers.lastObject;
        }
        
        //方法替换或者添加代理。
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [NSClassFromString(@"UINavigationController") aspect_hookSelector:NSSelectorFromString(@"navigationTransitionView:didEndTransition:fromView:toView:") withOptions:AspectPositionAfter usingBlock:^{
                [weakSelf didShowViewController];
            } error:NULL];
        });
        
        UINavigationController *naviC = vc;
        
        [naviC aspect_hookSelector:NSSelectorFromString(@"dealloc") withOptions:AspectPositionBefore usingBlock:^{
            [weakSelf didShowViewController];
        } error:NULL];
        
        //如果在队列中走两次popToViewController，就会出空指针问题。所以不允许走这个，其余都可以
        NSInvocation *invocation = [info originalInvocation];
        NSString *selectorName = NSStringFromSelector(invocation.selector);
        if([selectorName rangeOfString:@"popToViewController"].location != NSNotFound && self.safeNavigationQueue.suspended == YES){
            return;
        }
    }
    
    [self.safeNavigationQueue addOperationWithBlock:^{
        if(showVCMode == WTShowVCModePush || showVCMode == WTShowVCModePop) {
            [weakSelf.safeNavigationQueue setSuspended:YES];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(animated);
        });
    }];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self didShowViewController];
}

- (void)didShowViewController
{
    [self.safeNavigationQueue setSuspended:NO];
}

- (void)failureShowViewController
{
    [self.safeNavigationQueue setSuspended:NO];
}
@end
