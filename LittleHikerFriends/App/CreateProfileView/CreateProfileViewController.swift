//
//  CreateProfileViewController.swift
//  LittleHikerFriends
//
//  Created by sungkug_apple_developer_ac on 8/25/25.
//

import UIKit

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
    }
    
    func profileViewDidTapDone(_ view: ProfileCreateView) {
    }
    
    func profileView(_ view: ProfileCreateView, didChangeNickname text: String) {
    }
}
