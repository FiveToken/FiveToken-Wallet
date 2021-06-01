package io.forcewallet.bls

import io.forcewallet.wtools.*

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** BlsPlugin */
public class BlsPlugin: FlutterPlugin, MethodCallHandler {
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "bls")
    channel.setMethodCallHandler(BlsPlugin());
    loadWtoolsLib()
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "bls")
      channel.setMethodCallHandler(BlsPlugin())
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when {
      call.method == "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      call.method == "pkgen" -> {
        val num = call.argument<String>("num")
        if (num == null) {
          result.success("")
        } else {
          // we're using the helloDirect function here
          // but you could also use the hello function, too.
          var res = pkgen(num)
          result.success(res)
        }
      }
      call.method == "ckgen" -> {
        val num = call.argument<String>("num")
        if (num == null) {
          result.success("")
        } else {
          // we're using the helloDirect function here
          // but you could also use the hello function, too.
          val res = ckgen(num)
          result.success(res)
        }
      }
      call.method == "cksign" -> {
        val num = call.argument<String>("num")
        if (num == null) {
          result.success("")
        } else {
          // we're using the helloDirect function here
          // but you could also use the hello function, too.
          val res = cksign(num)
          result.success(res)
        }
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }
}
