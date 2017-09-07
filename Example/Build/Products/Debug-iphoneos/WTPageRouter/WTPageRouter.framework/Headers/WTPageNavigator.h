//
//  WTPageNavigator.h
//  Pods
//
//  Created by hongru qi on 2016/12/17.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WTPageResultProtocol.h"

@interface WTPageNavigator : NSObject

@property (nonatomic, strong) UINavigationController *rootNavigationController;
@property (nonatomic, copy) NSArray<__kindof UINavigationController *> *navigationControllers;
@property (nonatomic, strong) UINavigationController *navigationController;

+ (instancetype)instance;

// push方式打开新界面
- (BOOL)pushViewControllerByDict:(NSDictionary *)dict animated:(BOOL)animate;
- (BOOL)pushViewControllerByUrl:(NSString *)url animated:(BOOL)animate;
- (BOOL)pushViewController:(UIViewController *)viewController animated:(BOOL)animate;

- (BOOL)pushViewControllerByDict:(NSDictionary *)dict delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate;
- (BOOL)pushViewControllerByUrl:(NSString *)url delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate;
- (BOOL)pushViewController:(UIViewController *)viewController delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate;

- (BOOL)canPushViewController:(UIViewController *)viewController delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate;

// pop关闭新界面
- (BOOL)popViewControllerAnimated:(BOOL)animate;
- (BOOL)popToViewController:(UIViewController *)viewController animated:(BOOL)animate;
- (BOOL)popViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animate;

- (BOOL)canPopViewControllerAnimated:(BOOL)animate;
- (BOOL)canPopToViewController:(UIViewController *)viewController animated:(BOOL)animate;
- (BOOL)canPopViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animate;

// 打开模态界面，Caution:模块外的present请使用presentNavigationViewController
- (BOOL)presentViewControllerByDict:(NSDictionary *)dict animated:(BOOL)animate;
- (BOOL)presentViewControllerByDict:(NSDictionary *)dict animated:(BOOL)animate completion:(void (^)(void))completion;
- (BOOL)presentViewControllerByUrl:(NSString *)url animated:(BOOL)animate;
- (BOOL)presentViewControllerByUrl:(NSString *)url animated:(BOOL)animate completion:(void (^)(void))completion;
- (BOOL)presentViewController:(UIViewController *)viewController animated:(BOOL)animate;
- (BOOL)presentViewController:(UIViewController *)viewController animated:(BOOL)animate completion:(void (^)(void))completion;

- (BOOL)presentViewControllerByDict:(NSDictionary *)dict delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate;
- (BOOL)presentViewControllerByDict:(NSDictionary *)dict delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate completion:(void (^)(void))completion;
- (BOOL)presentViewControllerByUrl:(NSString *)url delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate;
- (BOOL)presentViewControllerByUrl:(NSString *)url delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate completion:(void (^)(void))completion;
- (BOOL)presentViewController:(UIViewController *)viewController delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate;
- (BOOL)presentViewController:(UIViewController *)viewController delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate completion:(void (^)(void))completion;

- (BOOL)canPresentViewController:(UIViewController *)viewController delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate completion:(void (^)(void))completion;

// 打开(带导航)模态界面，模块外的present请使用这个
- (BOOL)presentNavigationViewControllerByDict:(NSDictionary *)dict animated:(BOOL)animate;
- (BOOL)presentNavigationViewControllerByDict:(NSDictionary *)dict animated:(BOOL)animate completion:(void (^)(void))completion;
- (BOOL)presentNavigationViewControllerByUrl:(NSString *)url animated:(BOOL)animate;
- (BOOL)presentNavigationViewControllerByUrl:(NSString *)url animated:(BOOL)animate completion:(void (^)(void))completion;
- (BOOL)presentNavigationViewController:(UIViewController *)viewController animated:(BOOL)animate;
- (BOOL)presentNavigationViewController:(UIViewController *)viewController animated:(BOOL)animate completion:(void (^)(void))completion;

- (BOOL)presentNavigationViewControllerByDict:(NSDictionary *)dict delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate;
- (BOOL)presentNavigationViewControllerByDict:(NSDictionary *)dict delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate completion:(void (^)(void))completion;
- (BOOL)presentNavigationViewControllerByUrl:(NSString *)url delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate;
- (BOOL)presentNavigationViewControllerByUrl:(NSString *)url delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate completion:(void (^)(void))completion;
- (BOOL)presentNavigationViewController:(UIViewController *)viewController delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate;
- (BOOL)presentNavigationViewController:(UIViewController *)viewController delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate completion:(void (^)(void))completion;

- (BOOL)canPresentNavigationViewController:(UIViewController *)viewController delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate completion:(void (^)(void))completion;

// 关闭模态界面(包含带导航和不带导航的)
- (BOOL)dismissViewController:(BOOL)animate;
- (BOOL)dismissViewController:(BOOL)animate completion:(void (^)(void))completion;

- (BOOL)canDismissViewController:(BOOL)animate completion:(void (^)(void))completion;

// pop到当前navigationController所在的rootViewController
- (BOOL)popToRootViewControllerAnimated:(BOOL)animate;
- (BOOL)canPopToRootViewControllerAnimated;

- (UINavigationController *)navigationController;

@end

@interface UINavigationController (PageNavigatorController)

// 处于当前rootViewController最顶端可见的ViewController，包含modal
@property (nonatomic, strong, readonly) UIViewController *topVisibleViewController;

@end
