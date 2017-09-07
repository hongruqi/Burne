//
//  WTPageRouter.h
//  Pods
//
//  Created by hongru qi on 2016/12/17.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString * const kPageRouteNotificationValidateResult;

typedef id (^WTPageRouterBlock)(NSDictionary *params);

@interface WTPageRouter : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSString *,NSMutableArray *> *targetRoutes;

+ (instancetype)instance;

+ (void)enableScheme:(BOOL)enable;

- (void)registerUrl:(NSString *)route storyboardName:(NSString *)storyboardName identifier:(NSString *)identifier;
- (void)registerUrl:(NSString *)route toControllerClass:(Class)controllerClass;
- (void)registerUrl:(NSString *)route toAction:(WTPageRouterBlock)block;

- (UIViewController *)matchControllerUrl:(NSString *)route;
- (UIViewController *)matchControllerDict:(NSDictionary *)dict;

- (id)executeActionUrl:(NSString *)route;
- (id)executeActionDict:(NSDictionary *)dict;

@end

///--------------------------------
/// @name UIViewController Category
///--------------------------------

@interface UIViewController (WTPageRouter)

@property (nonatomic, strong, readonly) NSDictionary *params;

// TODO: maybe we need a validate params or mapping params method
- (BOOL)validateParams:(NSDictionary *)params;

@end
