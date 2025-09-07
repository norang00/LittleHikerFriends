//
//  ProfileCreateViewModel.swift
//  LittleHikerFriends
//
//  Created by sungkug_apple_developer_ac on 9/7/25.
//

final class ProfileCreateViewModel {
    @Published private(set) var state: ProfileViewState

    private var draft: ProfileDraft

    init(initialAvatar: UIImage? = UIImage(named: "defaultProfile"),
         initialNickname: String = "") {
        self.draft = .init(avatar: initialAvatar, nickname: initialNickname)
        let check = NicknameValidator.validate(initialNickname)
        self.state = .init(avatar: initialAvatar,
                           nickname: initialNickname,
                           isDoneEnabled: check.valid,
                           nicknameHelper: check.helper)
    }

    func setAvatar(_ image: UIImage?) {
        draft.avatar = image
        // 닉네임 유효성은 기존 값 재사용
        let check = NicknameValidator.validate(draft.nickname)
        state.avatar = image
        state.isDoneEnabled = check.valid
        state.nicknameHelper = check.helper
    }

    func setNickname(_ text: String) {
        draft.nickname = text
        let check = NicknameValidator.validate(text)
        state.nickname = text
        state.isDoneEnabled = check.valid
        state.nicknameHelper = check.helper
    }

    func makePayloadForSubmit() -> ProfileDraft? {
        // 서버 전송 전 최종 검증
        let check = NicknameValidator.validate(draft.nickname)
        return check.valid ? draft : nil
    }
}
