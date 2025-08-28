package com.studymate.studymate_flutter

import android.content.Context
import android.text.InputType
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import io.flutter.plugin.common.MethodChannel

class KoreanInputHelper(private val context: Context) {
    
    fun configureEditTextForKorean(editText: EditText) {
        // 한글 입력을 위한 EditText 설정
        editText.apply {
            // 입력 타입을 텍스트로 설정
            inputType = InputType.TYPE_CLASS_TEXT or 
                       InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS
            
            // IME 옵션 설정
            imeOptions = EditorInfo.IME_FLAG_NO_EXTRACT_UI or
                        EditorInfo.IME_FLAG_NO_FULLSCREEN
            
            // 개인화 학습 비활성화 (한글 입력에 영향을 줄 수 있음)
            privateImeOptions = "nm=1"
        }
    }
    
    fun showKeyboard(editText: EditText) {
        val imm = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        editText.requestFocus()
        imm.showSoftInput(editText, InputMethodManager.SHOW_IMPLICIT)
    }
    
    fun hideKeyboard(editText: EditText) {
        val imm = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        imm.hideSoftInputFromWindow(editText.windowToken, 0)
    }
}