//
//  flickrApp.swift
//  flickr
//
//  Created by Amanda Baret on 2022/11/24.
//

import SwiftUI

@main
struct flickrApp: App {
    @StateObject var launchScreenState = LaunchScreenStateManager()
       
       var body: some Scene {
           WindowGroup {
               ZStack {
                   HomeView()
                       .environmentObject(ImagesStore())
                   
                   if launchScreenState.state != .finished {
                       LaunchScreenView()
                   }
               }.environmentObject(launchScreenState)
           }
       }
}
