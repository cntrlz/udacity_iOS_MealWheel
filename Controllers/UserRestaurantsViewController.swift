//
//  UserRestaurantDetailsViewController.swift
//  MealWheel
//
//  Created by benchmark on 11/19/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import CoreLocation
import UIKit

class UserRestaurantDetailsViewController: UIViewController {
	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var frequencyLabel: UILabel!
	@IBOutlet var ratingLabel: UILabel!
	@IBOutlet var lastVisitedLabel: UILabel!
	@IBOutlet var priceLabel: UILabel!
	@IBOutlet var clusivityLabel: UILabel!
	@IBOutlet var distanceLabel: UILabel!

	var r: UserRestaurant?

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		if let r = r {
			nameLabel.text = r.name
			frequencyLabel.text = "I've eaten here \(r.visits) times"
			ratingLabel.text = "Rating: \(r.rating) stars"
			priceLabel.text = "Price: ?"
			clusivityLabel.text = "blacklist/whitelist not impl"
			
			if let date = r.lastVisited {
				let dateFormatter = DateFormatter()
				dateFormatter.dateStyle = .medium
				dateFormatter.timeStyle = .none
				dateFormatter.locale = Locale(identifier: "en_US")
				lastVisitedLabel.text = "Last Visited: \(dateFormatter.string(from: date))"
			}
			
			if(r.longitude != 0 && r.latitude != 0) {
				let location = (UIApplication.shared.delegate as! AppDelegate).lastLocation
				let distance = location.distance(from: CLLocation(latitude: r.latitude, longitude: r.longitude))
				let metersInMiles = 1609.344 // move to constants
				distanceLabel.text = "Distance: \(String(format: "%.2f", distance / metersInMiles)) mi"
			} else {
				distanceLabel.text = "Unknown Distance"
			}
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
