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
    @State var searchText: String = ""
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16, alignment: .trailing), count: Device.isIPhone ? 2 : 3)
    
    var body: some View {
        
        NavigationView {
            VStack {
                ScrollView {
                    VStack {
                        SearchBarView( $searchText.onChange { searchText in
                            self.store.doSearch(searchText)
                        })
                        .padding()
                        
                        LazyVGrid(columns: columns, spacing: Device.isIPhone ? 0 : 16) {
                            ForEach(store.images.photos.photo, id: \.id) { photo in
                                
                                ImageView(photo: photo)
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
            .background(Color.black.opacity(0.1)).edgesIgnoringSafeArea(.bottom)
            .navigationBarHidden(false)
            .navigationBarTitle(Text("Flickr Images"))
            .toolbarBackground( Color.white, for: .navigationBar)
        }
        
        
    }
    
}

private struct ImageView: View {
    @EnvironmentObject var store: ImagesStore
    @State var photo: Photo
    @State var image: UIImage?
    @State var loaded = false
    
    var width: CGFloat {
        return Device.isIPhone ? (UIScreen.main.bounds.width/2) - 40 : 300
    }
    
    var body: some View {
        
        LoadingView(isShowing: .constant(!loaded)) {
            HStack {
                
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: width, maxHeight: width)
                }
            }
        }
        .frame(width: width, height: width)
        .background(Color.white)
        .cornerRadius(14)
        .padding()
        .onAppear {
            
            store.getImage(photo: photo) { image in
                    self.image = image
                    self.loaded = true
            }
        }
    }
}

