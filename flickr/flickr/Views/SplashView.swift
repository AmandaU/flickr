//
//  SplashView.swift
//  flickr
//
//  Created by Amanda Baret on 2022/11/24.
//

import SwiftUI

// Just a fancy animation for ther splash
struct LaunchScreenView: View {
    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager // Mark 1
    
    @State private var firstAnimation = false  // Mark 2
    @State private var secondAnimation = false // Mark 2
    @State private var startFadeoutAnimation = false // Mark 2
    
    @ViewBuilder
    private var image: some View {  // Mark 3
        Image("Splash")
            .resizable()
            .scaledToFit()
            .frame(width: 300, height: 300)
            .rotationEffect(firstAnimation ? Angle(degrees: 900) : Angle(degrees: 1800)) // Mark 4
            .scaleEffect(secondAnimation ? 0 : 1) // Mark 4
            .offset(y: secondAnimation ? 400 : 0) // Mark 4
            .shadow(color: Color("Flickr"), radius: 50, x: 5, y: 25)
    }
    
    @ViewBuilder
    private var backgroundColor: some View {  // Mark 3
        Color.white.ignoresSafeArea()
    }
    
    private let animationTimer = Timer // Mark 5
        .publish(every: 0.5, on: .current, in: .common)
        .autoconnect()
    
    var body: some View {
        ZStack {
            backgroundColor  // Mark 3
            image  // Mark 3
        }.onReceive(animationTimer) { timerValue in
            updateAnimation()  // Mark 5
        }.opacity(startFadeoutAnimation ? 0 : 1)
            .task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                self.launchScreenState.dismiss()
            }
    }
    
    private func updateAnimation() { // Mark 5
        switch launchScreenState.state {
        case .firstStep:
            withAnimation(.easeInOut(duration: 0.9)) {
                firstAnimation.toggle()
            }
        case .secondStep:
            if secondAnimation == false {
                withAnimation(.linear) {
                    self.secondAnimation = true
                    startFadeoutAnimation = true
                }
            }
        case .finished:
            // use this case to finish any work needed
            break
        }
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView()
            .environmentObject(LaunchScreenStateManager())
    }
}
