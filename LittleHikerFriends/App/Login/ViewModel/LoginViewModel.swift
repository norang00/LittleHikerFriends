//
//  LoginViewModel.swift
//  LittleHikerFriends
//
//  Created by sungkug_apple_developer_ac on 8/23/25.
//

import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    enum State { case idle, loading, error(String) }
    enum Route { case main, profile }

    @Published private(set) var state: State = .idle
    var route: ((Route) -> Void)?

    private let auth: AuthService
    init(auth: AuthService) { self.auth = auth }

    func tapKakao() async {
        state = .loading
        do {
            try await auth.signInWithKakao()
            let has = UserDefaults.standard.bool(forKey: "hasProfile") // 임시
            route?(has ? .main : .profile)
            state = .idle
        } catch {
            state = .error((error as NSError).localizedDescription)
        }
    }

    func tapApple() {
        state = .error("Apple 로그인은 추후 추가 예정")
    }
}
