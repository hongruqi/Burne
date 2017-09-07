//
//  WTPageRouter.m
//  Pods
//
//  Created by hongru qi on 2016/12/17.
//
//

#import "WTPageRouter.h"
#import <objc/runtime.h>

// 协议头与path间的分隔符
static NSString * const kSchemaProtocolDelimiter = @"~";
NSString * const kPageRouteNotificationValidateResult = @"kNotificationPageRouteValidateResult";//通知发送校验结果 {result:YES/NO,paramsDict:paramsDict}

NSString * const kPageRouteBlockSuffix = @"kPageRouteBlockSuffix";

@interface WTPageRouter ()

@property (strong, nonatomic) NSMutableDictionary *routes;
@property (assign, nonatomic) BOOL enableScheme;

@end

@implementation WTPageRouter

#pragma mark - interface

+ (instancetype)instance
{
    static WTPageRouter *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)enableScheme:(BOOL)enable
{
    [WTPageRouter instance].enableScheme = enable;
}

- (void)registerUrl:(NSString *)route storyboardName:(NSString *)storyboardName identifier:(NSString *)identifier
{
    NSMutableDictionary *subRoutes = [self subRoutesToRoute:route];
    
    subRoutes[@"_"] = storyboardName;
    subRoutes[@"identifier"] = identifier;
    
    NSMutableArray *targetArray = self.targetRoutes[identifier];
    if (targetArray) {
        [targetArray addObject:route];
    } else {
        self.targetRoutes[identifier] = @[route].mutableCopy;
    }
}

- (void)registerUrl:(NSString *)route toControllerClass:(Class)controllerClass
{
    NSMutableDictionary *subRoutes = [self subRoutesToRoute:route];
    
    subRoutes[@"_"] = controllerClass;
    
    NSMutableArray *targetArray = self.targetRoutes[NSStringFromClass(controllerClass)];
    if (targetArray) {
        [targetArray addObject:route];
    } else {
        self.targetRoutes[NSStringFromClass(controllerClass)] = @[route].mutableCopy;
    }
}

- (void)registerUrl:(NSString *)route toAction:(WTPageRouterBlock)block
{
    NSString *blockTarget = [NSString stringWithFormat:@"%@-%@",route,kPageRouteBlockSuffix];
    NSMutableDictionary *subRoutes = [self subRoutesToRoute:blockTarget];
    
    subRoutes[@"_"] = [block copy];
}

- (UIViewController *)matchControllerUrl:(NSString *)route
{
    NSMutableDictionary *params = [self paramsInRoute:route];
    return [self createViewControllerByRouteParams:params];
}

- (UIViewController *)matchControllerDict:(NSDictionary *)dict
{
    NSString *target = dict[@"target"];
#ifdef DEBUG
    NSAssert(target, @"跳转时，需要有target字段");
#else
    //release 环境下增强安全性。
    if (target == nil) {
        return nil;
    }
#endif
    
    __block NSMutableDictionary *params = [self paramsInRoute:target];
    // NSMutableDictionary *subRoutes = self.routes;
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![key isEqualToString:@"target"]) {
            params[key] = obj;
        }
    }];
    
    return [self createViewControllerByRouteParams:params];
}

- (id)executeActionUrl:(NSString *)route
{
#ifdef DEBUG
    NSAssert(route, @"执行block时，需要有route字段");
#else
    if (route == nil) {
        return nil;
    }
#endif
    NSString *blockTarget = [NSString stringWithFormat:@"%@-%@",route,kPageRouteBlockSuffix];
    NSDictionary *params = [self paramsInRoute:blockTarget];
    
    WTPageRouterBlock routerBlock = [params[@"block"] copy];
    if (!routerBlock) {
        return nil;
    }
    
    return routerBlock([params copy]);
}

