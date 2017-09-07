//
//  WTNavigatorInterceptor.h
//  Pods
//
//  Created by hongru qi on 2017/5/30.
//
//

#import <Foundation/Foundation.h>
#import "WTControllerInvocation.h"

@interface WTNavigatorInterceptor : NSObject

@property (nonatomic, strong) UIViewController *currentViewControler;

+ (BOOL)registerClass:(Class)subClass;
+ (void)unregisterClass:(Class)subClass;


/*======================================================================
 Begin responsibilities for protocol implementors
 
 The methods between this set of begin-end markers must be
 implemented in order to create a working protocol.
 ======================================================================*/

- (BOOL)intercept:(WTControllerInvocation *)invocation;
+ (BOOL)navigateWithInvocation:(WTControllerInvocation *)invocation;
@end
