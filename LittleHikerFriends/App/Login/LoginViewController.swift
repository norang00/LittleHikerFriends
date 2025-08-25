//
//  LoginViewController.swift
//  LittleHikerFriends
//
//  Created by sungkug_apple_developer_ac on 7/27/25.
//
import UIKit
import Combine

final class LoginViewController: UIViewController {
    private let content = LoginView()
    private let vm: LoginViewModel
    private var bag = Set<AnyCancellable>()

    init(vm: LoginViewModel) { self.vm = vm; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func loadView() { view = content }
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    private func bind() {
        content.onTapKakao = { [weak self] in
            guard let self else { return }
            Task { await self.vm.tapKakao() }
        }
        content.onTapApple = { [weak self] in self?.vm.tapApple() }

        vm.$state.sink { [weak self] s in
            guard let self else { return }
            switch s {
            case .idle: self.content.setLoading(false)
            case .loading: self.content.setLoading(true)
            case .error(let msg):
                self.content.setLoading(false)
                let a = UIAlertController(title: "알림", message: msg, preferredStyle: .alert)
                a.addAction(.init(title: "확인", style: .default))
                self.present(a, animated: true)
            }
        }.store(in: &bag)

        vm.route = { [weak self] r in
            guard let self else { return }
            switch r {
            case .main:
                // 로그인 성공 시 탭바 컨트롤러로 전환
                let tabBarController = MainTabBarController()
                
                // 현재 window의 rootViewController를 교체
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = tabBarController
                    
                    // 부드러운 전환 애니메이션
                    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
                }
            case .profile:
                // 프로필 생성이 필요한 경우 (추후 구현)
                let vc = UIViewController()
                vc.view.backgroundColor = .systemGroupedBackground
                vc.title = "프로필 만들기"
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
