//
//  PhotoCellViewController.swift
//  Complete Tourist App
//
//  Created by Daniel Felipe Valencia Rodriguez on 29/08/22.
//

import Foundation
import UIKit

class PhotoCellViewController: UICollectionViewCell {
    
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var activityIndicatorCell: UIActivityIndicatorView!
    
    var dataController: DataController!
    var id: UUID? = nil
    
    func configure() {
        self.imageCell.image = nil
        self.imageCell.contentMode = .scaleAspectFill
        self.activityIndicatorCell.hidesWhenStopped = true
        //self.couldntLoadImageLabel.isHidden = true
    }
    
    func downloadPhoto(for photoInfo: FlickrReponse, pin: Pin) {
        FlickrClient.downloadPhoto(photoInfo: photoInfo) { (data, error) in
            guard let data = data else { return }
            
            self.savePhoto(pin: pin, photoData: data)
            self.imageCell.image = UIImage(data: data)
            DataModel.photosData.append(data)
        }
    }
    
    
    private func savePhoto(pin: Pin, photoData: Data) {
        let viewContext = dataController.viewContext// else { return }
        let pinToUpdate = viewContext.object(with: pin.objectID) as! Pin
        
        viewContext.perform {
            let photo = Photo(context: viewContext)
            photo.pin = pinToUpdate
            photo.image = photoData
            photo.creationDate = Date()
            try? viewContext.save()
        }
    }
    
}
