//
//  CreateProfileViewController.swift
//  LittleHikerFriends
//
//  Created by sungkug_apple_developer_ac on 8/25/25.
//

import UIKit
import PhotosUI

final class CreateProfileViewController: UIViewController, ProfileCreateViewDelegate {
    private let rootView = ProfileCreateView()
    
    override func loadView() {
        view = rootView
        rootView.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func profileViewDidTapCamera(_ view: ProfileCreateView, source: UIView) {
        presentPhotoActionSheet(anchor: view)
    }
    
    func profileViewDidTapDone(_ view: ProfileCreateView) {
    }
    
    func profileView(_ view: ProfileCreateView, didChangeNickname text: String) {
    }
}


extension CreateProfileViewController: PHPickerViewControllerDelegate {

    private func presentPhotoActionSheet(anchor: UIView) {
        let alert = UIAlertController(title: "프로필 사진 설정",
                                      message: nil,
                                      preferredStyle: .actionSheet)

        // 1) 앨범에서 사진 선택
        alert.addAction(UIAlertAction(title: "앨범에서 사진 선택", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))

        // 2) 기본 이미지 선택
        alert.addAction(UIAlertAction(title: "기본 이미지 선택", style: .default, handler: { [weak self] _ in
            let defaultImg = UIImage(named: "defaultProfile")
            self?.applyAvatar(defaultImg)
        }))

        // 취소
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))

        // popover 앵커 지정
        if let pop = alert.popoverPresentationController {
            pop.sourceView = anchor
            pop.sourceRect = anchor.bounds
            pop.permittedArrowDirections = [.up, .down]
        }

        present(alert, animated: true)
    }

    private func presentPhotoPicker() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    // PHPicker 결과 콜백
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self, let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self.applyAvatar(image)
            }
        }
    }

    private func applyAvatar(_ image: UIImage?) {
        // render 사용: 닉네임/버튼 상태는 기존 값 유지
        let nickname = rootView.nicknameField.text ?? ""
        let isDoneEnabled = !nickname.isEmpty
        rootView.render(.init(avatar: image, nickname: nickname, isDoneEnabled: isDoneEnabled))
    }
}
