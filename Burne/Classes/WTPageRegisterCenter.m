//
//  WTPageRegisterCenter.m
//  Pods
//
//  Created by hongru qi on 2016/12/17.
//
//

#import "WTPageRegisterCenter.h"
#import "WTPageRouter.h"
//#import "YAMLSerialization.h"

@implementation WTPageRegisterCenter

+ (void)registerViewControllerConfig:(NSDictionary *)config
{
    [config enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *classKey = (NSString *)key;
        if ([obj isKindOfClass:[NSString class]]){
            NSString *className = (NSString *)obj;
            [[WTPageRouter instance] registerUrl:classKey toControllerClass:NSClassFromString(className)];
        }else if ([obj isKindOfClass:[NSDictionary class]]){
            NSString *storyboardName = (NSString*)obj[@"storyboard_name"];
            NSString *identifier = (NSString*)obj[@"identifier"];
            [[WTPageRouter instance] registerUrl:classKey storyboardName:storyboardName identifier:identifier];
        }
    }];
}

+ (void)loadPage
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSMutableArray  *knownBundleNames = [NSMutableArray array];
    NSMutableArray *bundles =  [NSMutableArray array];
    for (NSURL *subpath in [manager enumeratorAtURL:[[NSBundle mainBundle] bundleURL] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:nil]) {
        BOOL isDir;
        if ([manager fileExistsAtPath:subpath.path isDirectory:&isDir] && isDir) {
            
            NSString *bundleName = [subpath lastPathComponent];
            if ([bundleName hasSuffix:@".bundle"]) {
                [knownBundleNames addObject:[bundleName stringByReplacingOccurrencesOfString:@".bundle" withString:@""]];
                [bundles addObject:subpath.path];
            }
        }
    }
    

//    for (NSString *bundlePath in bundles) {
//         NSString *filePath = [[NSBundle bundleWithPath:bundlePath] pathForResource:@"route" ofType:@"yaml"];
//        if (!filePath) {
//            return;
//        }
//        NSInputStream *stream = [[NSInputStream alloc] initWithFileAtPath:filePath];
//        NSDictionary *routesDict = [YAMLSerialization objectWithYAMLStream:stream
//                                                                    options:kYAMLReadOptionStringScalars
//                                                                      error:nil];
//        for (NSString *className in routesDict) {
//            Class clss = NSClassFromString(className);
//            NSAssert(clss, @"Unkonw Class Name: %@", className);
//            if (clss) {
//                NSArray *routes;
//                if ([routesDict[className] isKindOfClass:[NSArray class]]) {
//                    routes = routesDict[className];
//                } else {
//                    NSDictionary *config = routesDict[className];
//                    routes = config[@"route"];
//                }
//                for (NSString *route in routes) {
//                    [[WTPageRouter instance] registerUrl:route toControllerClass:clss];
//                }
//            }
//        }
//    }
}

@end
