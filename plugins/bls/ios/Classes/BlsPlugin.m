#import "BlsPlugin.h"
#if __has_include(<bls/bls-Swift.h>)
#import <bls/bls-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "bls-Swift.h"
#endif

@implementation BlsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBlsPlugin registerWithRegistrar:registrar];
}
@end
