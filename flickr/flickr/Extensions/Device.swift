//
//  Device.swift
//  flickr
//
//  Created by Amanda Baret on 2022/11/24.
//

import Foundation
import UIKit

public struct Device {
    
    public static var idiom: UIUserInterfaceIdiom {
        UIDevice.current.userInterfaceIdiom
    }
    
    public static var isIPad: Bool {
#if targetEnvironment(macCatalyst)
        return false
#else
        idiom == .pad
#endif
        
    }
    
    public static var isIPhone: Bool {
        idiom == .phone
    }
    
    public static var isMac: Bool {
        if #available(iOS 14.0, *) {
            return idiom == .mac
        }
        return false
    }
    
    public static var isMacCatalyst: Bool {
#if targetEnvironment(macCatalyst)
        return true
#else
        return false
#endif
    }
   
}

public extension UIDevice {
    
    var currentPerspectiveWidth: CGFloat {
#if targetEnvironment(macCatalyst)
        return UIScreen.main.bounds.height
#else
        if let interfaceOrientation = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation {
            if interfaceOrientation.isLandscape, (UIScreen.main.bounds.width < UIScreen.main.bounds.height) {
                
                return UIScreen.main.bounds.height
            } else {
                return UIScreen.main.bounds.width
            }
        }
        return UIScreen.main.bounds.width
#endif
        
    }
}
