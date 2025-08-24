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
         functions: Functions = .functions(region: "us-central1"),
         userRepo: UserRepository) {
        self.provider = provider
        self.functions = functions
        self.userRepo = userRepo
    }

    func signInWithKakao() async throws {
        let cred = try await provider.login()

        do {
            // Cloud Functions 호출 → customToken 수령
            let result = try await functions.httpsCallable("kakaoLogin")
                .call(["accessToken": cred.accessToken])

            guard
                let dict = result.data as? [String: Any],
                let customToken = dict["customToken"] as? String
            else {
                throw NSError(domain: "Auth",
                              code: -2,
                              userInfo: [NSLocalizedDescriptionKey: "Invalid kakaoLogin response: \(result.data)"])
            }

            // Firebase 로그인
            let authResult = try await Auth.auth().signIn(withCustomToken: customToken)
            let user = authResult.user
            print("Firebase signIn success uid:", user.uid)

            // Firestore upsert
            _ = try await userRepo.upsertUser(user)

        } catch {
            let ns = error as NSError
            let fnCode = (ns.domain == FunctionsErrorDomain) ? FunctionsErrorCode(rawValue: ns.code) ?? .unknown : .unknown
            let details = ns.userInfo[FunctionsErrorDetailsKey] ?? ns.userInfo
            print("code:", fnCode, "details:", details)
        }
    }
}
