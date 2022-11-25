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
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: Device.isIPhone ? 8 : 16, alignment: .trailing), count: Device.isIPhone ? 2 : 3)
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                ScrollView {
                    
                    SearchBarView( $searchText.onChange { searchText in
                        self.store.doSearch(searchText)
                    }) .padding()
                    
                    VStack {
                        LazyVGrid(columns: columns, spacing: Device.isIPhone ? 0 : 16) {
                            ForEach(store.images, id: \.id) { photo in
                                PhotoView(photo: photo)
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    
                }
                if store.loading {
                    VStack {
                        ProgressView()
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color.black.opacity(0.05)).edgesIgnoringSafeArea(.bottom)
            .navigationBarHidden(false)
            .navigationBarTitle(Text("Flickr Images"))
            .toolbarBackground( Color.white, for: .navigationBar)
        }
    }
}

private struct PhotoView: View {
    @EnvironmentObject var store: ImagesStore
    @State var photo: Photo
    
    var width: CGFloat {
        return Device.isIPhone ? (UIScreen.main.bounds.width/2) - 20 : 300
    }
    
    var url: URL {
        URL(string: "https://farm\(photo.farm).static.flickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_q.jpg")!
    }
    
    var body: some View {
       
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            VStack {
                ProgressView()
            }
            .background(Color.black.opacity(0.05))
                .cornerRadius(10)
        }
        .frame(width: width, height: width)
        .cornerRadius(10)
        .padding(.bottom, 8)
    }
}
