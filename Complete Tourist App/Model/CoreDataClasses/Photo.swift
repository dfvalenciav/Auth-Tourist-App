//
//  Photo.swift
//  Complete Tourist App
//
//  Created by Daniel Felipe Valencia Rodriguez on 29/08/22.
//

import Foundation
import CoreData
import UIKit

@objc(Photo)
public class Photo: NSManagedObject {

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.creationDate = Date()
        self.id = UUID()
    }
}
