#import "AppLoggerPlugin.h"
#if __has_include(<app_logger/app_logger-Swift.h>)
#import <app_logger/app_logger-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "app_logger-Swift.h"
#endif

@implementation AppLoggerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAppLoggerPlugin registerWithRegistrar:registrar];
}
@end
