//
//  PlaceViewModel.swift
//  SearchPlaces
//
//  Created by Eliric on 10/29/20.
//

import Foundation

struct PlaceViewModel {
    let position:[Double]
    let distance:Int
    let title:String
    let icon:String
    
    init(items:Items?) {
        let iconString = "https://download.vcdn.cit.data.here.com/p/d/places2_stg/icons/categories/01.icon"
        let unknownString = "unknown"
        self.position = items?.position ?? [0.0, 0.0]
        self.distance = items?.distance ?? 0
        var title = items?.title
        if(title == ""){
            title = unknownString
        }
        self.title = title ?? unknownString
        var icon = items?.icon
        if(icon == ""){
            icon = iconString
        }
        self.icon = icon ?? iconString
    }
    
}
