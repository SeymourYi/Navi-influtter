package com.Navi

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.util.Log
import android.widget.Toast
import com.xiaomi.mipush.sdk.ErrorCode
import com.xiaomi.mipush.sdk.MiPushClient
import com.xiaomi.mipush.sdk.MiPushCommandMessage
import com.xiaomi.mipush.sdk.MiPushMessage
import com.xiaomi.mipush.sdk.PushMessageReceiver

class DemoMessageReceiver : PushMessageReceiver() {
    private val TAG = "MiPushReceiver"
    private var mRegId: String? = null
    private var mResultCode: Long = -1
    private var mReason: String? = null
    private var mCommand: String? = null
    private var mMessage: String? = null
    private var mTopic: String? = null
    private var mAlias: String? = null
    private var mUserAccount: String? = null
    private var mStartTime: String? = null
    private var mEndTime: String? = null
    private val handler = Handler(Looper.getMainLooper())

    // 安全地在UI线程显示Toast
    private fun showToast(context: Context, message: String) {
        handler.post {
            try {
                Toast.makeText(context, message, Toast.LENGTH_LONG).show()
            } catch (e: Exception) {
                Log.e(TAG, "显示Toast失败: ${e.message}", e)
            }
        }
    }

    override fun onNotificationMessageClicked(context: Context, message: MiPushMessage) {
        mMessage = message.content
        when {
            !TextUtils.isEmpty(message.topic) -> {
                mTopic = message.topic
            }
            !TextUtils.isEmpty(message.alias) -> {
                mAlias = message.alias
            }
            !TextUtils.isEmpty(message.userAccount) -> {
                mUserAccount = message.userAccount
            }
        }
        Log.d(TAG, "用户点击了通知: $mMessage")
        showToast(context, "点击通知: $mMessage")
    }

    override fun onNotificationMessageArrived(context: Context, message: MiPushMessage) {
        mMessage = message.content
        when {
            !TextUtils.isEmpty(message.topic) -> {
                mTopic = message.topic
            }
            !TextUtils.isEmpty(message.alias) -> {
                mAlias = message.alias
            }
            !TextUtils.isEmpty(message.userAccount) -> {
                mUserAccount = message.userAccount
            }
        }
        Log.d(TAG, "收到通知: $mMessage")
        showToast(context, "收到通知: $mMessage")
    }

    override fun onCommandResult(context: Context, message: MiPushCommandMessage) {
        val command = message.command
        val arguments = message.commandArguments
        val cmdArg1 = if (arguments != null && arguments.size > 0) arguments[0] else null
        val cmdArg2 = if (arguments != null && arguments.size > 1) arguments[1] else null
        
        when (command) {
            MiPushClient.COMMAND_REGISTER -> {
                if (message.resultCode == ErrorCode.SUCCESS.toLong()) {
                    mRegId = cmdArg1
                    Log.d(TAG, "注册成功，RegID: $mRegId")
                    showToast(context, "小米推送注册成功，RegID: $mRegId")
                } else {
                    Log.e(TAG, "注册失败，错误码: ${message.resultCode}")
                    showToast(context, "小米推送注册失败，错误码: ${message.resultCode}")
                }
            }
            MiPushClient.COMMAND_SET_ALIAS -> {
                if (message.resultCode == ErrorCode.SUCCESS.toLong()) {
                    mAlias = cmdArg1
                    Log.d(TAG, "别名设置成功，Alias: $mAlias")
                    showToast(context, "别名设置成功: $mAlias")
                } else {
                    Log.e(TAG, "别名设置失败，错误码: ${message.resultCode}")
                }
            }
            MiPushClient.COMMAND_UNSET_ALIAS -> {
                if (message.resultCode == ErrorCode.SUCCESS.toLong()) {
                    mAlias = cmdArg1
                    Log.d(TAG, "别名移除成功，Alias: $mAlias")
                }
            }
            MiPushClient.COMMAND_SUBSCRIBE_TOPIC -> {
                if (message.resultCode == ErrorCode.SUCCESS.toLong()) {
                    mTopic = cmdArg1
                    Log.d(TAG, "订阅主题成功，Topic: $mTopic")
                }
            }
            MiPushClient.COMMAND_UNSUBSCRIBE_TOPIC -> {
                if (message.resultCode == ErrorCode.SUCCESS.toLong()) {
                    mTopic = cmdArg1
                    Log.d(TAG, "取消订阅主题成功，Topic: $mTopic")
                }
            }
            MiPushClient.COMMAND_SET_ACCEPT_TIME -> {
                if (message.resultCode == ErrorCode.SUCCESS.toLong()) {
                    mStartTime = cmdArg1
                    mEndTime = cmdArg2
                    Log.d(TAG, "设置接收时间成功，StartTime: $mStartTime, EndTime: $mEndTime")
                }
            }
        }
    }

    override fun onReceiveRegisterResult(context: Context, message: MiPushCommandMessage) {
        val command = message.command
        val arguments = message.commandArguments
        val cmdArg1 = if (arguments != null && arguments.size > 0) arguments[0] else null
        
        if (MiPushClient.COMMAND_REGISTER == command) {
            if (message.resultCode == ErrorCode.SUCCESS.toLong()) {
                mRegId = cmdArg1
                Log.d(TAG, "注册成功，RegID: $mRegId")
                // 将RegID保存起来，方便查看
                showToast(context, "小米推送注册成功，RegID: $mRegId")
            } else {
                Log.e(TAG, "注册失败，错误码: ${message.resultCode}, 原因: ${message.reason}")
                showToast(context, "小米推送注册失败，错误码: ${message.resultCode}")
            }
        }
    }
} 