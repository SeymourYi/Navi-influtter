package com.Navi

import cn.jpush.android.api.JPushMessage
import cn.jpush.android.api.NotificationMessage
import cn.jpush.android.api.CmdMessage
import cn.jpush.android.api.CustomMessage
import cn.jpush.android.service.JPushMessageReceiver
import android.content.Context
import android.util.Log
import android.content.Intent
import android.os.Bundle

class JpushReceiver : JPushMessageReceiver() {
    private val TAG = "JpushReceiver"

    override fun onTagOperatorResult(context: Context, jPushMessage: JPushMessage) {
        Log.d(TAG, "onTagOperatorResult: ${jPushMessage.toString()}")
        super.onTagOperatorResult(context, jPushMessage)
    }

    override fun onCheckTagOperatorResult(context: Context, jPushMessage: JPushMessage) {
        Log.d(TAG, "onCheckTagOperatorResult: ${jPushMessage.toString()}")
        super.onCheckTagOperatorResult(context, jPushMessage)
    }

    override fun onAliasOperatorResult(context: Context, jPushMessage: JPushMessage) {
        Log.d(TAG, "onAliasOperatorResult: ${jPushMessage.toString()}")
        super.onAliasOperatorResult(context, jPushMessage)
    }

    override fun onMobileNumberOperatorResult(context: Context, jPushMessage: JPushMessage) {
        Log.d(TAG, "onMobileNumberOperatorResult: ${jPushMessage.toString()}")
        super.onMobileNumberOperatorResult(context, jPushMessage)
    }
    
    // 处理通知消息，应用被杀死后会通过此方法接收推送
    override fun onNotifyMessageArrived(context: Context, notificationMessage: NotificationMessage) {
        Log.d(TAG, "收到通知消息(应用运行/后台/被杀死): ${notificationMessage.notificationContent}")
        super.onNotifyMessageArrived(context, notificationMessage)
    }
    
    // 点击通知栏消息时触发，可以在这里实现自定义跳转逻辑
    override fun onNotifyMessageOpened(context: Context, notificationMessage: NotificationMessage) {
        Log.d(TAG, "通知被点击: ${notificationMessage.notificationContent}")
        
        try {
            // 如果应用被杀死，点击通知时需要启动应用
            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (launchIntent != null) {
                launchIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                
                // 将通知数据传递给应用
                val bundle = Bundle()
                bundle.putString("messageType", "notification")
                bundle.putString("title", notificationMessage.notificationTitle)
                bundle.putString("content", notificationMessage.notificationContent)
                
                // 如果有额外数据，也传递
                if (notificationMessage.notificationExtras != null) {
                    bundle.putString("extras", notificationMessage.notificationExtras)
                }
                
                launchIntent.putExtras(bundle)
                context.startActivity(launchIntent)
            }
        } catch (e: Exception) {
            Log.e(TAG, "处理通知点击事件失败: ${e.message}")
        }
        
        super.onNotifyMessageOpened(context, notificationMessage)
    }
    
    // 接收自定义消息
    override fun onMessage(context: Context, customMessage: CustomMessage) {
        Log.d(TAG, "收到自定义消息: ${customMessage.message}")
        super.onMessage(context, customMessage)
    }
    
    // 接收命令消息
    override fun onCommandResult(context: Context, cmdMessage: CmdMessage) {
        Log.d(TAG, "收到命令结果: ${cmdMessage.cmd}")
        super.onCommandResult(context, cmdMessage)
    }
    
    // 连接状态变化
    override fun onConnected(context: Context, isConnected: Boolean) {
        Log.d(TAG, "JPush连接状态: $isConnected")
        super.onConnected(context, isConnected)
    }
} 