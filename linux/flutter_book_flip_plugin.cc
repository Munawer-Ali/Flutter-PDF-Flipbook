#include "flood_widget_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>
#include <cstring>

#include "flutter/shell/platform/linux/client_wrapper/include/flutter_plugin_registrar.h"
#include "flutter/shell/platform/linux/flutter_linux_gl.h"
#include "flutter/shell/platform/linux/public/flutter_linux/fl_flutter.h"
#include "flutter/shell/platform/linux/public/flutter_linux/fl_method_call.h"
#include "flutter/shell/platform/linux/public/flutter_linux/fl_method_response.h"
#include "flutter/shell/platform/linux/public/flutter_linux/fl_plugin_registrar.h"
#include "flutter/shell/platform/linux/public/flutter_linux/fl_standard_method_codec.h"

#define FLOOD_WIDGET_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), flutter_book_flip_plugin_get_type(), \
                              FlutterBookFlipPlugin))

struct _FlutterBookFlipPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(FlutterBookFlipPlugin, flutter_book_flip_plugin, g_object_get_type())

// Called when a method call is received from Dart.
static void flutter_book_flip_plugin_handle_method_call(
    FlutterBookFlipPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "getPlatformVersion") == 0) {
    struct utsname uname_data = {};
    uname(&uname_data);
    g_autofree gchar *version = g_strdup_printf("Linux %s", uname_data.version);
    g_autoptr(FlValue) result = fl_value_new_string(version);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void flutter_book_flip_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(flutter_book_flip_plugin_parent_class)->dispose(object);
}

static void flutter_book_flip_plugin_class_init(FlutterBookFlipPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = flutter_book_flip_plugin_dispose;
}

static void flutter_book_flip_plugin_init(FlutterBookFlipPlugin* self) {}

static void flutter_book_flip_plugin_register_with_registrar(FlutterPluginRegistrar* registrar) {
  FlutterBookFlipPlugin* plugin = flutter_book_flip_plugin_new();

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "flutter_book_flip_plugin",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                           g_object_ref(plugin),
                                           g_object_unref);

  g_object_unref(plugin);
}

static FlMethodResponse* method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                                       gpointer user_data) {
  FlutterBookFlipPlugin* plugin = FLOOD_WIDGET_PLUGIN(user_data);
  flutter_book_flip_plugin_handle_method_call(plugin, method_call);
  return nullptr;
}
