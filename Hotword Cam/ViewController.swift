//
//  ViewController.swift
//  Hotword Cam
//
//  Created by Finn Gaida on 19.12.18.
//  Copyright © 2018 Finn Gaida. All rights reserved.
//

import UIKit
import Speech
import AVKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCamera()
        setupSpeech()
    }

    var t: SFSpeechRecognitionTask?
    var o = AVCapturePhotoOutput()
    
    var r: SFSpeechRecognizer!
    let e = AVAudioEngine()
    let rr = SFSpeechAudioBufferRecognitionRequest()

    func setupCamera() {
        guard
            let d = AVCaptureDevice.default(for: .video),
            let i = try? AVCaptureDeviceInput(device: d)
        else { return }
        
        let s = AVCaptureSession()
        s.sessionPreset = .photo
        s.addInput(i)
        s.addOutput(o)
        let l = AVCaptureVideoPreviewLayer(session: s)
        l.frame = self.view.bounds
        self.view.layer.addSublayer(l)
        s.startRunning()
    }
    
    func setupSpeech() {
        guard
            let r = SFSpeechRecognizer(locale: Locale.current),
            SFSpeechRecognizer.authorizationStatus() == .authorized
        else {
            if SFSpeechRecognizer.authorizationStatus() == .notDetermined {
                return SFSpeechRecognizer.requestAuthorization { s in
                    self.setupSpeech()
                }
            } else { return }
        }
        self.r = r
        
        e.inputNode.installTap(onBus: 0, bufferSize: 1024, format: e.inputNode.outputFormat(forBus: 0)) { b, _ in
            self.rr.append(b)
        }
        
        e.prepare()
        do {
            try e.start()
        } catch let e {
            print(e)
        }
        
        self.t = r.recognitionTask(with: rr, resultHandler: { r, e in
            guard let s = r?.bestTranscription.formattedString else { return }
            print(s)
            
            if s.contains("test") || s.contains("Test") {
                self.takePhoto()
            }
        })
    }

    var cooldown: Bool = false
    func takePhoto() {
        guard !cooldown else { return }
        cooldown = true

        let format = [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA /*kCVPixelFormatType_32ARGB*/)]

        let s = AVCapturePhotoSettings(format: format)
        o.isHighResolutionCaptureEnabled = true
        s.isHighResolutionPhotoEnabled = true

        if o.isStillImageStabilizationSupported {
            s.isAutoStillImageStabilizationEnabled = true
        }

        if o.isDualCameraFusionSupported {
            s.isAutoDualCameraFusionEnabled = true
        }

        o.capturePhoto(with: s, delegate: self)
    }

}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard
            let buffer = photo.pixelBuffer,
            let i = UIImage(cvImageBuffer: buffer)
        else { return print("Couldn't get photo") }

        UIImageWriteToSavedPhotosAlbum(i, nil, nil, nil)
        ToastView(type: .videoSaved).show()
        cooldown = false
    }
}

extension UIImage {
    convenience init?(cvImageBuffer: CVImageBuffer, orientation: UIImage.Orientation = .right) {
        let ciimage = CIImage(cvImageBuffer: cvImageBuffer)

        var angle: CGFloat
        switch orientation {
        case .down, .upMirrored: angle = .pi
        case .up, .downMirrored: angle = 0
        case .left, .rightMirrored: angle = .pi * 1/2
        case .right, .leftMirrored: angle = .pi * 3/2
        }

        let rotated = ciimage.transformed(by: CGAffineTransform(rotationAngle: angle))
        guard let cgimage = CIContext().createCGImage(rotated, from: rotated.extent) else { return nil }
        self.init(cgImage: cgimage)
    }
}
