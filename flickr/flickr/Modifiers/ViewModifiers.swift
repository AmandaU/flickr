//
//  ViewModifiers.swift
//  flickr
//
//  Created by Amanda Baret on 2022/11/25.
//

import Foundation
import UIKit
import SwiftUI

struct PlatformWidth: ViewModifier {
    
    var platFormPadding: CGFloat {
        if Device.isIPad {
           return UIDevice.current.currentPerspectiveWidth * 0.1
        }
        return 20
    }
    func body(content: Content) -> some View {
        content
#if os(iOS)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, platFormPadding)
#endif
#if targetEnvironment(macCatalyst)
            .frame(width: UIDevice.current.currentPerspectiveWidth * 0.8)
#endif
        
    }
}

public extension View {
    func appropriatePlatformWidth() -> some View {
        modifier(PlatformWidth())
    }
}


struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    public func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}
