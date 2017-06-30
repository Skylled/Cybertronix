//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"
#import <firebase_storage/FirebaseStoragePlugin.h>
#import <image_picker/ImagePickerPlugin.h>
#import <path_provider/PathProviderPlugin.h>
#import <share/SharePlugin.h>
#import <url_launcher/UrlLauncherPlugin.h>

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FirebaseStoragePlugin registerWithRegistrar:[registry registrarForPlugin:@"FirebaseStoragePlugin"]];
  [ImagePickerPlugin registerWithRegistrar:[registry registrarForPlugin:@"ImagePickerPlugin"]];
  [PathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"PathProviderPlugin"]];
  [SharePlugin registerWithRegistrar:[registry registrarForPlugin:@"SharePlugin"]];
  [UrlLauncherPlugin registerWithRegistrar:[registry registrarForPlugin:@"UrlLauncherPlugin"]];
}

@end
