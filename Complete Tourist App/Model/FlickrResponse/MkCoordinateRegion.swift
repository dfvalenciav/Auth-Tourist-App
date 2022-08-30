//
//  MkCoordinateRegion.swift
//  Complete Tourist App
//
//  Created by Daniel Felipe Valencia Rodriguez on 29/08/22.
//

import Foundation
import MapKit

extension MKCoordinateRegion: Codable {
    
    // instance properties:
    // var center: CLLocationCoordinate2D
    // var span: MKCoordinateSpan
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let center = try container.decode(
            CLLocationCoordinate2D.self, forKey: .center
        )
        let span = try container.decode(
            MKCoordinateSpan.self, forKey: .span
        )
        self.init(center: center, span: span)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(
            keyedBy: CodingKeys.self
        )
        try container.encode(
            self.center, forKey: .center
        )
        try container.encode(
            self.span, forKey: .span
        )
        
    }
    
    enum CodingKeys: CodingKey {
        case center, span
    }
    
}



extension CLLocationCoordinate2D: Codable, Equatable, Hashable {
    
    // instance properties:
    // var latitude: CLLocationDegrees
    // var longitude: CLLocationDegrees

    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.latitude)
        hasher.combine(self.longitude)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        if lhs.latitude != rhs.latitude { return false }
        return lhs.longitude == rhs.longitude
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )
        let latitude = try container.decode(
            CLLocationDegrees.self, forKey: .latitude
        )
        let longitude = try container.decode(
            CLLocationDegrees.self, forKey: .longitude
        )
        
        self.init(latitude: latitude, longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(
            keyedBy: CodingKeys.self
        )
        
        try container.encode(
            self.latitude, forKey: .latitude
        )
    
        try container.encode(
            self.longitude, forKey: .longitude
        )
    }
    
    enum CodingKeys: CodingKey {
        case latitude, longitude
    }
    
}


extension MKCoordinateSpan: Codable {
    
    // instance properties:
    // var latitudeDelta: CLLocationDegrees
    // var longitudeDelta: CLLocationDegrees
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )
        let latitudeDelta = try container.decode(
            CLLocationDegrees.self, forKey: .latitudeDelta
        )
        let longitudeDelta = try container.decode(
            CLLocationDegrees.self, forKey: .longitudeDelta
        )
        
        self.init(
            latitudeDelta: latitudeDelta,
            longitudeDelta: longitudeDelta
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(
            keyedBy: CodingKeys.self
        )
        
        try container.encode(
            self.latitudeDelta, forKey: .latitudeDelta
        )
        
        try container.encode(
            self.longitudeDelta, forKey: .longitudeDelta
        )
    }
    
    
    
    enum CodingKeys: CodingKey {
        case latitudeDelta, longitudeDelta
    }
    
}
