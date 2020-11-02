//
//  SearchPlacesTests.swift
//  SearchPlacesTests
//
//  Created by Eliric on 10/28/20.
//

import XCTest
@testable import SearchPlaces

class SearchPlacesTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPlaceViewModel(){
        let item = Items(position: [10.232,123.0123], distance: 100, title: "Mightee mart", icon: "www.icon.com", vicinity: "", averageRating: 0)
        let placeViewModel = PlaceViewModel(items: item)
        
        XCTAssertEqual("Mightee mart", placeViewModel.title)
    }
    
    func testEmptyTitle(){
        let item = Items(position: [10.232,123.0123], distance: 100, title: "", icon: "www.icon.com", vicinity: "", averageRating: 0)
        let placeViewModel = PlaceViewModel(items: item)
        XCTAssertEqual("unknown", placeViewModel.title)
    }
    
    func testEmptyIcon(){
        let item = Items(position: [10.232,123.0123], distance: 100, title: "", icon: "", vicinity: "", averageRating: 0)
        let placeViewModel = PlaceViewModel(items: item)
        XCTAssertEqual("https://download.vcdn.cit.data.here.com/p/d/places2_stg/icons/categories/01.icon", placeViewModel.icon)
    }
}
