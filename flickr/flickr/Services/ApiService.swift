//
//  ImagesAPI.swift
//  flickr
//
//  Created by Amanda Baret on 2022/11/24.
//

import Foundation
import Combine
import UIKit

public class ImagesApi: APIProtocol {
    
    let apiEndPoint: String = "www.flickr.com"
 
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
    
    func getImages(search: String, page: Int) -> AnyPublisher<FlickrImages, Error>  {
        //  var request = URLRequest(url:  URL(string: "https://jsonplaceholder.typicode.com/users")!)
        do {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "www.flickr.com"
        urlComponents.path = "/services/rest"
            
        guard let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String else {
            throw APIError.invalidAPIKey
        }
        
        var items = [URLQueryItem]()
        items.append(URLQueryItem(name: "method", value: "flickr.photos.search"))
        items.append(URLQueryItem(name: "api_key", value: apiKey))
        items.append(URLQueryItem(name: "text", value: search))
        items.append(URLQueryItem(name: "format", value: "json"))
        items.append(URLQueryItem(name: "nojsoncallback", value: "1"))
            items.append(URLQueryItem(name: "page", value: String(page)))
            items.append(URLQueryItem(name: "per_page", value: "10"))
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
        
        return run(request)
            .map(\.value)
            .eraseToAnyPublisher()
            
        } catch {
            return Fail<FlickrImages, Error>(error: error)
                .eraseToAnyPublisher()
        }
    }
    
     func getImage(url: String) -> AnyPublisher<Data, Error>  {
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
                .tryMap({ (data: Data, response: URLResponse) in
                    guard let response = response as? HTTPURLResponse else {
                        throw APIError.invalidHTTPURLResponse
                    }
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
