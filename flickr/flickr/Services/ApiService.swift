//
//  ImagesAPI.swift
//  flickr
//
//  Created by Amanda Baret on 2022/11/24.
//

import Foundation
import Combine
import UIKit

//992e2fc8c28a0602d12cae83ebc1913f
//
//Secret:
//842ac8c24d5c7100

//https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=2e03720218b7eaec180dc21e7276c112&text=sunset&format=json&nojsoncallback=1&api_sig=481e2b3563447536c45d757023737f85

struct ApiService {
    struct Response<T> {
        let value: T
        let response: URLResponse
    }
    
    func run<T: Decodable>(_ request: URLRequest, _ decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<Response<T>, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request) // 3
            .tryMap { result -> Response<T> in
#if DEBUG
        if let jsonString = String(data: result.data, encoding: .utf8) {
            print(jsonString)
        }
#endif
                let value = try decoder.decode(T.self, from: result.data) // 4
                return Response(value: value, response: result.response) // 5
            }
            .receive(on: DispatchQueue.main) // 6
            .eraseToAnyPublisher() // 7
    }
}

enum ImagesApi {
    static let apiService = ApiService()
}

extension ImagesApi {
    
    static func getImages(search: String) -> AnyPublisher<FlickrImages, Error>  {
        //  var request = URLRequest(url:  URL(string: "https://jsonplaceholder.typicode.com/users")!)
        do {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "www.flickr.com"
        urlComponents.path = "/services/rest"
        
        var items = [URLQueryItem]()
        items.append(URLQueryItem(name: "method", value: "flickr.photos.search"))
        items.append(URLQueryItem(name: "api_key", value: "992e2fc8c28a0602d12cae83ebc1913f"))
        items.append(URLQueryItem(name: "text", value: search))
        items.append(URLQueryItem(name: "format", value: "json"))
        items.append(URLQueryItem(name: "nojsoncallback", value: "1"))
        urlComponents.queryItems = items
        
        guard let requestURL = urlComponents.url else {
            print(urlComponents.url)
            throw APIError.invalidURL
        }
            
        print(requestURL)
        var request: URLRequest = URLRequest(url: requestURL)
        let headers = [
            // "Authorization": "Bearer \(accessToken)",
            "Accept": "*/*",
            "Content-Type": "application/json"
        ]
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        return apiService.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
            
        } catch {
            return Fail<FlickrImages, Error>(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    static func getImageUrl(photo: Photo) -> AnyPublisher<String, Error>  {
        var request = URLRequest(url:  URL(string: "https://farm\(photo.farm).static.flickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg")!)
        print(request)
       
        let headers = [
            // "Authorization": "Bearer \(accessToken)",
            "Accept": "*/*",
            "Content-Type": "application/json"
        ]
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let urlSession = URLSession(configuration: .default)
     
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        return urlSession.dataTaskPublisher(for: request)
            .retry(3)
            .tryMap({ (data: Data, response: URLResponse) in

                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? String {
                    return json
                }
                return ""
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    static func getImage(url: String) -> AnyPublisher<Data, Error>  {
        do {
            guard let requestURL = URL(string: url) else {
                throw APIError.invalidURL
            }
            
            let headers = [
                // "Authorization": "Bearer \(accessToken)",
                "Accept": "image/*",
                "Content-Type": "image/*"
            ]
            
            let urlSession = URLSession(configuration: .default)
            var request: URLRequest = URLRequest(url: requestURL)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            return urlSession.dataTaskPublisher(for: requestURL)
                .retry(3)
                .tryMap({ (data: Data, response: URLResponse) in
                    guard let response = response as? HTTPURLResponse else {
                        throw APIError.invalidHTTPURLResponse
                    }
//                    
//                    if response.statusCode != 1 {
//                        throw APIError.responseStatusError
//                    }
                    return data
                })
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        } catch {
            return Fail<Data, Error>(error: error)
                .eraseToAnyPublisher()
        }
    }
}
