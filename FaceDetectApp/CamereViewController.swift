//
//  CamereViewController.swift
//  FaceDetectApp
//
//  Created by Muslim Mirzajonov on 20/03/24.
//

import UIKit
import AVFoundation
import Vision

class CameraViewController: UIViewController {
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    private var isFaceDetect = false
    private let photoOutput = AVCapturePhotoOutput()
    private let semicircleLayer = CAShapeLayer()
    private let freeformLayer = CAShapeLayer()
    private let userFaceDistanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        addCameraInput()
        showCameraFeed(centerX: view.center.x, centerY: view.center.y - UIScreen.main.bounds.height * 0.06, size: UIScreen.main.bounds.height * 0.35)
        getCameraFrames()
        captureSession.startRunning()
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    deinit {
        captureSession.stopRunning()
    }
    
    private func setup() {
        userFaceDistanceLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userFaceDistanceLabel)
        userFaceDistanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        userFaceDistanceLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        userFaceDistanceLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        let previewTop = previewLayer.frame.minY
        userFaceDistanceLabel.bottomAnchor.constraint(equalTo: view.topAnchor, constant: previewTop - 30).isActive = true
        changeFillBorderColor(color: .red, title: "The user's face is not visible or please move away from the camera")
    }
    
    func deg2rad(_ number: Double) -> CGFloat{
        return CGFloat(number * Double.pi/130)
    }
    
    private func addCameraInput() {
        guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .front).devices.first else {
            fatalError("No camera detected. Please use a real camera, not a simulator.")
        }
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        captureSession.addInput(cameraInput)
    }
    
    private func showCameraFeed(centerX: CGFloat, centerY: CGFloat, size: CGFloat) {
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
        let previewX = centerX - (size / 2)
        let previewY = centerY - (size / 2)
        
        previewLayer.frame = CGRect(x: previewX, y: previewY - UIScreen.main.bounds.height * 0.013, width: size, height: size + UIScreen.main.bounds.height * 0.15)
        
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height), cornerRadius: 0)
        
        let radius: CGFloat = size / 2
        let startAngle = deg2rad(0)
        let endAngle = deg2rad(130)
        
        let semicircle = UIBezierPath(arcCenter: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        semicircleLayer.path = semicircle.cgPath
        semicircleLayer.fillColor = UIColor.clear.cgColor
        semicircleLayer.lineWidth = 2.0
        
        let controlPointY = centerY + radius * 3 - UIScreen.main.bounds.height * 0.12
        let freeform = UIBezierPath()
        freeform.move(to: CGPoint(x: centerX - radius, y: centerY))
        freeform.addCurve(to: CGPoint(x: centerX + radius, y: centerY), controlPoint1: CGPoint(x: centerX - radius, y: controlPointY), controlPoint2: CGPoint(x: centerX + radius, y: controlPointY))
        
        freeformLayer.path = freeform.cgPath
        freeformLayer.fillColor = UIColor.clear.cgColor
        freeformLayer.lineWidth = 2.0
        
        path.append(semicircle)
        path.append(freeform)
        path.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = .evenOdd
        
        let maskLayer = CALayer()
        maskLayer.addSublayer(fillLayer)
        maskLayer.addSublayer(semicircleLayer)
        maskLayer.addSublayer(freeformLayer)
        
        maskLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - UIScreen.main.bounds.height * 0.06)
        view.layer.addSublayer(maskLayer)
    }
    
    private func changeFillBorderColor(color: UIColor, title: String) {
        freeformLayer.strokeColor = color.cgColor
        semicircleLayer.strokeColor = color.cgColor
        userFaceDistanceLabel.textColor = color
        userFaceDistanceLabel.text = title
    }

    
    private func getCameraFrames() {
        captureSession.addOutput(photoOutput)

        videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): NSNumber(value: kCVPixelFormatType_32BGRA)]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera_frame_processing_queue"))
        captureSession.addOutput(videoDataOutput)

        if let connection = videoDataOutput.connection(with: .video) {
            connection.videoOrientation = .portrait
        }
    }
    
    private func detectFace(image: CVPixelBuffer) {
        let faceDetectionRequest = VNDetectFaceLandmarksRequest { vnRequest, error in
            DispatchQueue.main.async {
                if let firstFace = vnRequest.results?.first as? VNFaceObservation {
                    self.handleFaceDetectionResults(observedFace: firstFace)
                } else {
                    self.changeFillBorderColor(color: .red, title: "The user's face is not visible or please move away from the camera")
                    self.isFaceDetect = false
                }
            }
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, orientation: .leftMirrored, options: [:])
        try? imageRequestHandler.perform([faceDetectionRequest])
    }
    
    private func handleFaceDetectionResults(observedFace: VNFaceObservation) {
        let previewWidth = previewLayer.bounds.width
        let faceWidth = observedFace.boundingBox.width * previewWidth
        let farThresholdPercentage: CGFloat = 0.4
        let farThreshold = previewWidth * farThresholdPercentage

        if faceWidth > farThreshold {
            changeFillBorderColor(color: .green, title: "The user face is at a normal distance")
            isFaceDetect = true
            if isFaceDetect {
                capturePhoto()
            }
        } else {
            isFaceDetect = false
            changeFillBorderColor(color: .yellow, title: "Please maintain a normal distance and move closer to the camera")
        }
    }

    private func capturePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = .off

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        detectFace(image: frame)
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else { return }
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: imageData) else { return }
        saveImageToStorage(image: image)
    }
    
    private func saveImageToStorage(image: UIImage) {
        do {
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                UserDefaults.standard.set(imageData, forKey: "latestSavedImage")
                DispatchQueue.main.async {
                    self.captureSession.stopRunning()
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } else {
                throw ImageError.imageDataConversionFailed
            }
        } catch {
            print("Error saving image to UserDefaults: \(error)")
        }
    }

    enum ImageError: Error {
        case imageDataConversionFailed
    }

}
