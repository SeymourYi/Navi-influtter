package com.Navi

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import androidx.annotation.NonNull
import android.os.Bundle
import android.util.Log
import androidx.core.view.WindowCompat
import android.view.WindowManager

class MainActivity : FlutterActivity() {
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
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Register plugins with Flutter Engine (v2 embedding)
        // This is the v2 way - using FlutterEngine parameter
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
} 