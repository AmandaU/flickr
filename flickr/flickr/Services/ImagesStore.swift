//
//  ImagesViewModel.swift
//  flickr
//
//  Created by Amanda Baret on 2022/11/24.
//

import Foundation
import Foundation
import Combine
import SwiftUI
import MapKit

class ImagesStore: ObservableObject {
    @Published var images = [Photo]()
    @Published var loading = false
    @Published var page = 1
    
    private let api: ImagesApi
    private var disposables = Set<AnyCancellable>()
    var cancellationToken: AnyCancellable?
    private let searchImagesSubject = CurrentValueSubject<String, Never>("")
    
    public init(api: ImagesApi = ImagesApi()) {
        self.api = api
        self.searchImagesSubject
            .removeDuplicates()
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { searchStr in
                if !searchStr.isEmpty && searchStr.count > 1 {
                    self.getImages(search: searchStr)
                }
            }.store(in: &self.disposables)
        
    }
    
    private func getImages(search: String) {
        loading = true
        page = 1
        api.getImages(search: search, page: page)
            .sink(
                receiveCompletion: { (completion) in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error ):
                        print(error)
                    }
                },
                receiveValue: {
                    self.images = $0.photos.photo
                    self.loading = false
                })
            .store(in: &self.disposables)
    }
    
    func getNextPage(search: String) {
        if search.isEmpty {
            page = 1
            return
        }
        page += 1
        api.getImages(search: search, page: page)
            .sink(
                receiveCompletion: { (completion) in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error ):
                        print(error)
                    }
                },
                receiveValue: {
                    self.images.append(contentsOf: $0.photos.photo)
                })
            .store(in: &self.disposables)
    }
    
    func doSearch(_ search: String) {
        self.searchImagesSubject.send(search)
    }
    
   
}
