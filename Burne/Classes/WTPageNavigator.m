//
//  WTPageNavigator.m
//  Pods
//
//  Created by hongru qi on 2016/12/17.
//
//

#import "WTPageNavigator.h"
#import "WTPageRouter.h"
#import "UIViewController+PageResult.h"

@interface WTPageNavigator ()

@property (nonatomic, strong) NSMutableArray *navigationControllerPool;
@property (nonatomic, strong, readonly) UINavigationController *lastNavigationController;
@property (nonatomic, strong, readonly) UIViewController *topModalViewController;

@end

@implementation WTPageNavigator


#pragma mark - Singleton method

+ (instancetype)instance
{
    static dispatch_once_t oncePredicate;
    static WTPageNavigator *instance;
    dispatch_once(&oncePredicate, ^{
        instance = [[self alloc] init];
        instance.navigationControllerPool = [[NSMutableArray alloc] initWithCapacity:2];
    });
    
    return instance;
}

- (instancetype)init
{

    if (self = [super init]) {
    }
    
    return self;
}

#pragma mark - push方式打开新界面
- (BOOL)pushViewControllerByDict:(NSDictionary *)dict animated:(BOOL)animate
{
    return [self pushViewControllerByDict:dict delegate:nil animated:animate];
}

- (BOOL)pushViewControllerByUrl:(NSString *)url animated:(BOOL)animate
{
    return [self pushViewControllerByUrl:url delegate:nil animated:animate];
}

- (BOOL)pushViewController:(UIViewController *)viewController animated:(BOOL)animate
{
    return [self pushViewController:viewController delegate:nil animated:animate];
}

- (BOOL)pushViewControllerByDict:(NSDictionary *)dict delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate
{
    UIViewController *viewController = [[WTPageRouter instance] matchControllerDict:dict];
    if (!viewController) {
        return [[WTPageRouter instance] executeActionDict:dict];
    }
    return [self pushViewController:viewController delegate:delegate animated:animate];
}

- (BOOL)pushViewControllerByUrl:(NSString *)url delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate
{
    UIViewController *viewController = [[WTPageRouter instance] matchControllerUrl:url];
    return [self pushViewController:viewController delegate:delegate animated:animate];
}

- (BOOL)canPushViewController:(UIViewController *)viewController delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate
{
    if (!viewController) {
        return NO;
    }
    return YES;
}

- (BOOL)pushViewController:(UIViewController *)viewController delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate
{
    
    if (![self canPushViewController:viewController delegate:delegate animated:animate]) {
        return NO;
    }
    
    if (delegate) {
        viewController.WTDelegate = delegate;
    }
    
    if (_navigationControllerPool.count <= 0 || !_rootNavigationController) {
        self.rootNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        return YES;
    }
    
    UINavigationController *navigationController = [self.navigationControllerPool lastObject];
    [navigationController pushViewController:viewController animated:animate];
    
    return YES;
}

- (BOOL)canPopViewControllerAnimated:(BOOL)animate
{
    if (self.lastNavigationController.viewControllers.count <= 1) {
        return NO;
    }
    return YES;
}

#pragma mark - pop关闭新界面
- (BOOL)popViewControllerAnimated:(BOOL)animate
{
    if (![self canPopViewControllerAnimated:animate]) {
        return NO;
    }
    
    UINavigationController *navigationController = [self.navigationControllerPool lastObject];
    if (navigationController.presentedViewController) {
        [navigationController dismissViewControllerAnimated:NO completion:^{
            [navigationController popViewControllerAnimated:animate];
        }];
        return YES;
    }
    
    [navigationController popViewControllerAnimated:animate];
    return YES;
}


- (BOOL)canPopToViewController:(UIViewController *)viewController animated:(BOOL)animate
{
    UINavigationController *navigationController = self.lastNavigationController;
    if (!navigationController || navigationController.topVisibleViewController != navigationController.topViewController) {
        return NO;
    }
    return YES;
}

