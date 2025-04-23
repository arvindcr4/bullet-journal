#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN macro.
CAP_PLUGIN(ApplePencil, "ApplePencil",
           CAP_PLUGIN_METHOD(isSupported, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(isPaired, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(initializeCanvas, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(clearCanvas, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(saveDrawing, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(loadImage, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(setToolProperties, CAPPluginReturnPromise);
)