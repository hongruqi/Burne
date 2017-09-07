//
//  WTNavigatorAspect.m
//  Pods
//
//  Created by hongru qi on 2017/5/25.
//
//

#import "WTNavigatorAspect.h"
#import "WTPageNavigator.h"
#import <Aspects/Aspects.h>
#import "WTPageSafeNavigation.h"
#import "WTPageResultProtocol.h"
#import "UIViewController+PageResult.h"
#import "WTPageRouter.h"
#import "WTControllerInvocation.h"
#import "WTNavigatorInterceptorManager.h"

@implementation WTNavigatorAspect

+ (instancetype)instance{
    static dispatch_once_t oncePredicate;
    static WTNavigatorAspect *instance;
    dispatch_once(&oncePredicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
                    //WTPageNavigator专用
            //push
            [WTPageNavigator aspect_hookSelector:@selector(pushViewController:delegate:animated:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info,UIViewController *viewController,id delegate,BOOL animated) {
                BOOL returnValue = [[WTPageNavigator instance] canPushViewController:viewController delegate:delegate animated:animated];
                [info.originalInvocation setReturnValue:&returnValue];
                if (returnValue) {
                    [[WTNavigatorAspect instance] processWithInfo:info viewController:viewController showVCMode:WTShowVCModePush animated:animated];
                }
            }error:NULL];
            
            //pop
            [WTPageNavigator aspect_hookSelector:@selector(popViewControllerAnimated:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info,BOOL animated) {
                BOOL returnValue = [[WTPageNavigator instance] canPopViewControllerAnimated:animated];
                [info.originalInvocation setReturnValue:&returnValue];
                if (returnValue) {
                    [[WTNavigatorAspect instance] processWithInfo:info viewController:nil showVCMode:WTShowVCModePop animated:animated];
                }
            }error:NULL];
            [WTPageNavigator aspect_hookSelector:@selector(popToViewController:animated:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info,UIViewController *viewController,BOOL animated) {
                BOOL returnValue = [[WTPageNavigator instance] canPopToViewController:viewController animated:animated];
                [info.originalInvocation setReturnValue:&returnValue];
                if (returnValue) {
                    [[WTNavigatorAspect instance] processWithInfo:info viewController:viewController showVCMode:WTShowVCModePop animated:animated];
                }
            }error:NULL];
            [WTPageNavigator aspect_hookSelector:@selector(popViewControllerAtIndex:animated:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info,NSUInteger index,BOOL animated) {
                BOOL returnValue = [[WTPageNavigator instance] canPopViewControllerAtIndex:index animated:animated];
                [info.originalInvocation setReturnValue:&returnValue];
                if (returnValue) {
                    [[WTNavigatorAspect instance] processWithInfo:info viewController:nil showVCMode:WTShowVCModePop animated:animated];
                }
            }error:NULL];
            
            //present
            [WTPageNavigator aspect_hookSelector:@selector(presentViewController:delegate:animated:completion:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info,UIViewController *viewController,id delegate,BOOL animated) {
                BOOL returnValue = [[WTPageNavigator instance] canPresentViewController:viewController delegate:delegate animated:animated completion:nil];
                [info.originalInvocation setReturnValue:&returnValue];
                if (returnValue) {
                    [[WTNavigatorAspect instance] processWithInfo:info viewController:viewController showVCMode:WTShowVCModePresent animated:animated];
                }
            }error:NULL];
            
            //present Navigator
            [WTPageNavigator aspect_hookSelector:@selector(presentNavigationViewController:delegate:animated:completion:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info,UIViewController *viewController,id delegate,BOOL animated) {
                BOOL returnValue = [[WTPageNavigator instance] canPresentNavigationViewController:viewController delegate:delegate animated:animated completion:nil];
                [info.originalInvocation setReturnValue:&returnValue];
                if (returnValue) {
                    [[WTNavigatorAspect instance] processWithInfo:info viewController:viewController showVCMode:WTShowVCModePresent animated:animated];
                }
            }error:NULL];
            
            //dismiss
            [WTPageNavigator aspect_hookSelector:@selector(dismissViewController:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info,BOOL animated) {
                BOOL returnValue = [[WTPageNavigator instance] canDismissViewController:animated completion:nil];
                [info.originalInvocation setReturnValue:&returnValue];
                if (returnValue) {
                    [[WTNavigatorAspect instance] processWithInfo:info viewController:nil showVCMode:WTShowVCModeDismiss animated:animated];
                }
            }error:NULL];
            [WTPageNavigator aspect_hookSelector:@selector(dismissViewController:completion:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info,BOOL animated) {
                BOOL returnValue = [[WTPageNavigator instance] canDismissViewController:animated completion:nil];
                [info.originalInvocation setReturnValue:&returnValue];
                if (returnValue) {
                    [[WTNavigatorAspect instance] processWithInfo:info viewController:nil showVCMode:WTShowVCModeDismiss animated:animated];
                }
            }error:NULL];
            
            //pop root
            [WTPageNavigator aspect_hookSelector:@selector(popToRootViewControllerAnimated:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info,BOOL animated) {
                BOOL returnValue = [[WTPageNavigator instance] canPopToRootViewControllerAnimated];
                [info.originalInvocation setReturnValue:&returnValue];
                if (returnValue) {
                    [[WTNavigatorAspect instance] processWithInfo:info viewController:nil showVCMode:WTShowVCModePop animated:animated];
                }
            }error:NULL];
        });
}

