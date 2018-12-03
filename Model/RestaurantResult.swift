//
//  RestaurantResult.swift
//  MealWheel
//
//  Created by benchmark on 11/30/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import Foundation
import CoreData

// Used for ease of parsing data
class RestaurantResult {
	var name: String?
	var id: NSManagedObjectID?
	var yelpId: String?
	var yelpRating: Double?
	var yelpUrl: String?
	var userRating: Double?
	var priceRating: Int?
	var address: String?
	var latitude: Double?
	var longitude: Double?
	var dateCreated: Date?
	var clusivity: Int?
	var category: String?
	var visits: Int?
	var lastVisited: Date?
	var type: ResultType?
}

enum ResultType {
	case Yelp
	case CoreData
	case Custom
}
