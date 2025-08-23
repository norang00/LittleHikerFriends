//
//  AppUser.swift
//  LittleHikerFriends
//
//  Created by sungkug_apple_developer_ac on 8/23/25.
//

import Foundation

// TODO: 임시 유저
struct AppUser: Codable, Equatable {
    let id: String
    var nickname: String
    var image: String?
    var groupIds: [String]
    var isHiking: Bool
    var positionId: String
    var createdAt: Date?
    var updatedAt: Date?

    static func new(uid: String, nickname: String) -> AppUser {
        .init(id: uid, nickname: nickname, image: nil, groupIds: [], isHiking: false,
              positionId: "pos_member", createdAt: nil, updatedAt: nil)
    }
}
