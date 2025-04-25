package com.Navi

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import cn.jpush.android.api.JPushInterface
import android.app.ActivityManager
import android.app.ActivityManager.RunningAppProcessInfo
import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.Process
import android.util.Log
import cn.jpush.android.api.BasicPushNotificationBuilder
import cn.jpush.android.api.CustomPushNotificationBuilder
import cn.jpush.android.api.JPushMessage
import com.xiaomi.channel.commonutils.logger.LoggerInterface
import com.xiaomi.mipush.sdk.Logger
import com.xiaomi.mipush.sdk.MiPushClient

// 移除workmanager相关配置
class NaviApplication : Application() {
    
    companion object {
        private const val TAG = "NaviApplication"
        const val CHANNEL_ID = "navi_push_channel"
        
        // 小米推送的AppID和AppKey（从开发者控制台获取）
        private const val MI_APP_ID = "2882303761520372137"
        private const val MI_APP_KEY = "5482037264137"
        
        // 获取RegID的辅助方法，可以在需要的地方调用
        fun getRegId(context: Context): String {
            val regId = MiPushClient.getRegId(context)
            Log.d(TAG, "当前RegID: ${if (regId.isNullOrEmpty()) "未注册" else regId}")
            return regId ?: ""
        }
    }
    
    override fun onCreate() {
        super.onCreate()
        
        // 创建通知渠道（Android 8.0+要求）
        createNotificationChannel()
        
        // 初始化JPush
        JPushInterface.setDebugMode(true) // 设置Debug模式，发布时请关闭
        JPushInterface.init(this)
        
        // 在Android 8.0+上手动关联极光推送与我们创建的通知渠道
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                // 设置极光推送使用我们创建的通知渠道
                JPushInterface.setChannel(this, CHANNEL_ID)
                Log.d(TAG, "关联极光推送与通知渠道: $CHANNEL_ID")
            } catch (e: Exception) {
                Log.e(TAG, "关联通知渠道失败: ${e.message}")
            }
        }
        
        // 配置JPush为允许保持长连接，提高推送到达率
        JPushInterface.setPowerSaveMode(this, true)
        
        // 启用自定义消息 - 这里不再调用setPushNotificationBuilder，改用setDefaultPushNotificationBuilder
        // JPushInterface.setPushNotificationBuilder(1, getCustomNotificationBuilder())
        
        // 使用基本通知构建器
        val basicBuilder = BasicPushNotificationBuilder(this)
        basicBuilder.statusBarDrawable = android.R.drawable.ic_dialog_info
        basicBuilder.notificationFlags = android.app.Notification.FLAG_AUTO_CANCEL
        // 设置通知提示音、振动和LED灯
        basicBuilder.notificationDefaults = android.app.Notification.DEFAULT_SOUND or 
                                          android.app.Notification.DEFAULT_VIBRATE or 
                                          android.app.Notification.DEFAULT_LIGHTS
        JPushInterface.setDefaultPushNotificationBuilder(basicBuilder)
        
        // 初始化小米推送，仅在主进程中初始化
        if (shouldInit()) {
            try {
                // 使用硬编码的正确AppID和AppKey
                Log.d(TAG, "小米推送初始化 - AppID: $MI_APP_ID, AppKey: $MI_APP_KEY")
                
                // 初始化小米推送
                MiPushClient.registerPush(this, MI_APP_ID, MI_APP_KEY)
                Log.d(TAG, "小米推送初始化完成")
                
                // 检查是否获取到RegID
                val regId = MiPushClient.getRegId(this)
                Log.d(TAG, "当前RegID: ${if (regId.isNullOrEmpty()) "尚未注册" else regId}")
                
            } catch (e: Exception) {
                Log.e(TAG, "初始化小米推送失败: ${e.message}", e)
            }
        } else {
            Log.d(TAG, "不是主进程，跳过小米推送初始化")
        }
        
        // 设置小米推送日志记录器，提高日志级别以便调试
        setupMiPushLogger()
    }
    
    // 检查是否是主进程，只在主进程初始化推送服务
    private fun shouldInit(): Boolean {
        val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val processInfos = am.runningAppProcesses
        val mainProcessName = applicationInfo.processName
        val myPid = Process.myPid()
        
        Log.d(TAG, "当前进程名: $mainProcessName, PID: $myPid")
        
        for (info in processInfos) {
            if (info.pid == myPid && mainProcessName == info.processName) {
                Log.d(TAG, "找到主进程，将初始化小米推送")
                return true
            }
        }
        
        Log.d(TAG, "不是主进程，不初始化小米推送")
        return false
    }
    
    private fun createNotificationChannel() {
        // Android 8.0+ 需要通知渠道
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Navi聊天通知"
            val descriptionText = "包含私聊和群聊消息的通知"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
                enableLights(true)
                enableVibration(true)
            }
            
            // 注册通知渠道
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
            Log.d(TAG, "通知渠道已创建: $CHANNEL_ID")
        }
    }
    
    private fun setupMiPushLogger() {
        try {
            // 设置小米推送日志为详细模式
            val logger = object : LoggerInterface {
                override fun setTag(tag: String) {
                    // 设置日志标签
                }
                
                override fun log(content: String, t: Throwable?) {
                    Log.e(TAG, content, t) // 使用Error级别以确保日志可见
                }
                
                override fun log(content: String) {
                    Log.e(TAG, content) // 使用Error级别以确保日志可见
                }
            }
            Logger.setLogger(this, logger)
            Log.d(TAG, "小米推送日志记录器设置成功")
        } catch (e: Exception) {
            Log.e(TAG, "设置小米推送日志记录器失败: ${e.message}")
        }
    }
} 