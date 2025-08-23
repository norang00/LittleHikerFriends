//
//  AuthService.swift
//  LittleHikerFriends
//
//  Created by sungkug_apple_developer_ac on 8/23/25.
//

protocol AuthService { func signInWithKakao() async throws }

final class KakaoAuthService: AuthService {
    private let provider: SocialLoginProvider
    init(provider: SocialLoginProvider) { self.provider = provider }
    func signInWithKakao() async throws { _ = try await provider.login() }
}
