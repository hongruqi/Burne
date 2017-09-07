//
//  WTPageNavigatorInterceptor.m
//  Pods
//
//  Created by hongru qi on 2017/5/30.
//
//

#import "WTNavigatorInterceptor.h"
#import "WTNavigatorInterceptorManager.h"
#import "WTPageNavigator.h"

@implementation WTNavigatorInterceptor

+ (BOOL)registerClass:(Class)subClass {
    return [WTNavigatorInterceptorManager registerClass:subClass];
}

+ (void)unregisterClass:(Class)subClass {
    
    return [WTNavigatorInterceptorManager unregisterClass:subClass];
}

- (BOOL)intercept:(WTControllerInvocation *)invocation {
    return YES;
}

+ (BOOL)navigateWithInvocation:(WTControllerInvocation *)invocation
{
    if (invocation.viewController) {
        if (invocation.showViewControllerMode == WTShowVCModePush) {
            [[WTPageNavigator instance] pushViewController:invocation.viewController animated:invocation.animation];
        } else if (invocation.showViewControllerMode == WTShowVCModePresent) {
            [[WTPageNavigator instance] presentNavigationViewController:invocation.viewController animated:invocation.animation];
        } else if (invocation.showViewControllerMode == WTShowVCModeDismiss) {
            [[WTPageNavigator instance] dismissViewController:invocation.animation];
        } else if (invocation.showViewControllerMode == WTShowVCModePop) {
            [[WTPageNavigator instance] popViewControllerAnimated:invocation.animation];
        } else {
            return NO;
        }
        return YES;
    }
    return NO;
}
@end
