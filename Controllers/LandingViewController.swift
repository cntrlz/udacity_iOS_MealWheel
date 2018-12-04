//
//  LandingViewController.swift
//  MealWheel
//
//  Created by benchmark on 11/16/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import UIKit
import CoreLocation

class LandingViewController: UIViewController {
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	@IBOutlet var exploreButton: UIButton!
	@IBOutlet var customizeButton: UIButton!
	@IBOutlet weak var cancelButton: UIButton!
	@IBOutlet weak var infoButton: UIButton!
	var results: [RestaurantsQuery.Data.Search.Business?] = []
	
	
	override func viewDidLoad() {
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "skip", style: .plain, target: self, action: #selector(skip))
		// Remove the separator line on the nav bar to get a smoother appearance
		navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
		navigationController?.navigationBar.shadowImage = UIImage()
		
		infoButton.isHidden = !UserDefaults.standard.bool(forKey: "showTips")
		infoButton.addTarget(self, action: #selector(showInfo), for: .touchUpInside)
	}
	
	@objc func skip(){
		present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBarController"), animated: true, completion: nil)
	}
	
	@IBAction func exploreSearch(_ sender: Any) {
		if !((UIApplication.shared.delegate as? AppDelegate)?.locationEnabled() ?? false) {
			let alert = UIAlertController(title: "Location Permissions", message: "In order to use location-dependent features in this app, you must grant MealWheel access to your location.", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {_ in
				(UIApplication.shared.delegate as? AppDelegate)?.locationManager.requestWhenInUseAuthorization()
			}))
			self.present(alert, animated: true)
			return
		}
		searchBegan()
		(UIApplication.shared.delegate as! AppDelegate).apiClient.returnDefaultFetch(completion: { results, error in
			if error != nil {
				let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
				self.present(alert, animated: true)
				self.searchEnded()
			}
			if results != nil {
				self.results = results!
				self.performSegue(withIdentifier: "landingToTabBar", sender: nil)
				self.searchEnded()
			} else {
				let alert = UIAlertController(title: "Error", message: "Your search sucks", preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "sad face", style: UIAlertActionStyle.default, handler: nil))
				self.present(alert, animated: true)
				self.searchEnded()
			}
		})
	}
	
	@IBAction func cancel(_ sender: Any) {
		// Cancels the search. Should appear when loading is taking longer than 5s or so
		// Not yet implemented (generally long load times will just error out as appropriate)
	}
	
	@objc func showInfo() {
		let alert = UIAlertController(title: "Info", message: "Explore mode chooses a random nearby restaurant from Yelp using your current filters. Customize mode lets you build your own Meal Wheel.", preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "Cool", style: UIAlertActionStyle.default, handler: nil))
		self.present(alert, animated: true)
	}
	
	func searchBegan() {
		activityIndicator.startAnimating()
		exploreButton.isEnabled = false
		exploreButton.isHighlighted = true
		customizeButton.isEnabled = false
		customizeButton.isHighlighted = true
	}
	
	func searchEnded() {
		exploreButton.isEnabled = true
		exploreButton.isHighlighted = false
		customizeButton.isEnabled = true
		customizeButton.isHighlighted = false
		activityIndicator.stopAnimating()
	}

	// MARK: - Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "landingToTabBar" && results.count > 0 {
			if let tabBar = segue.destination as? UITabBarController {
				if let nav = tabBar.customizableViewControllers?.first as? UINavigationController {
					if let wvc = nav.viewControllers.first as? WheelViewController {
						wvc.searchResults = results
						wvc.spinAtLoad = true
					}
				}
			}
		}
	}
}
