//
//  LoginButtonType.swift
//  LittleHikerFriends
//
//  Created by sungkug_apple_developer_ac on 8/23/25.
//

enum LoginButtonType: String {
    case apple = "애플로그인버튼"
    case kakao = "카카오로그인버튼"
    
    var imageName: String {
        rawValue
    }
}
