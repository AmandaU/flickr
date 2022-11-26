//
//  DummyAPI.swift
//  flickr
//
//  Created by Amanda Baret on 2022/11/26.
//

import Foundation
import Combine

public class DummyAPI: APIProtocol {
    var apiEndPoint: String = "www.nowhere"
    
    func getImages(search: String, page: Int) -> AnyPublisher<FlickrImages, Error> {
        do {
           throw APIError.testFail
            
        } catch {
            return Fail<FlickrImages, Error>(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    func getImage(url: String) -> AnyPublisher<Data, Error> {
        do {
           throw APIError.testFail
            
        } catch {
            return Fail<Data, Error>(error: error)
                .eraseToAnyPublisher()
        }
    }
    
}
