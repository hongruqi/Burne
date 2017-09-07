//
//  WTPageResultProtocol.h
//  Pods
//
//  Created by hongru qi on 2016/12/17.
//
//

#import <Foundation/Foundation.h>

@protocol WTPageResultProtocol <NSObject>

- (void)WT_target:(NSString *)target didFinishWithResult:(NSDictionary *)result;

@end
