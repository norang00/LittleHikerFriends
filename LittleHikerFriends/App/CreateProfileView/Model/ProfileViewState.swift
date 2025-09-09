//
//  ProfileViewState.swift
//  LittleHikerFriends
//
//  Created by sungkug_apple_developer_ac on 9/7/25.
//
import UIKit

struct ProfileViewState: Equatable {
    var avatar: UIImage?
    var nickname: String
    var isDoneEnabled: Bool
    var nicknameHelper: String?  // "*6글자까지 가능합니다." 또는 에러 메시지
}
