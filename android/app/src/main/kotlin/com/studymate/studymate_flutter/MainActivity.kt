package com.studymate.studymate_flutter

import android.os.Bundle
import android.view.WindowManager
import android.view.inputmethod.InputMethodManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.studymate/korean_input"
    private lateinit var koreanInputHelper: KoreanInputHelper
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 한글 입력을 위한 소프트 키보드 모드 설정
        window.setSoftInputMode(
            WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE or
            WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN
        )
        
        koreanInputHelper = KoreanInputHelper(this)
        
        // 플랫폼 채널 설정
        flutterEngine?.dartExecutor?.let {
            MethodChannel(it.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
                when (call.method) {
                    "enableKoreanInput" -> {
                        // 한글 입력 활성화 로직
                        result.success(true)
                    }
                    "checkIME" -> {
                        // 현재 IME 상태 확인
                        val imm = getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
                        val list = imm.enabledInputMethodList
                        val imeInfo = list.map { it.packageName }
                        result.success(imeInfo.toString())
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
        }
    }
}
