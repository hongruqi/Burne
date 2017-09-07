//
//  WTControllerInvocation.h
//  Pods
//
//  Created by hongru qi on 2017/5/30.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WTShowVCMode) {
    WTShowVCModePush = 1,
    WTShowVCModePop = 1 << 1,
    WTShowVCModePresent = 1 << 2,
    WTShowVCModeDismiss = 1 << 3,
    WTShowVCModePresentNavigator = 1 << 4
};

@interface WTControllerInvocation : NSObject

@property (nonatomic, strong) UIViewController *viewController;//要跳的控制器

@property (nonatomic, assign) BOOL animation;//是否有动画

@property (nonatomic, assign) WTShowVCMode showViewControllerMode;//显示控制器的方式
@end
