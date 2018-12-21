//
//  Platform.swift
//  Capture
//
//  Created by Finn Gaida on 13.07.17.
//  Copyright © 2017 Morsel Interactive. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

enum ScreenSize: String {
    case SE, normal, plus, X, Xr, max, iPad, iPadPro, other
}

public enum DeviceModel: String {
    case simulator,
    iPod,
    iPad,
    iPhone4            = "iPhone 4",
    iPhone4S           = "iPhone 4S",
    iPhone5            = "iPhone 5",
    iPhone5S           = "iPhone 5S",
    iPhone5C           = "iPhone 5C",
    iPhone6            = "iPhone 6",
    iPhone6plus        = "iPhone 6 Plus",
    iPhone6S           = "iPhone 6S",
    iPhone6Splus       = "iPhone 6S Plus",
    iPhoneSE           = "iPhone SE",
    iPhone7            = "iPhone 7",
    iPhone7plus        = "iPhone 7 Plus",
    iPhone8            = "iPhone 8",
    iPhone8plus        = "iPhone 8 Plus",
    iPhoneX            = "iPhone X",
    iPhoneXs           = "iPhone XS",
    iPhoneXsMax        = "iPhone XS Max",
    iPhoneXr           = "iPhone XR",
    unknown
}

/// Check if we're on the simulator
struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
        isSim = true
        #endif
        return isSim
    }()

    static let version: (Int, Int, Int) = {
        let vString = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let components = vString.components(separatedBy: ".").map { Int($0)! }
        return (components[0], components[1], components[2])
    }()
    
    static let build: Int = {
        let bString = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        return Int(bString) ?? 0
    }()

    static let screenSize: ScreenSize = {
        switch UIScreen.main.bounds.height {
        case 568: return .SE
        case 667: return .normal
        case 736: return .plus
        case 812: return .X
        case 896: return .max
        default: return .other
        }
    }()

    static let isEdgeless: Bool = {
        switch screenSize {
        case .X, .max: return true
        default: return false
        }
    }()

    static let dualCamSupported: Bool = {
        return AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInTelephotoCamera], mediaType: AVMediaType.video, position: .back).devices.count > 0
    }()

    static let deviceData: [String: String] = {
        let d = UIDevice.current
        return [
            "Name": d.name,
            "Model": d.model,
            "OS": d.systemName,
            "Version": d.systemVersion,
            "Screen Size": Platform.screenSize.rawValue,
            "App Version": "\(Platform.version.0).\(Platform.version.1).\(Platform.version.2)"
        ]
    }()

    static let hardwareModel: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }

        if let code = modelCode, let codeString = String(validatingUTF8: code) {
            return codeString
        } else {
            print("Couldn't read device string")
            return "unknown"
        }
    }()

    /// Prevent old devices from using ML:
    //    iPhone 6s
    //    iPhone 6s Plus
    //    iPhone 6
    //    iPhone 6 Plus
    //    iPhone SE
    //    iPhone 5s
    //    iPod touch 6th generation
    static var isMLCapable: Bool {
        let modelString = hardwareModel
        if modelString.contains("iPhone") {
            if let majorVersionString = modelString.replacingOccurrences(of: "iPhone", with: "").components(separatedBy: ",").first,
                let majorVersion = Int(majorVersionString) {
                return majorVersion >= 9  // SE, 6s, 6s+ have 8,x
            }
        }
        return false
    }

    static var has3DTouch: Bool {
        let modelString = hardwareModel
        if modelString.contains("iPhone") {
            // some exceptions (SE, XR)
            guard modelString != "iPhone8,4" && modelString != "iPhone11,8" else { return false }

            if let majorVersionString = modelString.replacingOccurrences(of: "iPhone", with: "").components(separatedBy: ",").first,
                let majorVersion = Int(majorVersionString) {
                return majorVersion >= 8 // 6s == 8,1
            }
        }
        return false
    }

    static let isiPad: Bool = {
        return UIDevice.current.model == "iPad"
    }()
}
