//
//  CreateProfileViewController.swift
//  LittleHikerFriends
//
//  Created by sungkug_apple_developer_ac on 8/25/25.
//

import UIKit
import PhotosUI
import Combine

final class CreateProfileViewController: UIViewController, ProfileCreateViewDelegate {
    private let rootView = ProfileCreateView()
    private let viewModel = ProfileCreateViewModel()
    private var bag = Set<AnyCancellable>()

    override func loadView() {
        view = rootView
        rootView.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] st in
                self?.rootView.render(.init(
                    avatar: st.avatar,
                    nickname: st.nickname,
                    isDoneEnabled: st.isDoneEnabled
                ))
                self?.rootView.setHelper(text: st.nicknameHelper) // helper 라벨 업데이트용
            }
            .store(in: &bag)
    }
    
    func profileViewDidTapCamera(_ view: ProfileCreateView, source: UIView) {
        presentPhotoActionSheet(anchor: view)
    }
    
    func profileViewDidTapDone(_ view: ProfileCreateView) {
        guard let payload = viewModel.makePayloadForSubmit() else { return }
    }
    
    func profileView(_ view: ProfileCreateView, didChangeNickname text: String) {
        viewModel.setNickname(text)
    }
}

extension CreateProfileViewController: PHPickerViewControllerDelegate {

    // MARK: - ActionSheet + PHPicker
    private func presentPhotoActionSheet(anchor: UIView) {
        let alert = UIAlertController(title: "프로필 사진 설정", message: nil, preferredStyle: .actionSheet)
        alert.addAction(.init(title: "앨범에서 사진 선택", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        alert.addAction(.init(title: "기본 이미지 선택", style: .default, handler: { [weak self] _ in
            self?.viewModel.setAvatar(UIImage(named: "defaultProfile"))
        }))
        alert.addAction(.init(title: "취소", style: .cancel, handler: nil))

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

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self, let image = object as? UIImage else { return }
            DispatchQueue.main.async { self.viewModel.setAvatar(image) }
        }
    }
}
