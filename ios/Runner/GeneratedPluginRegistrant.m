//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<modal_progress_hud_nsn/ModalProgressHudNsnPlugin.h>)
#import <modal_progress_hud_nsn/ModalProgressHudNsnPlugin.h>
#else
@import modal_progress_hud_nsn;
#endif

#if __has_include(<shared_preferences_ios/FLTSharedPreferencesPlugin.h>)
#import <shared_preferences_ios/FLTSharedPreferencesPlugin.h>
#else
@import shared_preferences_ios;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [ModalProgressHudNsnPlugin registerWithRegistrar:[registry registrarForPlugin:@"ModalProgressHudNsnPlugin"]];
  [FLTSharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTSharedPreferencesPlugin"]];
}

@end
