//
//  PlaceManager.swift
//  SearchPlaces
//
//  Created by Eliric on 10/28/20.
//

import Foundation
import CoreLocation
import UIKit
import CoreData

protocol PlaceManagerDelegate {
    func didUpdateItems(_ placeManager:PlaceManager, placesViewModel:[PlaceViewModel])
    func didFailWithError(error:Error)
}

struct PlaceManager {
    let apiId = "DemoAppId01082013GAL"
    let appCode = "AJKnXv84fjrb0KIHawS0Tg"
    let placeURL = "https://places.demo.api.here.com/places/v1/discover/search?"
    var delegate:PlaceManagerDelegate?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let entityName = "Place"

    func fetchPlace(name:String, coordinate:CLLocationCoordinate2D){
        let urlString = "\(placeURL)q=\(name)&at=\(coordinate.latitude)%2C\(coordinate.longitude)&app_id=\(apiId)&app_code=\(appCode)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString:String){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if(error != nil){
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data{
                    if let placesViewModel = self.parseJSON(safeData){
                        self.delegate?.didUpdateItems(self, placesViewModel: placesViewModel)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ placeData:Data) ->[PlaceViewModel]?{
        let decoder =  JSONDecoder()
        do {
            let decodedData = try decoder.decode(PlaceData.self, from: placeData)
            var placeModels:[PlaceViewModel]?
            if let tempItems = decodedData.results.items{
                //sort array by distance
                var items = tempItems.sorted(by: { $0.distance < $1.distance })
                //get nearest 10
                let arraySlice = items.prefix(10)
                items = Array(arraySlice)
                placeModels = items.map({return PlaceViewModel(items: $0)})
            }
            return placeModels
        } catch {
            print(error)
            delegate?.didFailWithError(error: error)
            return []
        }
    }
    
    //MARK: - Core Data
    
    func fetchData(){
        var itemsFromCoreData : [Place]?
        do{
            itemsFromCoreData = try context.fetch(Place.fetchRequest())
            if let places = itemsFromCoreData{
                var items = [Items]()
                for place in places as [Place]{
                    let item = Items(position: [place.latitude, place.longitude], distance: Int(place.distance), title: place.title ?? "", icon: place.icon ?? "", vicinity: "", averageRating: 0)
                    items.append(item)
                }
                let placesViewModels = items.map({return PlaceViewModel(items: $0)})
                self.delegate?.didUpdateItems(self, placesViewModel: placesViewModels)
            }
        }catch {
            print(error)
            delegate?.didFailWithError(error: error)
        }
    }
    
    func saveCoreData(placeviewModel:PlaceViewModel){
        let newPlace = Place(context:self.context)
        newPlace.distance = Int64(placeviewModel.distance)
        newPlace.title = placeviewModel.title
        newPlace.latitude = placeviewModel.position[0]
        newPlace.longitude = placeviewModel.position[1]
        newPlace.icon = placeviewModel.icon
        do{
            try self.context.save()
        }catch{
            print(error)
            delegate?.didFailWithError(error: error)
        }
    }
    
    func deleteFromCoreData(){
        let context = ( UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do{
            try context.execute(deleteRequest)
            try context.save()
        }
        catch{
            print ("There was an error")
        }
    }
}
