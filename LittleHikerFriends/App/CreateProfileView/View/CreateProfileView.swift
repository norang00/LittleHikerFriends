//
//  CreateProfileView.swift
//  LittleHikerFriends
//
//  Created by sungkug_apple_developer_ac on 8/25/25.
//

import UIKit
import Combine

protocol ProfileCreateViewDelegate: AnyObject {
    func profileViewDidTapCamera(_ view: ProfileCreateView, source: UIView)
    func profileViewDidTapDone(_ view: ProfileCreateView)
    func profileView(_ view: ProfileCreateView, didChangeNickname text: String)
}

final class ProfileCreateView: UIView {

    weak var delegate: ProfileCreateViewDelegate?

    // MARK: UI
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "프로필 이미지"
        l.font = .boldSystemFont(ofSize: 22)
        l.textAlignment = .center
        return l
    }()

    let avatarView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "defaultProfile"))
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()

    private let cameraButton: UIButton = {
        let b = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "camera.fill")
        b.configuration = config
        b.tintColor = .white
        b.backgroundColor = .gray
        b.layer.cornerRadius = 18
        b.layer.shadowOpacity = 0.15
        b.layer.shadowRadius = 4
        return b
    }()

    let nicknameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "닉네임을 입력해주세요."
        tf.borderStyle = .roundedRect
        tf.clearButtonMode = .whileEditing
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        return tf
    }()
    
    private let guaidLabel: UILabel = {
        let l = UILabel()
        l.text = "*6글자까지 가능합니다."
        l.font = .systemFont(ofSize: 16, weight: .regular)
        l.textAlignment = .center
        l.textColor = .lightGray
        return l
    }()

    let doneButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("완료", for: .normal)
        b.titleLabel?.font = .boldSystemFont(ofSize: 17)
        b.backgroundColor = .systemGreen
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 10
        b.isEnabled = false
        b.alpha = 0.5
        return b
    }()

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground
        setupLayout()
        cameraButton.addTarget(self, action: #selector(tapCamera), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(tapDone), for: .touchUpInside)
        nicknameField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarView.layer.cornerRadius = avatarView.bounds.width / 2
        cameraButton.layer.cornerRadius = 18
    }

    private func setupLayout() {
        [titleLabel, avatarView, cameraButton, nicknameField, guaidLabel, doneButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 112),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            avatarView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            avatarView.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 150),
            avatarView.heightAnchor.constraint(equalToConstant: 150),

            cameraButton.widthAnchor.constraint(equalToConstant: 36),
            cameraButton.heightAnchor.constraint(equalToConstant: 36),
            cameraButton.trailingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 6),
            cameraButton.bottomAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 6),

            nicknameField.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 77),
            nicknameField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            nicknameField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            nicknameField.heightAnchor.constraint(equalToConstant: 60),

            guaidLabel.topAnchor.constraint(equalTo: nicknameField.bottomAnchor, constant: 16),
            guaidLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            doneButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -60),
            doneButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    // MARK: Bind
    struct ViewState {
        let avatar: UIImage?
        let nickname: String
        let isDoneEnabled: Bool
    }

    func render(_ state: ViewState) {
        if let img = state.avatar { avatarView.image = img }
        if nicknameField.text != state.nickname {
            nicknameField.text = state.nickname
        }
        doneButton.isEnabled = state.isDoneEnabled
        doneButton.alpha = state.isDoneEnabled ? 1.0 : 0.5
    }

    // MARK: Actions
    @objc private func tapCamera() {
        delegate?.profileViewDidTapCamera(self, source: cameraButton)
    }
    @objc private func tapDone() {
        delegate?.profileViewDidTapDone(self)
    }
    @objc private func textChanged() {
        delegate?.profileView(self, didChangeNickname: nicknameField.text ?? "")
    }
}

import SwiftUI

struct ProfileCreateViewPreviewWrapper: UIViewRepresentable {
    final class Coordinator: NSObject, ProfileCreateViewDelegate {
        func profileViewDidTapCamera(_ view: ProfileCreateView, source: UIView) {
            print("📷 tap camera")
        }
        func profileViewDidTapDone(_ view: ProfileCreateView) {
            print("✅ tap done")
        }
        func profileView(_ view: ProfileCreateView, didChangeNickname text: String) {
            print("✏️ nickname:", text)
            let ok = !text.trimmingCharacters(in: .whitespaces).isEmpty && text.count <= 6
            view.render(.init(avatar: view.avatarView.image, nickname: text, isDoneEnabled: ok))
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> ProfileCreateView {
        let v = ProfileCreateView()
        v.delegate = context.coordinator
        v.render(.init(avatar: UIImage(named: "defaultProfile"),
                       nickname: "",
                       isDoneEnabled: false))
        return v
    }

    func updateUIView(_ uiView: ProfileCreateView, context: Context) {    }
}

#Preview {
    ProfileCreateViewPreviewWrapper()
        .ignoresSafeArea()
}
