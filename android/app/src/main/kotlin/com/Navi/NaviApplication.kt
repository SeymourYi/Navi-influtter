package com.Navi

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import cn.jpush.android.api.JPushInterface
import android.app.Application
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
        
        // 不需要硬编码小米推送的appId和appKey，因为已经在build.gradle.kts的manifestPlaceholders中设置
    }
    
    override fun onCreate() {
        super.onCreate()
        
        // 初始化JPush
        JPushInterface.setDebugMode(true) // 设置Debug模式，发布时请关闭
        JPushInterface.init(this)
        
        // 配置JPush为允许保持长连接，提高推送到达率
        JPushInterface.setPowerSaveMode(this, true)
        
        // 自定义通知样式（可选）
        val builder = BasicPushNotificationBuilder(this)
        builder.statusBarDrawable = android.R.drawable.ic_dialog_info
        builder.notificationFlags = android.app.Notification.FLAG_AUTO_CANCEL
        JPushInterface.setDefaultPushNotificationBuilder(builder)
        
        // 小米推送已通过极光SDK自动初始化，无需手动初始化
        // 只需要设置日志记录器即可
        setupMiPushLogger()
    }
    
    private fun setupMiPushLogger() {
        try {
            // 设置小米推送日志
            val logger = object : LoggerInterface {
                override fun setTag(tag: String) {
                    // 设置日志标签
                }
                
                override fun log(content: String, t: Throwable?) {
                    Log.d(TAG, content)
                }
                
                override fun log(content: String) {
                    Log.d(TAG, content)
                }
            }
            Logger.setLogger(this, logger)
            Log.d(TAG, "小米推送日志记录器设置成功")
        } catch (e: Exception) {
            Log.e(TAG, "设置小米推送日志记录器失败: ${e.message}")
        }
    }
} 