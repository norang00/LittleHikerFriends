//
//  LoginViewController.swift
//  LittleHikerFriends
//
//  Created by sungkug_apple_developer_ac on 7/27/25.
//

import UIKit
import KakaoSDKUser

enum LoginButtonType: String {
    case apple = "애플로그인버튼"
    case kakao = "카카오로그인버튼"
    
    var imageName: String {
        rawValue
    }
}

class LoginViewController: UIViewController {
    
    private let appleLoginButton: UIButton = {
        let button = UIButton()
        let loginType = LoginButtonType.apple
        button.setImage(UIImage(named: loginType.imageName), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(handleAppleLogin), for: .touchUpInside)
        return button
    }()

    private let kakaoLoginButton: UIButton = {
        let button = UIButton()
        let loginType = LoginButtonType.kakao
        button.setImage(UIImage(named: loginType.imageName), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(handleKakaoLogin), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
    }

    private func setupLayout() {
        [kakaoLoginButton, appleLoginButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            appleLoginButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            appleLoginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            appleLoginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            appleLoginButton.heightAnchor.constraint(equalToConstant: 45),
            
            kakaoLoginButton.bottomAnchor.constraint(equalTo: appleLoginButton.topAnchor, constant: -20),
            kakaoLoginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            kakaoLoginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            kakaoLoginButton.heightAnchor.constraint(equalToConstant: 45),
        ])
    }

    @objc private func handleAppleLogin() {
        print("애플 로그인 시도")
        // Apple 로그인 로직 호출
    }

    @objc private func handleKakaoLogin() {
        print("카카오 로그인 시도")
        kakaoLogin { [weak self] isSuccess in
            guard let self = self else { return }
            if isSuccess {
                self.checkProfileAndNavigate()
            } else {
                // 로그인 실패 처리
            }
        }
    }
    
    private func kakaoLogin(completion: @escaping (Bool) -> Void) {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { token, error in
                if let token = token {
                    print("로그인 성공! 토큰: \(token.accessToken)")
                    completion(true)
                } else {
                    print("로그인 실패: \(error?.localizedDescription ?? "unknown")")
                    completion(false)
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { token, error in
                if let token = token {
                    print("로그인 성공! 토큰: \(token.accessToken)")
                    completion(true)
                } else {
                    print("로그인 실패: \(error?.localizedDescription ?? "unknown")")
                    completion(false)
                }
            }
        }
    }
    
    private func checkProfileAndNavigate() {
        if profileExists() {
            goToMain()
        } else {
            goToProfileCreation()
        }
    }
    
    private func goToMain() {
        let vc = ViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    private func goToProfileCreation() {
        // TODO: 프로필 생성뷰 연결
    }
    
    private func profileExists() -> Bool {
        // TODO: 프로필 존재 확인, 서버로 부터 확인 후 생성
        
        return UserDefaults.standard.bool(forKey: "hasProfile")
    }
}
