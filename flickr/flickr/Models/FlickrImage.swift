//
//  Image.swift
//  flickr
//
//  Created by Amanda Baret on 2022/11/24.
//

import Foundation
// MARK: - Welcome
struct FlickrImages: Codable {
    let photos: Photos
    let stat: String
    
    init() {
        self.photos = Photos()
        self.stat = ""
    }
}

// MARK: - Photos
struct Photos: Codable {
    let page, pages, perpage, total: Int
    let photo: [PhotoDTO]
    
    init() {
        self.photo = []
        self.page = 0
        self.pages = 0
        self.perpage = 0
        self.total = 0
    }
}

// MARK: - Photo
struct PhotoDTO: Codable {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
}

struct Photo {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
    
    init(dto: PhotoDTO) {
        self.id = dto.id
        self.owner = dto.owner
        self.secret = dto.secret
        self.server = dto.server
        self.farm = dto.farm
        self.title = dto.title
        self.ispublic = dto.ispublic
        self.isfriend = dto.isfriend
        self.isfamily = dto.isfamily
    }
}