- (BOOL)popToViewController:(UIViewController *)viewController animated:(BOOL)animate
{
    if (![self canPopToViewController:viewController animated:animate]) {
        return NO;
    }
    UINavigationController *navigationController = self.lastNavigationController;
    
    if (navigationController.presentedViewController) {
        [navigationController dismissViewControllerAnimated:NO completion:^{
            [navigationController popToViewController:viewController animated:animate];
        }];
        return YES;
    }
    
    [navigationController popToViewController:viewController animated:animate];
    return YES;
}

- (BOOL)canPopViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animate
{
    UINavigationController *navigationController = self.lastNavigationController;
    if (!navigationController || navigationController.topVisibleViewController != navigationController.topViewController
        || navigationController.viewControllers.count < index) {
        return NO;
    }
    return YES;
}

- (BOOL)popViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animate
{
    if (![self canPopViewControllerAtIndex:index animated:animate]) {
        return NO;
    }
    
    UINavigationController *navigationController = self.lastNavigationController;
    
    UIViewController *viewController = navigationController.viewControllers[navigationController.viewControllers.count - index];
    if (navigationController.presentedViewController) {
        [navigationController dismissViewControllerAnimated:NO completion:^{
            [navigationController popToViewController:viewController animated:animate];
        }];
        return YES;
    }
    
    [navigationController popToViewController:viewController animated:animate];
    return YES;
}

#pragma mark - 打开模态界面
//Caution:模块外的present请使用presentNavigationViewController
- (BOOL)presentViewControllerByDict:(NSDictionary *)dict animated:(BOOL)animate
{
    return [self presentViewControllerByDict:dict delegate:nil animated:animate completion:nil];
}

- (BOOL)presentViewControllerByDict:(NSDictionary *)dict animated:(BOOL)animate completion:(void (^)(void))completion
{
    return [self presentViewControllerByDict:dict delegate:nil animated:animate completion:completion];
}

- (BOOL)presentViewControllerByUrl:(NSString *)url animated:(BOOL)animate
{
    return [self presentViewControllerByUrl:url delegate:nil animated:animate completion:nil];
}

- (BOOL)presentViewControllerByUrl:(NSString *)url animated:(BOOL)animate completion:(void (^)(void))completion
{
    return [self presentViewControllerByUrl:url delegate:nil animated:animate completion:completion];
}

- (BOOL)presentViewController:(UIViewController *)viewController animated:(BOOL)animate
{
    return [self presentViewController:viewController delegate:nil animated:animate completion:nil];
}

- (BOOL)presentViewController:(UIViewController *)viewController animated:(BOOL)animate completion:(void (^)(void))completion
{
    return [self presentViewController:viewController delegate:nil animated:animate completion:nil];
}

- (BOOL)presentViewControllerByDict:(NSDictionary *)dict delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate
{
    return [self presentViewControllerByDict:dict delegate:delegate animated:animate completion:nil];
}

- (BOOL)presentViewControllerByDict:(NSDictionary *)dict delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate completion:(void (^)(void))completion
{
    UIViewController *viewController = [[WTPageRouter instance] matchControllerDict:dict];
    if (!viewController) {
        return [[WTPageRouter instance] executeActionDict:dict];
    }
    return [self presentViewController:viewController delegate:delegate animated:animate completion:completion];
}

- (BOOL)presentViewControllerByUrl:(NSString *)url delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate
{
    return [self presentViewControllerByUrl:url delegate:delegate animated:animate completion:nil];
}

- (BOOL)presentViewControllerByUrl:(NSString *)url delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate completion:(void (^)(void))completion
{
    UIViewController *viewController = [[WTPageRouter instance] matchControllerUrl:url];
    return [self presentViewController:viewController delegate:delegate animated:animate completion:completion];
}

- (BOOL)presentViewController:(UIViewController *)viewController delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate
{
    return [self presentViewController:viewController delegate:delegate animated:animate completion:nil];
}

