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

    func upsertUser(_ authUser: FirebaseAuth.User, defaultNickname: String? = nil) async throws -> AppUser {
        let ref = db.collection("users").document(authUser.uid)
        let snap = try await ref.getDocument()

        if let existing = try? snap.data(as: AppUser.self) {
            try await ref.setData(["updatedAt": FieldValue.serverTimestamp()], merge: true)
            return existing
        } else {
            let nickname = authUser.displayName ?? defaultNickname ?? "User"
            var new = AppUser.new(uid: authUser.uid, nickname: nickname)
            try ref.setData(from: new, merge: true)
            try await ref.setData([
                "createdAt": FieldValue.serverTimestamp(),
                "updatedAt": FieldValue.serverTimestamp()
            ], merge: true)
            return new
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
