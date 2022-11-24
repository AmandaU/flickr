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
