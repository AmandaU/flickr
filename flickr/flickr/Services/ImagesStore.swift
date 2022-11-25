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
        api.getImages(search: search)
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
                    self.images = $0.photos.photo.map({Photo(dto: $0)})
                    self.loading = false
                })
            .store(in: &self.disposables)
    }
    
    func doSearch(_ search: String) {
        self.searchImagesSubject.send(search)
    }
    
   
}
