//
//  HomeViewController.swift
//  LittleHikerFriends
//
//  Created by Kyuhee hong on 8/25/25.
//

import UIKit

final class HomeViewController: UIViewController {
    
    private let homeView = HomeView()
    
    override func loadView() {
        view = homeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        title = "홈"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
