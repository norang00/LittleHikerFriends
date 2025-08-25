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

enum SignInOutcome {
    case newUser(AppUser)     // 프로필 생성
    case existing(AppUser)    // 메인으로
}

protocol AuthService {
    func signInWithKakao() async throws -> SignInOutcome
}

final class FirebaseAuthService: AuthService {
    private let provider: SocialLoginProvider
    private let functions: Functions
    private let userRepo: UserRepository

    init(provider: SocialLoginProvider,
         functions: Functions = .functions(region: "us-central1"),
         userRepo: UserRepository) {
        self.provider = provider
        self.functions = functions
        self.userRepo = userRepo
    }

    func signInWithKakao() async throws -> SignInOutcome {
        // 카카오 로그인 → accessToken
        let cred = try await provider.login()

        // Functions 호출 → customToken
        let res = try await functions.httpsCallable("kakaoLogin")
            .call(["accessToken": cred.accessToken])

        guard let dict = res.data as? [String: Any],
              let customToken = dict["customToken"] as? String else {
            throw NSError(domain: "Auth", code: -2,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid kakaoLogin response"])
        }

        // Firebase Auth 로그인
        let authRes = try await Auth.auth().signIn(withCustomToken: customToken)
        let user = authRes.user

        // Firestore upsert + 신규여부 판단
        let (appUser, isNew) = try await userRepo.upsertUser(user, defaultNickname: nil)
        return isNew ? .newUser(appUser) : .existing(appUser)
    }
}
