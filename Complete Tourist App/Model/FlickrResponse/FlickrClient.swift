//
//  FlickrClient.swift
//  Complete Tourist App
//
//  Created by Daniel Felipe Valencia Rodriguez on 29/08/22.
//

import Foundation
import CoreLocation
import UIKit

class FlickrClient {
    
    static let apiKey = "086bb4e9237031ab922da8ffe54feb5f"
    
    enum EndPoints {
        static let apiUrl = "https://www.flickr.com/services/rest"
        static let imageUrl = "https://live.staticflickr.com"
        
        static let methodParam = "/?method=flickr.photos.search"
        static let apiKeyParam = "&api_key=\(FlickrClient.apiKey)"
        static let formatParam = "&per_page=30&format=json&nojsoncallback=1"
        
        case search(latitude: Double, longitude: Double, page: Int)
        case downloadImage(server: String, id: String, secret: String)
        
        var stringValue: String {
            switch self {
            case .search(let lat, let lon, let page):
                return EndPoints.apiUrl + EndPoints.methodParam + EndPoints.apiKeyParam + EndPoints.formatParam + "&lat=\(lat)&lon=\(lon)&page=\(page)"
            case .downloadImage(let server, let id, let secret):
                return "\(EndPoints.imageUrl)/\(server)/\(id)_\(secret)_q.jpg"
            }
        }
        
        var url: URL {
            return URL(string: self.stringValue)!
        }
    }
    
    class func getPhotosList(latitude lat: Double, longitude lon: Double, completion: @escaping ([FlickrReponse], Error?) -> Void) {
        let page = getRandomPageNumber()
        let task = URLSession.shared.dataTask(with: EndPoints.search(latitude: lat, longitude: lon, page: page).url) { (data, response, error) in
            guard let data = data else { return }
            
            do {
                let result = try JSONDecoder().decode(PhotosInfoResponse.self, from: data)
                DispatchQueue.main.async {
                    DataModel.currentPhotosInfoResponse = result
                    completion(result.photos.photo, nil)
                }
            } catch {
                print("Error in decoding photos list: \(error)")
                DispatchQueue.main.async {
                    completion([], error)
                }
            }
        }
        
        task.resume()
    }
    
    class func downloadPhoto(photoInfo: FlickrReponse, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: EndPoints.downloadImage(server: photoInfo.server, id: photoInfo.id, secret: photoInfo.secret).url) { (data, response, error) in
            
            DispatchQueue.main.async {
                completion(data, nil)
            }
        }
        
        task.resume()
    }
    
    class func getRandomPageNumber() -> Int {
        guard let totalPages = DataModel.currentPhotosInfoResponse?.photos.pages,
              totalPages > 1
        else {
            return 1
        }
        let randomPage = Int.random(in: 1...totalPages)
        return randomPage
    }
}
