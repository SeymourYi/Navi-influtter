package com.Navi

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import androidx.annotation.NonNull
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Bundle
import android.util.Log
import org.json.JSONObject
import androidx.core.view.WindowCompat
import android.view.View
import android.view.WindowManager

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.Navi/push_notification"
    private var notificationData: HashMap<String, Any>? = null
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("MainActivity", "onCreate方法被调用，应用启动中")
        
        // 启用边缘到边缘模式，让应用内容可以延伸到系统导航栏下方
        WindowCompat.setDecorFitsSystemWindows(window, false)
        
        // 设置窗口标志，让内容可以显示在系统栏后面
        window.setFlags(
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
        )
        
        // 检查是否由通知启动
        handleNotificationIntent(intent)
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        Log.d("MainActivity", "onNewIntent方法被调用，有新的Intent")
        // 处理新的Intent（当应用已经在运行时）
        handleNotificationIntent(intent)
    }
    
    private fun handleNotificationIntent(intent: Intent) {
        try {
            Log.d("MainActivity", "处理Intent: action=${intent.action}, 是否有extra=${intent.extras != null}")
            
            // 检查是否有极光推送相关的数据
            if (intent.extras != null) {
                val extras = intent.extras
                val jpushBundle = extras?.getBundle("cn.jpush.android.EXTRA")
                val jpushMessage = extras?.getString("cn.jpush.android.MESSAGE")
                val jpushAlert = extras?.getString("cn.jpush.android.ALERT")
                val jpushTitle = extras?.getString("cn.jpush.android.NOTIFICATION_CONTENT_TITLE")
                
                Log.d("MainActivity", "极光推送字段检查: EXTRA=${jpushBundle != null}, MESSAGE=${jpushMessage != null}, ALERT=${jpushAlert != null}, TITLE=${jpushTitle != null}")
                
                if (jpushMessage != null || jpushAlert != null || jpushTitle != null || jpushBundle != null) {
                    Log.d("MainActivity", "检测到极光推送消息，准备提取数据")
                    notificationData = HashMap<String, Any>()
                    
                    // 提取各种可能的字段
                    if (jpushBundle != null) {
                        notificationData!!["cn.jpush.android.EXTRA"] = bundleToMap(jpushBundle)
                    }
                    
                    if (jpushMessage != null) {
                        notificationData!!["cn.jpush.android.MESSAGE"] = jpushMessage
                        // 尝试解析jpushMessage中的JSON数据
                        try {
                            val jsonObject = JSONObject(jpushMessage)
                            if (jsonObject.has("username")) {
                                notificationData!!["username"] = jsonObject.getString("username")
                                Log.d("MainActivity", "从MESSAGE提取到username: ${jsonObject.getString("username")}")
                            }
                            if (jsonObject.has("senderId")) {
                                notificationData!!["senderId"] = jsonObject.getString("senderId")
                                Log.d("MainActivity", "从MESSAGE提取到senderId: ${jsonObject.getString("senderId")}")
                            }
                            if (jsonObject.has("type") && jsonObject.getString("type") == "chat") {
                                notificationData!!["type"] = "chat"
                                Log.d("MainActivity", "从MESSAGE确认消息类型: chat")
                            }
                        } catch (e: Exception) {
                            Log.e("MainActivity", "解析MESSAGE JSON失败: ${e.message}")
                        }
                    }
                    
                    if (jpushAlert != null) {
                        notificationData!!["cn.jpush.android.ALERT"] = jpushAlert
                        Log.d("MainActivity", "提取到通知内容: $jpushAlert")
                    }
                    
                    if (jpushTitle != null) {
                        notificationData!!["cn.jpush.android.NOTIFICATION_CONTENT_TITLE"] = jpushTitle
                        Log.d("MainActivity", "提取到通知标题: $jpushTitle")
                    }
                    
                    // 获取其他可能的字段
                    extras?.keySet()?.forEach { key ->
                        if (key.startsWith("cn.jpush.android") && extras.get(key) != null) {
                            val value = extras.get(key).toString()
                            notificationData!![key] = value
                            Log.d("MainActivity", "提取到其他极光字段: $key = $value")
                        }
                    }
                    
                    Log.d("MainActivity", "提取的通知数据完成: ${notificationData?.size}个字段")
                }
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "处理通知Intent错误: ${e.message}", e)
        }
    }
    
    private fun bundleToMap(bundle: Bundle): Map<String, Any> {
        val map = HashMap<String, Any>()
        try {
            bundle.keySet().forEach { key ->
                bundle.get(key)?.let { 
                    map[key] = it 
                    Log.d("MainActivity", "从Bundle提取: $key = $it")
                }
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "Bundle转Map失败: ${e.message}", e)
        }
        return map
    }
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // 适配Flutter插件注册
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        
        // 额外打印通知数据的日志
        if (notificationData != null && notificationData!!.isNotEmpty()) {
            Log.d("MainActivity", "Flutter引擎配置时有通知数据: ${notificationData?.size}个字段")
        } else {
            Log.d("MainActivity", "Flutter引擎配置时无通知数据")
        }
        
        // 设置方法通道
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "getInitialNotification" -> {
                        Log.d("MainActivity", "Flutter请求获取通知数据: ${notificationData?.size}个字段")
                        result.success(notificationData)
                        
                        // 成功返回后清除数据，防止重复处理
                        if (notificationData != null) {
                            Log.d("MainActivity", "清除通知数据")
                            notificationData = null
                        }
                    }
                    "initializePushIfNeeded" -> {
                        try {
                            val initialized = (application as? NaviApplication)?.initializePushIfPermitted("flutter_channel")
                            Log.d("MainActivity", "收到Flutter推送初始化请求，结果: $initialized")
                            result.success(initialized)
                        } catch (e: Exception) {
                            Log.e("MainActivity", "推送初始化请求失败: ${e.message}", e)
                            result.error("INIT_ERROR", e.message, null)
                        }
                    }
                    else -> {
                        Log.d("MainActivity", "未实现的方法: ${call.method}")
                        result.notImplemented()
                    }
                }
            } catch (e: Exception) {
                Log.e("MainActivity", "处理方法调用错误: ${e.message}", e)
                result.error("ERROR", "方法调用处理错误: ${e.message}", null)
            }
        }
    }
} 