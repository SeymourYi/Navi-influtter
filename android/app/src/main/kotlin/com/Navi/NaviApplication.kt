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
import android.os.Handler
import android.os.Looper
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
            Log.e(TAG, "【小米推送】当前RegID: ${if (regId.isNullOrEmpty()) "未注册" else regId}")
            return regId ?: ""
        }
        
        // 为小米推送设置别名
        fun setMiPushAlias(context: Context, alias: String) {
            try {
                Log.e(TAG, "【小米推送】正在设置别名: $alias")
                MiPushClient.setAlias(context, alias, null)
            } catch (e: Exception) {
                Log.e(TAG, "【小米推送】设置别名失败: ${e.message}", e)
            }
        }
    }
    
    override fun onCreate() {
        super.onCreate()
        
        // 在应用启动时立即输出明显的日志标记
        printSeparator("应用启动")
        
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
        printSeparator("开始初始化小米推送")
        if (shouldInit()) {
            try {
                // 使用硬编码的正确AppID和AppKey
                Log.e(TAG, "【小米推送】准备初始化 - AppID: $MI_APP_ID, AppKey: $MI_APP_KEY")
                
                // 初始化小米推送
                MiPushClient.registerPush(this, MI_APP_ID, MI_APP_KEY)
                Log.e(TAG, "【小米推送】初始化API调用完成，等待结果...")
                
                // 定时查询RegID
                scheduleRegIdCheck()
                
                // 立即检查一次RegID
                printCurrentRegId()
                
                // 监听极光设置的别名并同步到小米推送
                monitorJPushAlias()
                
            } catch (e: Exception) {
                Log.e(TAG, "【小米推送】初始化失败: ${e.message}", e)
            }
        } else {
            Log.e(TAG, "【小米推送】不是主进程，跳过初始化")
        }
        
        // 设置小米推送日志记录器，提高日志级别以便调试
        setupMiPushLogger()
    }
    
    // 监听极光设置的别名并同步到小米推送
    private fun monitorJPushAlias() {
        val handler = Handler(Looper.getMainLooper())
        handler.postDelayed({
            try {
                // 从SharedPreferences获取极光别名
                val sharedPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val jpushAlias = sharedPrefs.getString("flutter.alias", "")
                
                // 如果获取到极光别名，并且不为空，则设置给小米推送
                if (!jpushAlias.isNullOrEmpty()) {
                    // 先清除旧别名
                    MiPushClient.unsetAlias(this, null, null)
                    // 延迟1秒后设置新别名，确保清除操作完成
                    handler.postDelayed({
                        setMiPushAlias(this, jpushAlias)
                        Log.e(TAG, "【推送同步】已将极光别名 '$jpushAlias' 同步设置到小米推送")
                    }, 1000)
                } else {
                    // 尝试获取极光默认别名（这里假设极光别名可能是用户ID）
                    val userId = "2222" // 替换为实际获取用户ID的逻辑
                    if (!userId.isNullOrEmpty()) {
                        // 先清除旧别名
                        MiPushClient.unsetAlias(this, null, null)
                        // 延迟1秒后设置新别名
                        handler.postDelayed({
                            setMiPushAlias(this, userId)
                            Log.e(TAG, "【推送同步】未找到极光别名，已将用户ID '$userId' 设置为小米推送别名")
                        }, 1000)
                    } else {
                        Log.e(TAG, "【推送同步】无法获取极光别名或用户ID")
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "【推送同步】同步别名时发生错误: ${e.message}", e)
            }
        }, 5000) // 5秒后执行，确保极光推送别名已设置
    }
    
    // 定时查询RegID
    private fun scheduleRegIdCheck() {
        val handler = Handler(Looper.getMainLooper())
        
        // 5秒后查询RegID
        handler.postDelayed({
            printCurrentRegId()
        }, 5000)
        
        // 10秒后再次查询RegID
        handler.postDelayed({
            printCurrentRegId()
        }, 10000)
        
        // 30秒后再次查询RegID
        handler.postDelayed({
            printCurrentRegId()
        }, 30000)
    }
    
    // 打印当前RegID
    private fun printCurrentRegId() {
        try {
            val regId = MiPushClient.getRegId(this)
            if (!regId.isNullOrEmpty()) {
                printSeparator("小米推送RegID")
                Log.e(TAG, "【小米推送】RegID 获取成功：$regId")
                printSeparator("RegID结束")
            } else {
                Log.e(TAG, "【小米推送】RegID 尚未获取")
            }
        } catch (e: Exception) {
            Log.e(TAG, "【小米推送】获取RegID异常: ${e.message}", e)
        }
    }
    
    // 打印分隔符，使日志更醒目
    private fun printSeparator(message: String) {
        Log.e(TAG, "===================================================")
        Log.e(TAG, "============ $message ============")
        Log.e(TAG, "===================================================")
    }
    
    // 检查是否是主进程，只在主进程初始化推送服务
    private fun shouldInit(): Boolean {
        val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val processInfos = am.runningAppProcesses
        val mainProcessName = applicationInfo.processName
        val myPid = Process.myPid()
        
        Log.e(TAG, "【进程检查】当前进程名: $mainProcessName, PID: $myPid")
        
        for (info in processInfos) {
            if (info.pid == myPid && mainProcessName == info.processName) {
                Log.e(TAG, "【进程检查】找到主进程，将初始化小米推送")
                return true
            }
        }
        
        Log.e(TAG, "【进程检查】不是主进程，不初始化小米推送")
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
                    Log.e(TAG, "【小米推送日志】$content", t) // 使用Error级别以确保日志可见
                }
                
                override fun log(content: String) {
                    Log.e(TAG, "【小米推送日志】$content") // 使用Error级别以确保日志可见
                }
            }
            Logger.setLogger(this, logger)
            Log.e(TAG, "【小米推送】日志记录器设置成功")
        } catch (e: Exception) {
            Log.e(TAG, "【小米推送】设置日志记录器失败: ${e.message}")
        }
    }
} 