- (void)processWithInfo:(id<AspectInfo>)info viewController:(UIViewController *)viewController showVCMode:(WTShowVCMode)showVCMode animated:(BOOL)animated
{
    //先走拦截
    BOOL isInterceptor = [[WTNavigatorInterceptorManager instance] processInterceptor:info.originalInvocation viewController:viewController animated:animated showVCMode:showVCMode];
    if(isInterceptor == YES){
        return;
    }
    
    //处理pageResult
    [self handlePageResultWithInfo:info viewController:viewController showVCMode:showVCMode animated:animated];
    
    if (showVCMode == WTShowVCModeDismiss) {
        [info.originalInvocation invoke];
        return;
    }
    //处理push的
    [[WTPageSafeNavigation instance] processSafePushWithInfo:info showVCMode:showVCMode animated:animated completion:^(BOOL animated) {
        [info.originalInvocation invoke];
        NSMethodSignature *methodSignature = [info.originalInvocation methodSignature];
        const char *returnType = [methodSignature methodReturnType];
        if (strncmp(returnType, "v", 1) != 0) {
            if (strncmp(returnType, "@", 1) == 0) {
                void *result;
                [info.originalInvocation getReturnValue:&result];
                id returnValue = (__bridge id)result;
                if (returnValue == nil) {
                    [[WTPageSafeNavigation instance] failureShowViewController];
                    return;
                } else if ([returnValue isKindOfClass:[NSArray class]]) {
                    NSArray *arrayReturnValue = (NSArray *)returnValue;
                    if (arrayReturnValue.count == 0) {
                        [[WTPageSafeNavigation instance] failureShowViewController];
                        return;
                    }
                }
            } else {
                switch (returnType[0] == 'r' ? returnType[1] : returnType[0]) {
                    case 'B': {
                        BOOL boolResult;
                        [info.originalInvocation getReturnValue:&boolResult];
                        if (!boolResult) {
                            [[WTPageSafeNavigation instance] failureShowViewController];
                            break;
                        }
                    }
                    case 'c': {
                        char charResult;
                        [info.originalInvocation getReturnValue:&charResult];
                        if (charResult == '\0') {
                            [[WTPageSafeNavigation instance] failureShowViewController];
                        }
                        break;
                    }
                }
            }
        }
        return;
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
        NSString *selectorName = [NSString stringWithFormat:@"%s",sel_getName([info.originalInvocation selector])];
        if([selectorName rangeOfString:@"popToViewController:animated:"].location != NSNotFound){
            [(WTPageNavigator *)info.instance popToViewController:viewController animated:animated];
        }
#pragma clang diagnostic pop
    }];
}

- (void)handlePageResultWithInfo:(id<AspectInfo>)info viewController:(UIViewController *)viewController showVCMode:(WTShowVCMode)showVCMode animated:(BOOL)animated
{
    if (showVCMode != WTShowVCModeDismiss && showVCMode != WTShowVCModePop) {
        return;
    }
    UIViewController *nowViewController = [WTPageNavigator instance].navigationControllers.lastObject.topVisibleViewController;
    //如果不需要带回数据 则直接返回
    if (![nowViewController.WTDelegate conformsToProtocol:@protocol(WTPageResultProtocol)]
        || ![nowViewController.WTDelegate respondsToSelector:@selector(WT_target:didFinishWithResult:)]) {
        return;
    }
    //希望通过WTPageResultProtocol带回数据的页面 进行跳转时必须使用target 不符合则直接抛出异常
    NSString *target = nowViewController.params[@"target"];
    if (target) {
        [nowViewController.WTDelegate WT_target:target didFinishWithResult:nowViewController.pageResult];
        return;
    }
    //抛出异常
    NSDictionary *userInfo = @{@"viewController":   nowViewController ?: [NSNull null],
                               @"param":            nowViewController.params  ?: [NSNull null],
                               };
    NSException *exception = [NSException exceptionWithName:@"target不存在" reason:@"希望通过WTPageResultProtocol带回数据的页面 进行跳转时必须使用target" userInfo:userInfo];
    @throw exception;
}


@end
