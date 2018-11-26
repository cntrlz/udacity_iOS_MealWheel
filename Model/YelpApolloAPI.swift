//
//  YelpApolloAPI.swift
//  MealWheel
//
//  Created by benchmark on 11/16/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import Apollo
import Foundation
import UIKit

class YelpAPI {
	let accessToken: String = "bKy9HpK1uX0ukd0M76LKDkmzo95_HLLZl4UXHjiT7u9HTe5b__14M3Fc-94e0tc1OJvcRiNdd2Bh4lvbZVsDUOlNs0nVoD3IkEpPqzVNYBAZWEOV_IypslulKXOZW3Yx"
	let contentType: String = "application/graphql"
	let language: String = "en_US"

	let apollo: ApolloClient = {
		let configuration = URLSessionConfiguration.default
		configuration.httpAdditionalHeaders = ["Authorization": "Bearer \(accessToken)", "Content-Type": contentType, "Accept-Language": language]
		let url = URL(string: "https://api.yelp.com/v3/graphql")!
		return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
	}()

	func performDefaultFetch() {
		apollo.fetch(query: RestaurantsQuery(limit: 25, long: lastLocation.coordinate.longitude, lat: lastLocation.coordinate.latitude, cat: "restaurants", radius: 200), cachePolicy: .returnCacheDataElseFetch) { result, error in
			print("Query complete")
			if let error = error {
				print("Error with RestaurantsQuery: \(error.localizedDescription)")
				return
			}

			self.results = result?.data?.search?.business ?? []
			self.cacheResults()
		}
	}

	func cacheResults() {
		for b in results {
			if let newId = b?.fragments.businessDetails.id {
				let fetch: NSFetchRequest<YelpRestaurant> = YelpRestaurant.fetchRequest()
				fetch.predicate = NSPredicate(format: "id == %@", newId)
				//				fetch.fetchLimit = 1
				fetch.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
				let r: YelpRestaurant
				do {
					let result = try dataController.viewContext.fetch(fetch)
					if result.count > 0 {
						print("\(#function) We already have a stored YelpRestaurant with ID: ", result.first?.id, " updating if needed.")
						r = dataController.viewContext.object(with: result.first!.objectID) as! YelpRestaurant
					} else {
						print("\(#function) Adding new YelpRestaurant")
						r = YelpRestaurant(context: dataController.viewContext)
					}

				} catch {
					fatalError("YelpAPI - The fetch for existing ID in \(#function) could not be performed: \(error.localizedDescription)")
				}

				let name = b?.fragments.businessDetails.name
				let displayPhone = b?.fragments.businessDetails.displayPhone
				let id = b?.fragments.businessDetails.id
				let price = b?.fragments.businessDetails.price
				let url = b?.fragments.businessDetails.url
				let reviewCount = Int16(b?.fragments.businessDetails.reviewCount ?? 0)
				let yelpRating = b?.fragments.businessDetails.rating ?? 0

				if r.dateFetched == nil {
					r.dateFetched = Date()
				}
				if let categories = b?.fragments.businessDetails.categories {
					let cat = categories.first??.alias
					if r.category == nil || r.category != cat {
						r.category = cat
					}
				}
				if let latitude = b?.fragments.businessDetails.coordinates?.latitude {
					if r.latitude != latitude {
						r.latitude = latitude
					}
				}
				if let longitude = b?.fragments.businessDetails.coordinates?.longitude {
					if r.longitude != longitude {
						r.longitude = longitude
					}
				}
				if r.name == nil || r.name != name {
					r.name = name ?? ""
				}
				if r.displayPhone == nil || r.displayPhone != displayPhone {
					r.displayPhone = displayPhone ?? ""
				}
				if r.id == nil || r.id != id {
					r.id = id ?? ""
				}
				if r.price == nil || r.price != price {
					r.price = price ?? ""
				}
				if r.url == nil || r.url != url {
					r.url = url ?? ""
				}
				if r.reviewCount != reviewCount {
					r.reviewCount = reviewCount
				}
				if r.yelpRating != yelpRating {
					r.yelpRating = yelpRating
				}

				try? dataController.viewContext.save()
			} else {
				break
			}
		}
	}
}
