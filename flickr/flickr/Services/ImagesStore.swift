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
    
    private let api: ImagesApi
    private var disposables = Set<AnyCancellable>()
    var cancellationToken: AnyCancellable?
    private let searchImagesSubject = CurrentValueSubject<String, Never>("")
    private let cacheSearch = "SEARCH"
    
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
        loadLocal()
    }
    
    private func getImages(search: String) {
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
                    }
                },
                receiveValue: {
                    self.images = $0.photos.photo
                    self.loading = false
                    self.history = []
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
    
   
}
