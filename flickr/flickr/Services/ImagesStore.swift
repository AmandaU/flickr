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
    @Published var searchText = ""
    @Published var history: [String] = []
    
    let photosFetched = PassthroughSubject<String?, Never>()
    private let api: APIProtocol
    private var disposables = Set<AnyCancellable>()
    var cancellationToken: AnyCancellable?
    private let searchImagesSubject = CurrentValueSubject<String, Never>("")
    private let cacheSearch = "SEARCH"
    
    public init(apiKey: String?) {
        self.api = ImagesAPI(apiKey: apiKey)
        
        self.searchImagesSubject
            .removeDuplicates()
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { searchStr in
                if !searchStr.isEmpty && searchStr.count > 1 {
                    self.getImages(search: searchStr)
                }
            }.store(in: &self.disposables)
        loadLocal()
    }
    
    func getImages(search: String) {
        loading = true
        page = 1
        saveLocal(search: search)
        api.getImages(search: search, page: page)
            .sink(
                receiveCompletion: { (completion) in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error ):
                        print(error)
                        self.photosFetched.send("There was a problem fetching the images.")
                    }
                },
                receiveValue: {
                    self.images = $0.photos.photo
                    self.loading = false
                    self.history = []
                    self.photosFetched.send(self.images.isEmpty ? "There are currenty no Flickr images to display" : nil)
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
    
    func saveLocal(search: String) {
        let search = search.trimmingCharacters(in: .whitespacesAndNewlines)
        var searches: [String] = []
        if let searchArray = UserDefaults.standard.object(forKey: self.cacheSearch) as? [String] {
            searches = searchArray
        }
        if !searches.contains(search) {
            searches.append(search)
        }
        UserDefaults.standard.set(searches, forKey: self.cacheSearch)
    }
    
    func loadLocal() {
        if let searches = UserDefaults.standard.object(forKey: self.cacheSearch) as? [String] {
            self.history =  searches
        } else {
            self.history = []
        }
    }
    
    func clearHistory() {
        let clear: [String] = []
        UserDefaults.standard.set(clear, forKey: self.cacheSearch)
        self.history = []
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, onDone: @escaping (UIImage) -> Void) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            // always update the UI from the main thread
            DispatchQueue.main.async() { [weak self] in
                onDone(UIImage(data: data) ?? UIImage())
            }
        }
    }
   
}
