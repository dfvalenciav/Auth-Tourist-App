//
//  PhotoViewController.swift
//  Complete Tourist App
//
//  Created by Daniel Felipe Valencia Rodriguez on 23/08/22.
//

import Foundation
import UIKit
import MapKit
import CoreData



class PhotoViewController : UIViewController{
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var noPhotosFoundLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Properties
    
    var pin: Pin!
    var selectedLocation: CLLocation!
    var dataController : DataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    
    private var shouldDownload = true
    private var photosInfo = [FlickrReponse]()
    private var blockOperations = [BlockOperation]()
    private var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    
    // MARK: - LifeCycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        setupCollectionView()
        setupFlowLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupData()
        noPhotosFoundLabel.isHidden = true
        
        setCenterRegion(coordinate: selectedLocation.coordinate)
        addPin(coordinate: selectedLocation.coordinate)
    }
    
    
    //  MARK: - Initialization Functions
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupFlowLayout() {
        flowLayout.minimumLineSpacing = 1.0
        flowLayout.minimumInteritemSpacing = 1.0
    }
    
    private func setupData() {
        activityIndicator.startAnimating()
        shouldDownload = pin.photos?.count ?? 0 <= 0
        DataModel.photosData = []
       
        if shouldDownload {
            fetchPhotos(coordinate: selectedLocation.coordinate)
        } else {
            setupFetchedResultsController()
            let photos = fetchedResultsController.fetchedObjects ?? []
            DataModel.photosData = photos.map { $0.image! }
            activityIndicator.stopAnimating()
        }
    }
    
    
    
    
    // MARK: - Button Related Functions
    

    @IBAction func newCollectionButtonPressed(_ sender: Any) {
        
        fetchedResultsController = nil
        DataModel.photosData = []
        photosInfo = []
        
        collectionView.reloadData()
        
        self.dataController.viewContext.performAndWait{
            let pinToDeletePhotos = dataController.viewContext.object(with: self.pin.objectID) as! Pin
            pinToDeletePhotos.photos = []
            try? dataController.viewContext.save()
        }
        
        setupData()
    }
    
    private func setDownloadingState(isDownloading: Bool) {
        newCollectionButton.isEnabled = !isDownloading
        if isDownloading {
            newCollectionButton.setTitle("Downloading", for: .disabled)
        } else {
            newCollectionButton.setTitle("New Collection", for: .normal)
        }
      
        
    }
    
    
    // MARK: - Map Related Functions
    
    private func setCenterRegion(coordinate: CLLocationCoordinate2D) {
        let distance: CLLocationDistance = 100000.0
        let coordinate2D = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let region = MKCoordinateRegion(center: coordinate2D, latitudinalMeters: distance, longitudinalMeters: distance)
        mapView.setRegion(region, animated: true)
    }
    
    private func addPin(coordinate: CLLocationCoordinate2D) {
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
    }
    
    
    
    // MARK: - Networking Related Functions

    private func fetchPhotos(coordinate: CLLocationCoordinate2D) {
        
        setDownloadingState(isDownloading: true)
        FlickrClient.getPhotosList(latitude: coordinate.latitude, longitude: coordinate.longitude, completion: handleGetPhotosList(photosInfo:error:))
    }
    
    private func handleGetPhotosList(photosInfo: [FlickrReponse], error: Error?) {
        self.noPhotosFoundLabel.isHidden = photosInfo.count > 0
        
        if let error = error {
            self.alertError(title: "Error in fetching photos", message: "\(error.localizedDescription)")
        }
        activityIndicator.stopAnimating()
        self.photosInfo = photosInfo
        collectionView.reloadData()
        setDownloadingState(isDownloading: false)
    }
    
    
    // MARK: - Alert Message Functions
    
    private func confirmDelete(itemAt indexPath: IndexPath) {
        let alertVC = UIAlertController(title: "Are you sure?", message: "Do you really want to delete this photo?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deletePhoto(indexPath: indexPath)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        [deleteAction, cancelAction].forEach { alertVC.addAction($0) }
        present(alertVC, animated: true)
    }
    
    private func alertError(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alertVC, animated: true)
    }
    
    
    
    // MARK: - CoreData Related Functions
    
    private func setupFetchedResultsController() {
        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            fatalError("error in fetching photos: \(error.localizedDescription)")
        }
    }
    
    
    private func deletePhoto(indexPath: IndexPath) {
        setupFetchedResultsController()

        DataModel.photosData.remove(at: indexPath.item)
        if shouldDownload {
            photosInfo.remove(at: indexPath.item)
        }
        
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        pin.removeFromPhotos(photoToDelete)
        try? dataController.viewContext.save()
    }
    
    deinit {
        blockOperations.forEach{ $0.cancel() }
        blockOperations.removeAll(keepingCapacity: false)
    }
}




// MARK: - UICollectionViewDelegateFlowLayout

extension PhotoViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 5) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 5, left: 2, bottom: 2, right: 0)
    }
    
}



// MARK: - UICollectionViewDataSource

extension PhotoViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        confirmDelete(itemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCellViewController", for: indexPath) as! PhotoCellViewController
        cell.dataController = self.dataController
        
        if DataModel.photosData.count > indexPath.item {
            let imageData = DataModel.photosData[indexPath.item]
            cell.imageCell.image = UIImage(data: imageData)
        } else {
            cell.downloadPhoto(for: photosInfo[indexPath.item], pin: pin)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if shouldDownload {
            return photosInfo.count
        }
        return DataModel.photosData.count
    }
    
    
}



// MARK: - MKMapViewDelegate

extension PhotoViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinId = "pinId"
        return setupAnnotationView(mapView, pinId: pinId, annotation: annotation)
    }
}



// MARK: - NSFetchedResultsControllerDelegate

extension PhotoViewController: NSFetchedResultsControllerDelegate {
    
    private func deleteOperation(_ indexPath: IndexPath?) -> BlockOperation {
        return BlockOperation(block: { [weak self] in
            if let this = self {
                this.collectionView!.deleteItems(at: [indexPath!])
            }
        })
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            blockOperations.append(deleteOperation(indexPath))
        default: break
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll(keepingCapacity: false)
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView!.performBatchUpdates({ () -> Void in
            blockOperations.forEach { $0.start() }
        }, completion: { (finished) -> Void in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
    }
}
