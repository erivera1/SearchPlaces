//
//  Place+CoreDataProperties.swift
//  SearchPlaces
//
//  Created by Eliric on 10/29/20.
//
//

import Foundation
import CoreData


extension Place {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Place> {
        return NSFetchRequest<Place>(entityName: "Place")
    }

    @NSManaged public var distance: Int64
    @NSManaged public var icon: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var title: String?

}

extension Place : Identifiable {

}
