//
//  APIProtocol.swift
//  flickr
//
//  Created by Amanda Baret on 2022/11/26.
//

import Foundation
import Combine

protocol APIProtocol {
    var apiEndPoint: String { get }
    func getImages(search: String, page: Int) -> AnyPublisher<FlickrImages, Error>
    func getImage(url: String) -> AnyPublisher<Data, Error> 
}
