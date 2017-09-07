//
//  UIViewController+PageResult.h
//  Pods
//
//  Created by hongru qi on 2017/4/19.
//
//

#import <UIKit/UIKit.h>
#import "WTPageResultProtocol.h"

@interface UIViewController (PageResult)

@property (nonatomic, weak) id<WTPageResultProtocol> WTDelegate;
@property (nonatomic, strong) NSMutableDictionary *pageResult;

@end
