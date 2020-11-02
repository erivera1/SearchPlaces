//
//  Place.swift
//  SearchPlaces
//
//  Created by Eliric on 10/28/20.
//

import Foundation

struct PlaceData: Codable{
    let results: Results
}

struct Results:Codable {
    let items: [Items]?
}

struct Items: Codable {
    let position:[Double]
    let distance:Int
    let title:String
    let icon:String
    let vicinity:String
    let averageRating: Int
}




