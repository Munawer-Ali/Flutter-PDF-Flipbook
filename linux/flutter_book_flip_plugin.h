#ifndef FLOOD_WIDGET_PLUGIN_H_
#define FLOOD_WIDGET_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

#ifdef FLOOD_WIDGET_PLUGIN_IMPL
#define FLOOD_WIDGET_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define FLOOD_WIDGET_PLUGIN_EXPORT
#endif

typedef struct _FlutterBookFlipPlugin FlutterBookFlipPlugin;
typedef struct _FlutterBookFlipPluginClass FlutterBookFlipPluginClass;

FLOOD_WIDGET_PLUGIN_EXPORT GType flutter_book_flip_plugin_get_type(void);

FLOOD_WIDGET_PLUGIN_EXPORT void flutter_book_flip_plugin_register_with_registrar(FlutterEngineRegistrar* registrar);

G_END_DECLS

#endif  // FLOOD_WIDGET_PLUGIN_H_
