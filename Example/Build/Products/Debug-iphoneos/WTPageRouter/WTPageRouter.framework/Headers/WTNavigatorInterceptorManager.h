//
//  WTPageNavigatorInterceptorManager.h
//  Pods
//
//  Created by hongru qi on 2017/5/30.
//
//

#import <Foundation/Foundation.h>
#import "WTControllerInvocation.h"

@interface WTNavigatorInterceptorManager : NSObject

+ (instancetype)instance;

+ (BOOL)registerClass:(Class)invocationClass;
+ (void)unregisterClass:(Class)invocationClass;

//处理拦截，YES代表被拦截了。
- (BOOL)processInterceptor:(NSInvocation *)invocation
            viewController:(UIViewController *)viewController
                  animated:(BOOL)animated
                showVCMode:(WTShowVCMode)showVCMode;

@end
