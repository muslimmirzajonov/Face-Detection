//
//  ViewController.swift
//  FaceDetectApp
//
//  Created by Muslim Mirzajonov on 20/03/24.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabbar()
    }
    
    private func setupTabbar() {
        let viewController = HomeViewController()
        let savedPostsViewController = PhotosViewController()
        
        viewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house"))
        savedPostsViewController.tabBarItem = UITabBarItem(title: "Photos", image: UIImage(systemName: "photo.artframe"), selectedImage: UIImage(systemName: "photo.artframe"))
        
        let controllers = [viewController, savedPostsViewController]
        self.viewControllers = controllers.map { UINavigationController(rootViewController: $0) }
    }
}
