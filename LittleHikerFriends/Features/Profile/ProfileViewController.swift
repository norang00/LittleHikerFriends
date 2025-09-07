//
//  ProfileViewController.swift
//  LittleHikerFriends
//
//  Created by Kyuhee hong on 8/25/25.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    private let profileView = ProfileView()
    
    override func loadView() {
        view = profileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        title = "프로필"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
