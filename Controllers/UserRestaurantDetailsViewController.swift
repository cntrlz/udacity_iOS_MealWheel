//
//  UserRestaurantDetailsViewController.swift
//  MealWheel
//
//  Created by benchmark on 11/19/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import CoreData
import CoreLocation
import Cosmos
import UIKit

class UserRestaurantDetailsViewController: UIViewController {
	@IBOutlet var frequencyLabel: UILabel!
	@IBOutlet var frequencySlider: UISlider!
	@IBOutlet var priceRating: CosmosView!
	@IBOutlet var rating: CosmosView!
	@IBOutlet weak var clusivityControl: UISegmentedControl!
	@IBOutlet var lastVisitedLabel: UILabel!
	@IBOutlet var locationLabel: UILabel!
	@IBOutlet var yelpButton: UIButton!
	
	var r: UserRestaurant?
	var yelpURL: URL?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let url = getURL(yelpId: r?.yelpId) {
			yelpButton.isHidden = false
			yelpURL = url
			yelpButton.addTarget(self, action: #selector(openLink), for: .touchUpInside)
		}
		
		// Do any additional setup after loading the view.
		if let r = r {
			navigationItem.title = r.name ?? "No Name"
			frequencyLabel.text = "I've eaten here \(r.visits) times"
			frequencySlider.value = Float(r.visits) / 10.0 // TODO: Make max visits
			rating.rating = r.rating
			priceRating.rating = Double(r.price)
			clusivityControl.selectedSegmentIndex = Int(r.clusivity) + 1
			
			if let date = r.lastVisited {
				let dateFormatter = DateFormatter()
				dateFormatter.dateStyle = .medium
				dateFormatter.timeStyle = .none
				dateFormatter.locale = Locale(identifier: "en_US")
				lastVisitedLabel.text = "Last Visited: \(dateFormatter.string(from: date))"
			} else {
				lastVisitedLabel.text = "Last Visited: Unknown"
			}
			
			if r.longitude != 0 && r.latitude != 0 {
				let location = (UIApplication.shared.delegate as! AppDelegate).lastLocation
				let distance = location.distance(from: CLLocation(latitude: r.latitude, longitude: r.longitude))
				let metersInMiles = 1609.344 // move to constants
				locationLabel.text = "Distance: \(String(format: "%.2f", distance / metersInMiles)) mi"
			} else {
				locationLabel.text = "Unknown Distance"
				print("Distance couldn't be calculated because lat/long values are \(r.latitude) / \(r.longitude)")
			}
		}
	}
	
	@objc func openLink() {
		if yelpURL != nil {
			UIApplication.shared.open(yelpURL!)
		}
	}
	
	func getURL(yelpId: String?) -> URL? {
		if let id = yelpId {
			let appDelegate = UIApplication.shared.delegate as! AppDelegate
			let dataController = appDelegate.dataController
			
			let yrRequest: NSFetchRequest<YelpRestaurant> = YelpRestaurant.fetchRequest()
			let predicate = NSPredicate(format: "id == %@", id)
			yrRequest.predicate = predicate
			yrRequest.fetchLimit = 1
			do {
				let result = try dataController.viewContext.fetch(yrRequest)
				if let r = result.first {
					if let u = r.url {
						return URL(string: u)
					}
				}
				return nil
			} catch let error as NSError {
				print("UserRestaurantDetailsViewController - There was an error with the yelpId fetch: \(error)")
				return nil
			}
		} else {
			return nil
		}
	}
	
    /*
    // MARK: - Navigation
	
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
