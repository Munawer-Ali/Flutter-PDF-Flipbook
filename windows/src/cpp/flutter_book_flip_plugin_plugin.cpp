#include "flutter_book_flip_plugin_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <memory>

namespace flutter_book_flip_plugin {

class FlutterBookFlipPluginPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterBookFlipPluginPlugin();

  virtual ~FlutterBookFlipPluginPlugin();

  // Disallow copy and assign.
  FlutterBookFlipPluginPlugin(const FlutterBookFlipPluginPlugin&) = delete;
  FlutterBookFlipPluginPlugin& operator=(const FlutterBookFlipPluginPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

// static
void FlutterBookFlipPluginPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "flutter_book_flip_plugin",
          &flutter::StandardMethodCodec::instance());

  auto plugin = std::make_unique<FlutterBookFlipPluginPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

FlutterBookFlipPluginPlugin::FlutterBookFlipPluginPlugin() {}

FlutterBookFlipPluginPlugin::~FlutterBookFlipPluginPlugin() {}

void FlutterBookFlipPluginPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getPlatformVersion") == 0) {
    std::ostringstream version_stream;
    version_stream << "Windows ";
    result->Success(flutter::EncodableValue(version_stream.str()));
  } else {
    result->NotImplemented();
  }
}

}  // namespace flutter_book_flip_plugin

void FlutterBookFlipPluginRegisterWithRegistrar(
FlutterDesktopPluginRegistrarRef registrar) {
  flutter_book_flip_plugin::FlutterBookFlipPluginPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
