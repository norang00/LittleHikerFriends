//
//  NicknameValidator.swift
//  LittleHikerFriends
//
//  Created by sungkug_apple_developer_ac on 9/7/25.
//

enum NicknameValidator {
    static func validate(_ text: String) -> (valid: Bool, helper: String?) {
        if text.isEmpty { return (false, "*6글자까지 가능합니다.") }
        if text.count > 6 { return (false, "닉네임은 6자 이내여야 합니다.") }
        return (true, nil)
    }
}
