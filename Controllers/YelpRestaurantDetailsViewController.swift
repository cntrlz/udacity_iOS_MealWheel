//
//  YelpRestaurantDetailsViewController.swift
//  MealWheel
//
//  Created by benchmark on 11/19/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import CoreData
import Cosmos
import UIKit
import MapKit

class YelpRestaurantDetailsViewController: UIViewController {
	@IBOutlet var priceCosmosView: CosmosView!
	@IBOutlet var ratingCosmosView: CosmosView!
	@IBOutlet var yelpButton: UIButton!
	@IBOutlet var addressLabel: UILabel!
	@IBOutlet var distanceLabel: UILabel!
	@IBOutlet weak var customLabel: UILabel!
	
	@IBOutlet var myStatisticsView: UIView!
	@IBOutlet var frequencySlider: UISlider!
	@IBOutlet var frequencyLabel: UILabel!
	@IBOutlet var lastAteLabel: UILabel!
	@IBOutlet var clusivityControl: UISegmentedControl!
	
	var b: RestaurantsQuery.Data.Search.Business!
	var nb: RestaurantResult!
	var cachedRestaurant: UserRestaurant!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = nb.name ?? "No Name"
		ratingCosmosView.rating = nb.yelpRating ?? 0.0
		priceCosmosView.rating = Double(nb.priceRating ?? 0)
		
		if nb.type == .Custom {
			customLabel.isHidden = false
		}
		
		let metersInMiles = 1609.344 // TODO: Move this and similar to a constants file
		addressLabel.text = nb.address ?? ""
		let location = (UIApplication.shared.delegate as! AppDelegate).lastLocation
		if nb.latitude != nil && nb.longitude != nil {
			let distance = location.distance(from: CLLocation(latitude: nb.latitude!, longitude: nb.longitude!))
			distanceLabel.text = "\(String(format: "%.2f", distance / metersInMiles)) mi"
		} else {
			distanceLabel.text = ""
		}
		
		if nb.yelpUrl != nil {
			yelpButton.isHidden = false
			yelpButton.addTarget(self, action: #selector(openLink), for: .touchUpInside)
		}
		
		if isCached() {
			myStatisticsView.isHidden = false
			frequencySlider.value = Float(cachedRestaurant.visits < 10 ? Float(cachedRestaurant.visits) / 10.0 : 1)
			frequencyLabel.text = "I have eaten here \(cachedRestaurant.visits <= 10 ? String(describing: cachedRestaurant.visits) : "10+") times"
			clusivityControl.selectedSegmentIndex = Int(cachedRestaurant.clusivity) + 1
			
			if let date = cachedRestaurant.lastVisited {
				let dateFormatter = DateFormatter()
				dateFormatter.dateStyle = .medium
				dateFormatter.timeStyle = .none
				dateFormatter.locale = Locale(identifier: "en_US")
				lastAteLabel.text = "Last Visited: \(dateFormatter.string(from: date))"
			} else {
				lastAteLabel.text = "Last Visited: Unknown"
			}
		}
	}
	
	@IBAction func goToPlace(_ sender: Any) {
		if nb.address != nil {
			let url = "http://maps.apple.com/maps?daddr=\(nb.address!.replacingOccurrences(of: " ", with: "+"))"
			UIApplication.shared.open(URL(string: url)!, options: [:]) { (success) in
				print("Success I guess")
			}
		} else if nb?.longitude != 0, nb?.latitude != 0 {
			let url = "http://maps.apple.com/maps?daddr=\(nb!.latitude!),\(nb!.longitude!)"
			UIApplication.shared.open(URL(string: url)!, options: [:]) { (success) in
				if success { print("YelpRestaurantDetails: Successfully opened link") } else {
					print("YelpRestaurantDetails: Error opening link")
				}
			}
		} else {
			print("YelpRestaurantDetails: Invalid Coordinates sent to \(#function)")
		}
	}
	
	@objc func openLink() {
		if let url = URL(string: nb.yelpUrl!) {
			UIApplication.shared.open(url)
		}
	}
	
	func isCached() -> Bool {
		if let id = nb.yelpId {
			let appDelegate = UIApplication.shared.delegate as! AppDelegate
			let dataController = appDelegate.dataController
			
			let urRequest: NSFetchRequest<UserRestaurant> = UserRestaurant.fetchRequest()
			let predicate = NSPredicate(format: "yelpId == %@", id)
			urRequest.predicate = predicate
			urRequest.fetchLimit = 1
			do {
				let result = try dataController.viewContext.fetch(urRequest)
				if let r = result.first {
					cachedRestaurant = r
					return true
				} else {
					return false
				}
			} catch let error as NSError {
				print("YelpRestaurantDetailsViewController - There was an error with the yelpId fetch: \(error)")
				return false
			}
		}
		return false
	}
}
