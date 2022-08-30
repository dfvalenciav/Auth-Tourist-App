//
//  FlickrResponse.swift
//  Complete Tourist App
//
//  Created by Daniel Felipe Valencia Rodriguez on 29/08/22.
//

import Foundation
import UIKit


struct FlickrReponse: Codable, Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.imageURL == rhs.imageURL
    }
        
    let id: String
    let owner: String?
    let secret: String
    let server: String
    let farm: Int
    let title: String?
    let ispublic: Int?
    let isfriend: Int?
    let isfamily: Int?
    
    var imageURL: URL {
        return URL(string:
            "https://farm\(farm).staticflickr.com/" +
            "\(server)/\(id)_\(secret).jpg"
        )!
    }
    
    @discardableResult
    func retrievePhoto(
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) -> URLSessionDataTask {
        
        let task = URLSession.shared.dataTask(with: imageURL) {
            data, urlResponse, error in
            
            guard let data = data,
                    let image = UIImage(data: data)
            else {
                completion(.failure(error ?? NSError()))
                return
            }
            
            completion(.success(image))
        }
        task.resume()
        return task
        
    }
}

struct PageMetadata: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [FlickrReponse]
}

struct PhotosInfoResponse: Codable {
    let photos: PageMetadata
    let stat: String
}

struct PhotoData: Codable {
    let info: FlickrReponse
    var imageData: Data
}

struct FlickrPhotosData: Decodable {
    
    let photos: [FlickrReponse]
    let totalPages: Int
    
    init(from decoder: Decoder) throws {
        let topLevelContainer = try decoder.container(
            keyedBy: TopLevelKeys.self
        )
        let photosDataContainer = try topLevelContainer.nestedContainer(
            keyedBy: PhotosKeys.self,
            forKey: .photos
        )
        
        self.photos = try photosDataContainer.decode(
            [FlickrReponse].self, forKey: .photo
        )
        
        let putativeTotalPages = try photosDataContainer.decode(
            Int.self, forKey: .totalPages
        )
        self.totalPages = min(putativeTotalPages, 100)
        
    }
    
    enum TopLevelKeys: String, CodingKey {
        case photos, stat
    }
    
    enum PhotosKeys: String, CodingKey {
        case page
        case totalPages = "pages"
        case perpage
        case totalPhotos = "total"
        case photo
    }
}
