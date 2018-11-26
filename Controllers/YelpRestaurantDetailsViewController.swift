//
//  YelpRestaurantDetailsViewController.swift
//  MealWheel
//
//  Created by benchmark on 11/19/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import UIKit

class YelpRestaurantDetailsViewController: UIViewController {
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var yelpRatingLabel: UILabel!
	@IBOutlet weak var priceLabel: UILabel!
	@IBOutlet weak var distanceLabel: UILabel!
	
	var b: RestaurantsQuery.Data.Search.Business!

    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = b.fragments.businessDetails.name
		yelpRatingLabel.text = "\(String(format: "%.1f", b.fragments.businessDetails.rating ?? 0.0))"
		priceLabel.text = b.fragments.businessDetails.price
		
		let metersInMiles = 1609.344 // move to constants
		distanceLabel.text = "\(b.fragments.businessDetails.distance! / metersInMiles) mi"
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
