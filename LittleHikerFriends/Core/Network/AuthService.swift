//
//  AuthService.swift
//  LittleHikerFriends
//
//  Created by sungkug_apple_developer_ac on 8/23/25.
//

import Foundation
import FirebaseAuth
import FirebaseFunctions
import FirebaseFirestore

protocol AuthService {
    func signInWithKakao() async throws
}

final class FirebaseAuthService: AuthService {
    private let provider: SocialLoginProvider
    private let functions: Functions
    private let userRepo: UserRepository

    init(provider: SocialLoginProvider,
         functions: Functions = .functions(),
         userRepo: UserRepository) {
        self.provider = provider
        self.functions = functions
        self.userRepo = userRepo
    }

    func signInWithKakao() async throws {
        // 카카오 로그인 → accessToken
        let cred = try await provider.login()

        // Cloud Functions 호출 → customToken 수령
        let result = try await functions.httpsCallable("kakaoLogin")
            .call(["accessToken": cred.accessToken])

        guard
            let data = result.data as? [String: Any],
            let customToken = data["customToken"] as? String
        else {
            throw NSError(domain: "Auth", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid kakaoLogin response"])
        }

        // Firebase 로그인
        let authResult = try await Auth.auth().signIn(withCustomToken: customToken)
        let firebaseUser = authResult.user

        // Firestore users/{uid} upsert → /me 대체
        _ = try await userRepo.upsertUser(firebaseUser)
    }
}
