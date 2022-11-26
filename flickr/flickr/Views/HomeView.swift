//
//  SplashView.swift
//  flickr
//
//  Created by Amanda Baret on 2022/11/24.
//

import Foundation
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: ImagesStore
    @State var update = false
    @State var searchText = ""
    @State var orientation = UIDevice.current.orientation
    
    var columns: [GridItem] {
        var number = 0
        if Device.isMacCatalyst {
            number = 3
        } else if orientation == .unknown {
            number = UIScreen.main.bounds.width > UIScreen.main.bounds.height ? 3 : 2
        } else if orientation.isLandscape {
            number = 3
        } else {
            number = 2
        }
        let spacing = CGFloat(number * 4)
        return  Array(repeating: GridItem(.flexible(), spacing: spacing, alignment: .trailing), count: number)
    }
    
    var body: some View {
        
        if Device.isIPhone {
            NavigationView {
                ZStack {
                    ScrollView {
                        SearchBarView($searchText)
                            .padding(.vertical)
                            .appropriatePlatformWidth()
                       photoGrid
                    }
                    if store.loading {
                        ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(Color.black.opacity(0.05)).edgesIgnoringSafeArea(.bottom)
                .navigationBarHidden(false)
                .navigationBarTitle("Flickr Images")
                .onRotate { orientation in
                    self.orientation = UIDevice.current.orientation
                }
            }
            .onAppear {
                store.loadLocal()
            }
            
        } else {
            
            NavigationView {
                VStack {
                    SearchBarView($searchText)
                        .padding()
                    Spacer()
                }
                   ZStack {
                        ScrollView {
                            photoGrid
                        }
                        if store.loading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                   .navigationBarHidden(false)
                   .navigationBarTitle("Flickr Images", displayMode: .inline)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color.black.opacity(0.05)).edgesIgnoringSafeArea(.bottom)
           
            .onRotate { orientation in
                self.orientation = UIDevice.current.orientation
            }
            .onAppear {
                store.loadLocal()
            }
        }
    }
    
    var photoGrid: some View {
        VStack {
            
            LazyVGrid(columns: columns) {
                ForEach(store.images, id: \.id) { photo in
                    PhotoView(photo: photo)
                }
                if  !store.images.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onAppear {
                            store.page += 1
                            self.store.getNextPage(search: searchText)
                        }
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
}

private struct PhotoView: View {
    @EnvironmentObject var store: ImagesStore
    @State var photo: Photo
    
    var url: URL {
        URL(string: "https://farm\(photo.farm).static.flickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_q.jpg")!
    }
    
    var body: some View {
       
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
           Text("")
        }
        .cornerRadius(10)
        .padding(.bottom, 8)
    }
}
