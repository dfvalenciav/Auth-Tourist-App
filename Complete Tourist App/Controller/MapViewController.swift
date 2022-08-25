//
//  MapViewController.swift
//  Complete Tourist App
//
//  Created by Daniel Felipe Valencia Rodriguez on 23/08/22.
//

import Foundation
import UIKit
import MapKit
class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var dataController : DataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    var longGestureRecognizer: UILongPressGestureRecognizer!
    private var selectedLocation: CLLocation?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}