- (BOOL)canPresentViewController:(UIViewController *)viewController delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate completion:(void (^)(void))completion
{
    if (!viewController) {
        return NO;
    }
    if (_navigationControllerPool.count <= 0) {
        return NO;
    }
    return YES;
}

- (BOOL)presentViewController:(UIViewController *)viewController delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate completion:(void (^)(void))completion
{
    if (![self canPresentViewController:viewController delegate:delegate animated:animate completion:nil]) {
        return NO;
    }
    
    if (delegate) {
        viewController.WTDelegate = delegate;
    }
    
    UINavigationController *navigationController = [self.navigationControllerPool lastObject];
    [navigationController.topVisibleViewController presentViewController:viewController animated:animate completion:completion];
    return YES;
}

#pragma mark - 打开(带导航)模态界面
//模块外的present请使用这个
- (BOOL)presentNavigationViewControllerByDict:(NSDictionary *)dict animated:(BOOL)animate
{
    return [self presentNavigationViewControllerByDict:dict delegate:nil animated:animate completion:nil];
}

- (BOOL)presentNavigationViewControllerByDict:(NSDictionary *)dict animated:(BOOL)animate completion:(void (^)(void))completion
{
    return [self presentNavigationViewControllerByDict:dict delegate:nil animated:animate completion:completion];
}

- (BOOL)presentNavigationViewControllerByUrl:(NSString *)url animated:(BOOL)animate
{
    return [self presentNavigationViewControllerByUrl:url delegate:nil animated:animate completion:nil];
}

- (BOOL)presentNavigationViewControllerByUrl:(NSString *)url animated:(BOOL)animate completion:(void (^)(void))completion
{
    return [self presentNavigationViewControllerByUrl:url delegate:nil animated:animate completion:completion];
}

- (BOOL)presentNavigationViewController:(UIViewController *)viewController animated:(BOOL)animate
{
    return [self presentNavigationViewController:viewController delegate:nil animated:animate completion:nil];
}

- (BOOL)presentNavigationViewController:(UIViewController *)viewController animated:(BOOL)animate completion:(void (^)(void))completion
{
    return [self presentNavigationViewController:viewController delegate:nil animated:animate completion:completion];
}

- (BOOL)presentNavigationViewControllerByDict:(NSDictionary *)dict delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate
{
    return [self presentNavigationViewControllerByDict:dict delegate:delegate animated:animate completion:nil];
}

- (BOOL)presentNavigationViewControllerByDict:(NSDictionary *)dict delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate completion:(void (^)(void))completion
{
    UIViewController *viewController = [[WTPageRouter instance] matchControllerDict:dict];
    if (!viewController) {
        return [[WTPageRouter instance] executeActionDict:dict];
    }
    return [self presentNavigationViewController:viewController delegate:delegate animated:animate completion:completion];
}

- (BOOL)presentNavigationViewControllerByUrl:(NSString *)url delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate
{
    return [self presentNavigationViewControllerByUrl:url delegate:delegate animated:animate completion:nil];
}

- (BOOL)presentNavigationViewControllerByUrl:(NSString *)url delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate completion:(void (^)(void))completion
{
    UIViewController *viewController = [[WTPageRouter instance] matchControllerUrl:url];
    return [self presentNavigationViewController:viewController delegate:delegate animated:animate completion:completion];
}

- (BOOL)presentNavigationViewController:(UIViewController *)viewController delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate
{
    return [self presentNavigationViewController:viewController delegate:delegate animated:animate completion:nil];
}

- (BOOL)canPresentNavigationViewController:(UIViewController *)viewController delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate completion:(void (^)(void))completion
{
    if (!viewController) {
        return NO;
    }
    if (_navigationControllerPool.count <= 0) {
        return NO;
    }
    return YES;
}

