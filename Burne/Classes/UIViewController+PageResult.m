//
//  UIViewController+PageResult.m
//  Pods
//
//  Created by hongru qi on 2017/4/19.
//
//

#import "UIViewController+PageResult.h"
#import <objc/runtime.h>

@implementation UIViewController (PageResult)

- (void)setPageResult:(NSMutableDictionary *)pageResult
{
    objc_setAssociatedObject(self, @selector(pageResult), pageResult, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)pageResult
{
    NSMutableDictionary* pageResult = objc_getAssociatedObject(self, @selector(pageResult));
    if (pageResult == nil) {
        pageResult = [NSMutableDictionary dictionary];
        [self setPageResult:pageResult];
    }
    return pageResult;
}

- (void)setWTDelegate:(id)WTDelegate
{
    objc_setAssociatedObject(self, @selector(WTDelegate), WTDelegate, OBJC_ASSOCIATION_ASSIGN);
}

- (id<WTPageResultProtocol>)WTDelegate
{
    return objc_getAssociatedObject(self, @selector(WTDelegate));
}
@end
