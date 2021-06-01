#import "FlotusPlugin.h"
#if __has_include(<flotus/flotus-Swift.h>)
#import <flotus/flotus-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flotus-Swift.h"
#endif

@implementation FlotusPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlotusPlugin registerWithRegistrar:registrar];
}
@end