- (id)executeActionDict:(NSDictionary *)dict
{
    NSString *target = dict[@"target"];
#ifdef DEBUG
    NSAssert(target, @"执行block时，需要有target字段");
#else
    if (target == nil) {
        return nil;
    }
#endif
    NSString *blockTarget = [NSString stringWithFormat:@"%@-%@",target,kPageRouteBlockSuffix];
    __block NSMutableDictionary *params = [self paramsInRoute:blockTarget];
    
    WTPageRouterBlock routerBlock = [params[@"block"] copy];
    
    if (!routerBlock) {
        return nil;
    }
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        params[key] = obj;
    }];
    
    return routerBlock([params copy]);
}

#pragma mark - route main
// extract params in a route
- (NSMutableDictionary *)paramsInRoute:(NSString *)route
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (!self.enableScheme) {
        route = [self stringFromFilterAppUrlScheme:route];
    }
    params[@"route"] = route;
    
    NSMutableDictionary *subRoutes = self.routes;
    NSArray *pathComponents = [self pathComponentsFromRoute:route];
    for (NSString *pathComponent in pathComponents) {
        BOOL found = NO;
        NSArray *subRoutesKeys = subRoutes.allKeys;
        for (NSString *key in subRoutesKeys) {
            if ([subRoutesKeys containsObject:pathComponent]) {
                found = YES;
                subRoutes = subRoutes[pathComponent];
                break;
            } else if ([key hasPrefix:@":"]) {
                found = YES;
                subRoutes = subRoutes[key];
                params[[key substringFromIndex:1]] = pathComponent;
                break;
            }
        }
        if (!found) {
            return nil;
        }
    }
    
    // Extract Params From Query.
    NSRange firstRange = [route rangeOfString:@"?"];
    if (firstRange.location != NSNotFound && route.length > firstRange.location + firstRange.length) {
        NSString *paramsString = [route substringFromIndex:firstRange.location + firstRange.length];
        NSArray *paramStringArr = [paramsString componentsSeparatedByString:@"&"];
        for (NSString *paramString in paramStringArr) {
            NSArray *paramArr = [paramString componentsSeparatedByString:@"="];
            if (paramArr.count > 1) {
                NSString *key = [paramArr objectAtIndex:0];
                NSString *value = [paramArr objectAtIndex:1];
                //value decode
                value = [[value stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                params[key] = value;
            }
        }
    }
    
    Class class = subRoutes[@"_"];
    if (class_isMetaClass(object_getClass(class))) {
        if ([class isSubclassOfClass:[UIViewController class]]) {
            params[@"controller_class"] = subRoutes[@"_"];
        }else{
            return nil;
        }
    } else {
        if ([subRoutes[@"_"] isKindOfClass:[NSString class]]) {
            params[@"storyboard_name"] = subRoutes[@"_"];
            params[@"identifier"] = subRoutes[@"identifier"];
        }else{
            if (subRoutes[@"_"]) {
                params[@"block"] = [subRoutes[@"_"] copy];
            }
        }
    }
    return params;
}


- (NSArray *)pathComponentsFromRoute:(NSString *)route
{
    NSMutableArray *pathComponents = [NSMutableArray array];
    if ([route rangeOfString:@"://"].location != NSNotFound) {
        NSArray *pathSegments = [route componentsSeparatedByString:@"://"];
        // 添加scheme
        NSString *scheme = pathSegments[0];
        [pathComponents addObject:scheme];
        
        // 如果只有协议，那么放一个占位符
        if ((pathSegments.count == 2 && ((NSString *)pathSegments[1]).length) || pathSegments.count < 2) {
            [pathComponents addObject:kSchemaProtocolDelimiter];
        }
        route = [route substringFromIndex:scheme.length + 2];
    }
    
    for (NSString *pathComponent in route.pathComponents) {
        if ([pathComponent isEqualToString:@"/"]) continue;
        //if ([[pathComponent substringToIndex:1] isEqualToString:@"?"]) break;
        
        NSRange range = [pathComponent rangeOfString:@"?"];
        if (range.location != NSNotFound) {
            if (range.location > 0) {
                [pathComponents addObject:[pathComponent substringToIndex:range.location]];
            }
            break;
        }
        [pathComponents addObject:pathComponent];
    }
    return [pathComponents copy];
}


- (NSMutableDictionary *)subRoutesToRoute:(NSString *)route
{
    if (!self.enableScheme) {
        route = [self stringFromFilterAppUrlScheme:route];
    }
    
    NSArray *pathComponents = [self pathComponentsFromRoute:route];
    NSInteger index = 0;
    NSMutableDictionary *subRoutes = self.routes;
    while (index < pathComponents.count) {
        NSString *pathComponent = pathComponents[index];
        if (![subRoutes objectForKey:pathComponent]) {
            subRoutes[pathComponent] = [[NSMutableDictionary alloc] init];
        }
        subRoutes = subRoutes[pathComponent];
        index++;
    }
    
    return subRoutes;
}

#pragma mark - Private

- (UIViewController *)viewControllerByRouteParams:(NSMutableDictionary *)params
{
    Class controllerClass = params[@"controller_class"];
    if (!controllerClass) {
        return nil;
    }
    
    NSString *route = params[@"route"];
    NSString *target = route;
    if (route && [route containsString:@"?"]) {
        target = [route componentsSeparatedByString:@"?"][0];
    }
    
    UIViewController *viewController = [[controllerClass alloc] init];
    //    if (![[viewController class] validateParams:params]) {
    BOOL validateResult = [viewController validateParams:params];
    [[NSNotificationCenter defaultCenter] postNotificationName:kPageRouteNotificationValidateResult object:nil userInfo:@{@"result":@(validateResult),@"paramsDict":[params copy]}];
    if (!validateResult) {
        return nil;
    }
    
    objc_setAssociatedObject(viewController, @selector(params), [params copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return viewController;
}

- (UIViewController *)createViewControllerByRouteParams:(NSMutableDictionary *)params
{
    Class controllerClass = params[@"controller_class"];
    NSString *storyboardName = params[@"storyboard_name"];

    
    NSString *route = params[@"route"];
    NSString *target = route;
    if (route && [route containsString:@"?"]) {
        target = [route componentsSeparatedByString:@"?"][0];
    }
    
    UIViewController *viewController;
    
    if (!controllerClass) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
        viewController = [storyboard instantiateViewControllerWithIdentifier:params[@"identifier"]];
    }else{
        viewController = [[controllerClass alloc] init];
    }

    BOOL validateResult = [viewController validateParams:params];
    [[NSNotificationCenter defaultCenter] postNotificationName:kPageRouteNotificationValidateResult object:nil userInfo:@{@"result":@(validateResult),@"paramsDict":[params copy]}];
    if (!validateResult) {
        return nil;
    }
    
    objc_setAssociatedObject(viewController, @selector(params), [params copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return viewController;
}

- (NSString *)stringFromFilterAppUrlScheme:(NSString *)string
{
    // 过滤一切scheme
    if ([string rangeOfString:@"://"].location != NSNotFound) {
        NSArray *pathSegments = [string componentsSeparatedByString:@"://"];
        NSString *appUrlScheme = pathSegments[0];
        string = [string substringFromIndex:appUrlScheme.length + 2];
    }
    return string;
}

- (NSArray *)appUrlSchemes
{
    NSMutableArray *appUrlSchemes = [NSMutableArray array];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    for (NSDictionary *dic in infoDictionary[@"CFBundleURLTypes"]) {
        NSString *appUrlScheme = dic[@"CFBundleURLSchemes"][0];
        [appUrlSchemes addObject:appUrlScheme];
    }
    
    return [appUrlSchemes copy];
}

#pragma mark - getter
- (NSMutableDictionary *)routes
{
    if (!_routes) {
        _routes = [[NSMutableDictionary alloc] init];
    }
    return _routes;
}

- (NSMutableDictionary<NSString *,NSMutableArray *> *)targetRoutes
{
    if (!_targetRoutes) {
        _targetRoutes = [[NSMutableDictionary alloc] init];
    }
    return _targetRoutes;
}

@end

#pragma mark - UIViewController Category

@implementation UIViewController (WTPageRouter)

- (NSDictionary *)params
{
    return objc_getAssociatedObject(self, @selector(params));
}

- (BOOL)validateParams:(NSDictionary *)params
{
    return YES;
}
@end
