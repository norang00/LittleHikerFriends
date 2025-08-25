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
            let outcome = try await auth.signInWithKakao()
            switch outcome {
            case .newUser(_): route?(.profile)
            case .existing(_): route?(.main)
            }
            state = .idle
        } catch {
            state = .error((error as NSError).localizedDescription)
        }
    }

    func tapApple() {
        state = .error("Apple 로그인은 추후 추가 예정")
    }
}
