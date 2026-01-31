#import "FlutterUsabillaPlugin.h"
#if __has_include(<flutter_usabilla/flutter_usabilla-Swift.h>)
#import <flutter_usabilla/flutter_usabilla-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_usabilla-Swift.h"
#endif

@implementation FlutterUsabillaPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterUsabillaPlugin registerWithRegistrar:registrar];
}
@end
