//
//  PhotosViewController.swift
//  FaceDetectApp
//
//  Created by Muslim Mirzajonov on 20/03/24.
//

import UIKit

class PhotosViewController: UIViewController {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photos"
        view.backgroundColor = .white

        setupImageView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getImageFromStorage()
    }
    
    private func setupImageView() {
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            imageView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }

    private func getImageFromStorage() {
        guard let imageData = UserDefaults.standard.data(forKey: "latestSavedImage") else {
            print("No image data found in UserDefaults")
            return
        }

        if let image = UIImage(data: imageData) {
            imageView.image = image
        } else {
            print("Error converting image data to UIImage")
        }
    }
}
