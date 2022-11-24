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
    @Published var images = FlickrImages()
    var cancellationToken: AnyCancellable?
    private var disposables = Set<AnyCancellable>()
    private let searchImagesSubject = CurrentValueSubject<String, Never>("")
    
    public init() {
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
        cancellationToken = ImagesApi.getImages(search: search)
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
                    self.images = $0
                })
    }
    
    func doSearch(_ search: String) {
        self.searchImagesSubject.send(search)
    }
    
    func getImage(photo: Photo,  onDone: @escaping (UIImage?) -> Void) {
        cancellationToken = getPicture(photo: photo)
            .sink(
                receiveCompletion: { (completion) in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error ):
                        print(error)
                    }
                },
                receiveValue: { image in
                    onDone(image)
                })
    }
    
    
     func getPicture(photo: Photo) -> AnyPublisher<UIImage?, Error> {
//         var url = URLRequest(url:  URL(string: "https://farm\(photo.farm).static.flickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg")!)
         var url =  "https://farm\(photo.farm).static.flickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg"
//        return ImagesApi.getImageUrl(photo: photo)
//            .flatMap({ (url : String) -> AnyPublisher<UIImage?, Error> in
                return ImagesApi.getImage(url: url)
                    .map({ (data: Data) in
                        return UIImage(data: data)
                    })
                    .eraseToAnyPublisher()
//            })
//            .eraseToAnyPublisher()
    }
    
}
