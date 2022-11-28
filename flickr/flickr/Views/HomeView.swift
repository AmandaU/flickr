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
    @State var error: String?
    
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
            phoneView
        } else {
            tabletView
        }
    }
    
    
    // Stack navigation for pahone
    var phoneView: some View {
        NavigationView {
            ZStack {
                
                ScrollView {
                    SearchBarView($searchText)
                        .padding(.vertical)
                        .appropriatePlatformWidth()
                    if let error = error {
                        Text(error)
                            .font(.title)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                    photoGrid
                }
                if store.loading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
            
            .onReceive(store.photosFetched, perform: { error in
                self.error = error
            })
            .background(Color.black.opacity(0.05)).edgesIgnoringSafeArea(.bottom)
            .navigationBarHidden(false)
            .navigationBarTitle("Flickr Images")
            
        }
        .onRotate { orientation in
            self.orientation = UIDevice.current.orientation
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.black.opacity(0.05)).edgesIgnoringSafeArea(.bottom)
        .onAppear {
            store.loadLocal()
        }
    }
    
    // Catering for the double panel navigation mechanism for table views
    var tabletView: some View {
        NavigationView {
            VStack {
                SearchBarView($searchText)
                    .padding()
                Spacer()
            }
            ZStack {
                ScrollView {
                    if let error = error {
                        Text(error)
                            .font(.title)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                    photoGrid
                }
                if store.loading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .onReceive(store.photosFetched, perform: { error in
                self.error = error
            })
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
    @State var showFullImage = false
    
    var url: URL {
        URL(string: "https://farm\(photo.farm).static.flickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_q.jpg")!
    }
    
    var body: some View {
        Button {
            showFullImage = true
        } label: {
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
        .fullScreenCover(isPresented: $showFullImage) {
            FullImageView(photo: photo)
        }
        .accessibilityIdentifier("photoButton")
    }
}
