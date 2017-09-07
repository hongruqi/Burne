//
//  WTPageSafeNavigation.h
//  Pods
//
//  Created by hongru qi on 2017/5/25.
//
//

#import <Foundation/Foundation.h>
#import <Aspects/Aspects.h>
#import "WTNavigatorAspect.h"
#import "WTControllerInvocation.h"

@interface WTPageSafeNavigation : NSObject

+ (instancetype _Nullable )instance;

- (void)processSafePushWithInfo:(_Nonnull id<AspectInfo>)info showVCMode:(WTShowVCMode)showVCMode animated:(BOOL)animated completion:(void (^ __nullable)(BOOL animated))completion;

- (void)failureShowViewController;

@end
