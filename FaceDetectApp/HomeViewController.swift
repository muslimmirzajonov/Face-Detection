//
//  HomeViewController.swift
//  FaceDetectApp
//
//  Created by Muslim Mirzajonov on 20/03/24.
//

import UIKit

class HomeViewController: UIViewController {
    private lazy var previewLayer = UIView()
    private let userFaceDistanceLabel: UILabel = {
        let label = UILabel()
        label.text = "The user's face is not visible or please move away from the camera"
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "camera"), style: .plain, target: self, action: #selector(cameraButtonTapped))
//        showCameraFeed(centerX: view.center.x, centerY: view.center.y - UIScreen.main.bounds.height * 0.06, size: UIScreen.main.bounds.height * 0.35)
    }
    
    private func setup() {
        userFaceDistanceLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userFaceDistanceLabel)
        userFaceDistanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        userFaceDistanceLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        userFaceDistanceLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        let previewTop = previewLayer.frame.minY
        userFaceDistanceLabel.bottomAnchor.constraint(equalTo: view.topAnchor, constant: previewTop - 30).isActive = true
    }
    
    @objc func cameraButtonTapped() {
        let vc = CameraViewController()
        vc.hidesBottomBarWhenPushed = true 
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func deg2rad(_ number: Double) -> CGFloat{
        return CGFloat(number * Double.pi/130)
    }
    
    private func showCameraFeed(centerX: CGFloat, centerY: CGFloat, size: CGFloat) {
//        previewLayer.videoGravity = .resizeAspectFill
        setup()
        view.addSubview(previewLayer)
        let previewX = centerX - (size / 2)
        let previewY = centerY - (size / 2)
        
        previewLayer.backgroundColor = .red
        previewLayer.frame = CGRect(x: previewX, y: previewY - UIScreen.main.bounds.height * 0.013, width: size, height: size + UIScreen.main.bounds.height * 0.15)
        
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height), cornerRadius: 0)
        
        let radius: CGFloat = size / 2
        let startAngle = deg2rad(0)
        let endAngle = deg2rad(130)
        
        let semicircle = UIBezierPath(arcCenter: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        let controlPointY = centerY + radius * 3 - UIScreen.main.bounds.height * 0.12
        let freeform = UIBezierPath()
        freeform.move(to: CGPoint(x: centerX - radius, y: centerY))
        freeform.addCurve(to: CGPoint(x: centerX + radius, y: centerY), controlPoint1: CGPoint(x: centerX - radius, y: controlPointY), controlPoint2: CGPoint(x: centerX + radius, y: controlPointY))
        
        path.append(semicircle)
        path.append(freeform)
        path.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.opacity = 0.1
        
        fillLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - UIScreen.main.bounds.height * 0.06)
        view.layer.addSublayer(fillLayer)
    }

}
