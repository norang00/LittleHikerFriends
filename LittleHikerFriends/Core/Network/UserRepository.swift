//
//  UserRepository.swift
//  LittleHikerFriends
//
//  Created by sungkug_apple_developer_ac on 8/23/25.
//

import FirebaseFirestore
import FirebaseAuth

final class UserRepository {
    private let db = Firestore.firestore()

    func upsertUser(_ authUser: FirebaseAuth.User,
                    defaultNickname: String? = nil) async throws -> (AppUser, Bool) {

        let uid = authUser.uid
        let ref = db.collection("users").document(uid)

        // 존재 여부 먼저 확인
        let snap = try await ref.getDocument()

        if snap.exists, let existing = try? snap.data(as: AppUser.self) {
            // 기존 유저 → updatedAt만 갱신
            try await ref.setData(["updatedAt": FieldValue.serverTimestamp()], merge: true)
            return (existing, false)
        } else {
            // 신규 유저 생성 (한 번의 setData(from:)으로 created/updated @ServerTimestamp 채워짐)
            let nickname = authUser.displayName ?? defaultNickname ?? "User"
            let newUser = AppUser.new(uid: uid, nickname: nickname)

            try ref.setData(from: newUser, merge: true)
            // 필요하면 최신 스냅으로 리로드
            let latest = try await ref.getDocument()
            let materialized = (try? latest.data(as: AppUser.self)) ?? newUser
            return (materialized, true)
        }
    }

    func fetchMe(uid: String) async throws -> AppUser {
        try await db.collection("users").document(uid).getDocument().data(as: AppUser.self)
    }

    func updateProfile(uid: String, nickname: String? = nil, imageURL: String? = nil,
                       isHiking: Bool? = nil, positionId: String? = nil,
                       groupIds: [String]? = nil) async throws {
        var data: [String: Any] = ["updatedAt": FieldValue.serverTimestamp()]
        if let nickname { data["nickname"] = nickname }
        if let imageURL { data["image"] = imageURL }
        if let isHiking { data["isHiking"] = isHiking }
        if let positionId { data["positionId"] = positionId }
        if let groupIds { data["groupIds"] = groupIds }
        try await db.collection("users").document(uid).setData(data, merge: true)
    }
}
