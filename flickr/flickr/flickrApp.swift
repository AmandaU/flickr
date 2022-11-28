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
                   
                   // Pasing the api key in so that we can test its validity. This api key comes from the config file which, in normal circumstances must not be committed to git and must be re-created by the person running the project, with their own api key
                   HomeView()
                       .environmentObject(ImagesStore(apiKey:  Bundle.main.infoDictionary?["API_KEY"] as? String))
                   
                   if launchScreenState.state != .finished {
                       LaunchScreenView()
                   }
               }.environmentObject(launchScreenState)
           }
       }
}
