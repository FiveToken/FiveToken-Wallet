package io.forcewallet.flotus

import wlib.Wlib;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** FlotusPlugin */
public class FlotusPlugin: FlutterPlugin, MethodCallHandler {
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flotus")
    channel.setMethodCallHandler(FlotusPlugin());
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
      val channel = MethodChannel(registrar.messenger(), "flotus")
      channel.setMethodCallHandler(FlotusPlugin())
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when {
      call.method == "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      call.method == "genAddress" -> {
        val pk = call.argument<String>("pk")
        val t = call.argument<String>("t")
        val res = Wlib.genAddress(pk, t)
        result.success(res)
      }
      call.method == "addressFromString" -> {
        val ad = call.argument<String>("ad")
        val res = Wlib.addressFromString(ad)
        result.success(res)
      }
      call.method == "messageCid" -> {
        val msg = call.argument<String>("msg")
        val res = Wlib.messageCid(msg)
        result.success(res)
      }
      call.method == "secpPrivateToPublic" -> {
        var ck = call.argument<String>("ck")
        var res = Wlib.secpPrivateToPublic(ck)
        result.success(res)
      }
      call.method == "secpSign" -> {
        var ck = call.argument<String>("ck")
        var msg = call.argument<String>("msg")
        var res = Wlib.secpSign(ck, msg)
        result.success(res)
      }
      call.method == "genConstructorParamV3" -> {
        var input = call.argument<String>("input")
        var res = Wlib.genConstructorParamV3(input)
        result.success(res)
      }
      call.method == "genProposeForSendParamV3" -> {
        var to = call.argument<String>("to")
        var value = call.argument<String>("value")
        var res = Wlib.genProposeForSendParamV3(to,value)
        result.success(res)
      }
      call.method == "genProposalForWithdrawBalanceV3" -> {
        var miner = call.argument<String>("miner")
        var value = call.argument<String>("value")
        var res = Wlib.genProposalForWithdrawBalanceV3(miner,value)
        result.success(res)
      }
      call.method == "genProposalForChangeOwnerV3" -> {
        var self = call.argument<String>("self")
        var miner = call.argument<String>("miner")
        var value = call.argument<String>("value")
        var res = Wlib.genProposalForChangeOwnerV3(self,miner,value)
        result.success(res)
      }
      call.method == "genProposalForChangeWorkerAddress" -> {
        var miner = call.argument<String>("miner")
        var value = call.argument<String>("value")
        var res = Wlib.genProposalForChangeWorkerAddress(miner,value)
        result.success(res)
      }
      call.method == "genApprovalV3" -> {
        var tx = call.argument<String>("tx")
        var res = Wlib.genApprovalV3(tx)
        result.success(res)
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }
}
