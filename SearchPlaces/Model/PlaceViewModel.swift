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
        
        self.position = items?.position ?? [0.0, 0.0]
        self.distance = items?.distance ?? 0
        var title = items?.title
        if(title == ""){
            title = Constants.unknownString
        }
        self.title = title ?? Constants.unknownString
        var icon = items?.icon
        if(icon == ""){
            icon = Constants.iconString
        }
        self.icon = icon ?? Constants.iconString
    }
    
}
