//
//  ToastView.swift
//  Capture
//
//  Created by Finn Gaida on 24.08.17.
//  Copyright © 2017 Morsel Interactive. All rights reserved.
//

import UIKit

/// Displays a message at the top of the screen
class ToastView: UIView {
    enum ToastType {
        // Camera view
        case burstDeleted, cancelled, darkModeDisabled

        // Preview view
        case savingVideo, savingPhotos, videoSaved, notSaved, timeForBurst, exporting

        // IAP
        case loadingAppStore, purchaseSuccess, purchaseCancelled, restoreSuccess(itemCount: Int), restoreCancelled, nothingToRestore

        // Generic
        case error
    }

    /// Kind of icon + text combination of the toast
    let type: ToastType
    
    /// Optional - called on tap
    let action: (() -> ())?

    /// Icon on the left
    private var icon: UIView!

    /// Text field on the right
    private var label: UILabel

    /// Action receiver
    private var button: UIButton = UIButton()

    init(type: ToastType, action: (() -> ())? = nil) {
        self.type = type
        self.action = action

        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.semibold)
        label.textColor = .white

        switch type {
            case .videoSaved:       label.text = "Photo saved"
            default: break
        }

        label.sizeToFit()
        self.label = label

        let widthBase: CGFloat
        switch type {
        case .cancelled, .timeForBurst, .darkModeDisabled: widthBase = 16
        default: widthBase = 38
        }
        let width = widthBase + label.frame.width + 16

        super.init(frame: CGRect(x: UIScreen.main.bounds.width/2-width/2, y: -36, width: width, height: 36))
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Please use init(type:, message:)")
    }

    func setup() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.height/2

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blur.frame = self.bounds
        self.addSubview(blur)

        label.frame = CGRect(x: self.frame.width - label.frame.width - 16, y: 8, width: label.frame.width, height: 20)
        self.addSubview(label)

        switch type {
        case .savingVideo, .savingPhotos, .loadingAppStore, .exporting:
//            let loader = MaterialActivityIndicator(frame: CGRect(x: 13, y: 9, width: 18, height: 18))
//            icon = loader
//            self.addSubview(loader)
            break

        case .cancelled, .timeForBurst, .nothingToRestore, .darkModeDisabled: break

        default:
            let image: UIImage
            switch type {
            case .error, .notSaved, .purchaseCancelled, .restoreCancelled: image = #imageLiteral(resourceName: "CancelButtonCancelIcon")
            default: image = #imageLiteral(resourceName: "Checkmark, White")
            }

            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 10, y: 6, width: 24, height: 24)
            icon = imageView
            self.addSubview(imageView)
        }

        button.frame = self.bounds
//        button.addControlEvent(.touchUpInside) { [weak self] in
//            guard let wSelf = self else { return }
//            wSelf.hide() {
//                wSelf.action?()
//            }
//        }
//        button.addControlEvent(.touchDragExit) { [weak self] in
//            self?.hide()
//        }
        self.addSubview(button)
    }

    @objc func show(autohide: Bool = true, completion: (()->())? = nil) {
        if case .timeForBurst = self.type {
//            Sounds.shared.play(sound: .notification)
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.addSubview(self)
            let topOffset: CGFloat = Platform.isEdgeless ? 64 : 32

            animateSpring(duration: 0.6, damping: 0.65) {
                self.transform = CGAffineTransform(translationX: 0, y: self.frame.height+topOffset)
            }

//            if let loader = self.icon as? MaterialActivityIndicator {
//                loader.setupAnimations(deterministic: false)
//            }

            if autohide {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                    self.hide(completion: completion)
                })
            }
        }
    }

    @objc func hide(completion: (()->())? = nil) {
        DispatchQueue.main.async {
            animateLin(duration: 0.3, completion: completion) {
                self.transform = CGAffineTransform(translationX: 0, y: -self.frame.height-32)
            }
        }
    }
}
