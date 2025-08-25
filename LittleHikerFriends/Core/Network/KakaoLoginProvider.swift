//
//  KakaoLoginProvider.swift
//  LittleHikerFriends
//
//  Created by sungkug_apple_developer_ac on 8/23/25.
//
import KakaoSDKUser
import Foundation

struct SocialCredential {
    let provider: String
    let accessToken: String
    let idToken: String?
}

protocol SocialLoginProvider {
    func login() async throws -> SocialCredential
}

final class KakaoLoginProvider: SocialLoginProvider {
    func login() async throws -> SocialCredential {
        try await withCheckedThrowingContinuation { cont in
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk { token, error in
                    if let t = token {
                        cont.resume(returning: .init(provider: "kakao",
                                                     accessToken: t.accessToken,
                                                     idToken: nil))
                    } else {
                        cont.resume(throwing: error ?? NSError(domain: "Kakao", code: -1))
                    }
                }
            } else {
                UserApi.shared.loginWithKakaoAccount { token, error in
                    if let t = token {
                        cont.resume(returning: .init(provider: "kakao",
                                                     accessToken: t.accessToken,
                                                     idToken: nil))
                    } else {
                        cont.resume(throwing: error ?? NSError(domain: "Kakao", code: -1))
                    }
                }
            }
        }
    }
}
