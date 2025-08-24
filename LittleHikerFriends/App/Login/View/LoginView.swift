//
//  LoginView.swift
//  LittleHikerFriends
//
//  Created by sungkug_apple_developer_ac on 8/23/25.
//

import UIKit

final class LoginView: UIView {

    var onTapApple: (() -> Void)?
    var onTapKakao: (() -> Void)?

    private let appleLoginButton: UIButton = {
        let button = UIButton()
        let loginType = LoginButtonType.apple
        button.setImage(UIImage(named: loginType.imageName), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()

    private let kakaoLoginButton: UIButton = {
        let button = UIButton()
        let loginType = LoginButtonType.kakao
        button.setImage(UIImage(named: loginType.imageName), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()

    private let activity = UIActivityIndicatorView(style: .medium)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        setupLayout()
    }

    private func setup() {
        backgroundColor = .systemBackground
        appleLoginButton.addTarget(self, action: #selector(tapApple), for: .touchUpInside)
        kakaoLoginButton.addTarget(self, action: #selector(tapKakao), for: .touchUpInside)
    }

    private func setupLayout() {
        [kakaoLoginButton, appleLoginButton, activity].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            appleLoginButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -100),
            appleLoginButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            appleLoginButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            appleLoginButton.heightAnchor.constraint(equalToConstant: 45),

            kakaoLoginButton.bottomAnchor.constraint(equalTo: appleLoginButton.topAnchor, constant: -20),
            kakaoLoginButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            kakaoLoginButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            kakaoLoginButton.heightAnchor.constraint(equalToConstant: 45),

            activity.centerXAnchor.constraint(equalTo: centerXAnchor),
            activity.bottomAnchor.constraint(equalTo: kakaoLoginButton.topAnchor, constant: -20)
        ])
    }

    // 로딩 상태
    func setLoading(_ loading: Bool) {
        DispatchQueue.main.async {
            loading ? self.activity.startAnimating() : self.activity.stopAnimating()
            self.appleLoginButton.isEnabled = !loading
            self.kakaoLoginButton.isEnabled = !loading
        }
    }

    // MARK: - Actions
    @objc private func tapApple() { onTapApple?() }
    @objc private func tapKakao() { onTapKakao?() }
}
