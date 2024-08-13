//
//  FullScreenImageViewController.swift
//  BeachInfo
//
//  Created by Don Browning on 8/12/24.
//

import Foundation
import UIKit

class FullScreenImageViewController: UIViewController {
    
    var image: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        let imageview = UIImageView(image: image)
        imageview.contentMode = .scaleAspectFit
        imageview.frame = view.bounds
        imageview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(imageview)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        // Removing the force rotate b/c i don't like the experience but this implementation is great
        // forceRotateToLandscape()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    func forceRotateToLandscape() {
        // Force device orientation to landscape
        if UIDevice.current.orientation != .landscapeLeft && UIDevice.current.orientation != .landscapeRight {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            
            setDeviceOrientation(orientation: .landscapeRight)
        }
    }
    
    @objc func dismissFullscreenImage() {
        setDeviceOrientation(orientation: .portrait)
        dismiss(animated: true, completion: nil)
    }
    
    
    
}

extension UIViewController {
    
    func setDeviceOrientation(orientation: UIInterfaceOrientationMask) {
        if #available(iOS 16.0, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
        } else {
            UIDevice.current.setValue(orientation.toUIInterfaceOrientation.rawValue, forKey: "orientation")
        }
    }
}

extension UIInterfaceOrientationMask {
    var toUIInterfaceOrientation: UIInterfaceOrientation {
        switch self {
        case .portrait:
            return UIInterfaceOrientation.portrait
        case .portraitUpsideDown:
            return UIInterfaceOrientation.portraitUpsideDown
        case .landscapeRight:
            return UIInterfaceOrientation.landscapeRight
        case .landscapeLeft:
            return UIInterfaceOrientation.landscapeLeft
        default:
            return UIInterfaceOrientation.unknown
        }
    }
}
