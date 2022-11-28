//
//  Errors.swift
//  flickr
//
//  Created by Amanda Baret on 2022/11/24.
//

import Foundation


// The API error
enum APIError: Error {
  case invalidURL
    case invalidHTTPURLResponse
    case responseStatusError
    case invalidAPIKey
}