- (BOOL)presentNavigationViewController:(UIViewController *)viewController delegate:(id<WTPageResultProtocol>)delegate animated:(BOOL)animate completion:(void (^)(void))completion
{
    UINavigationController *navigationController = [self.navigationControllerPool lastObject];
    UINavigationController *modalViewController = [[UINavigationController alloc] initWithRootViewController:viewController];
    if (delegate) {
        viewController.WTDelegate = delegate;
    }

    [navigationController.topVisibleViewController presentViewController:modalViewController animated:animate completion:completion];
    [self.navigationControllerPool addObject:modalViewController];
    
    return YES;
}

#pragma mark - 关闭模态界面(包含带导航和不带导航的)
- (BOOL)dismissViewController:(BOOL)animate
{
    return [self dismissViewController:animate completion:nil];
}

- (BOOL)canDismissViewController:(BOOL)animate completion:(void (^)(void))completion
{
    if (_navigationControllerPool.count <= 0) {
        return NO;
    }
    
    UINavigationController *navigationController = [self.navigationControllerPool lastObject];
//    UIViewController *modalViewController = navigationController.topVisibleViewController;
    
    // 最后的navigationController中没有模态viewController情况(check最后的navigationController是否是modal)
    if (navigationController.topViewController == navigationController.topVisibleViewController) {
        if (_navigationControllerPool.count <= 1) {
            return NO;
        }
        
        UINavigationController *parentNavigationController = _navigationControllerPool[_navigationControllerPool.count - 2];
        if (parentNavigationController.topViewController == parentNavigationController.topVisibleViewController) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)dismissViewController:(BOOL)animate completion:(void (^)(void))completion
{
    if (![self canDismissViewController:animate completion:nil]) {
        return NO;
    }
    
    UINavigationController *navigationController = [self.navigationControllerPool lastObject];
    UIViewController *modalViewController = navigationController.topVisibleViewController;
    
    // 最后的navigationController中没有模态viewController情况(check最后的navigationController是否是modal)
    if (navigationController.topViewController == navigationController.topVisibleViewController) {
        modalViewController = navigationController;
        [_navigationControllerPool removeObject:navigationController];
    }
    
    [modalViewController dismissViewControllerAnimated:animate completion:completion];
    return YES;
}

- (BOOL)canPopToRootViewControllerAnimated
{
    if (self.lastNavigationController.viewControllers.count > 1) {
        return YES;
    }
    return NO;
}

// pop到当前navigationController所在的rootViewController
- (BOOL)popToRootViewControllerAnimated:(BOOL)animate
{
    if (![self canPopToRootViewControllerAnimated]) {
        return NO;
    }
    [self.lastNavigationController popToRootViewControllerAnimated:animate];
    return YES;
}

#pragma mark - Accessors
- (NSArray<__kindof UINavigationController *> *)navigationControllers
{
    return [NSArray arrayWithArray:_navigationControllerPool];;
}

- (UINavigationController *)lastNavigationController
{
    if (_navigationControllerPool.count <= 0) {
        return nil;
    }
    
    return [_navigationControllerPool lastObject];
}

- (void)setRootNavigationController:(UINavigationController *)rootNavigationController
{
    _rootNavigationController = rootNavigationController;
    if (_navigationControllerPool.count <= 0) {
        [_navigationControllerPool addObject:_rootNavigationController];
    } else {
        // danger to be here
        [_navigationControllerPool removeAllObjects];
        [_navigationControllerPool addObject:_rootNavigationController];
    }
}

- (UINavigationController *)navigationController
{
    return self.navigationControllers.lastObject;
}


@end

@interface UINavigationController(modal)

@property (nonatomic, strong, readonly) UIViewController *topModalViewController;

@end

@implementation UINavigationController(modal)

-(UIViewController *)topModalViewController {
    return self.topVisibleViewController;
}

@end


@implementation UINavigationController (PageNavigatorController)

- (UIViewController*)topVisibleViewController
{
    UIViewController *visibleViewController = self.visibleViewController;
    
    while (visibleViewController.presentedViewController) {
        visibleViewController = visibleViewController.presentedViewController;
    }
    
    return visibleViewController;
}
@end
