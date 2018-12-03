//
//  OptionsViewController.swift
//  MealWheel
//
//  Created by benchmark on 11/26/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import UIKit


// TODO: Fix constraint conflicts to make it look nice on any screen size!
class OptionsViewController: UIViewController {
	var results: [RestaurantsQuery.Data.Search.Business?] = []
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var addButton: UIButton!
	@IBOutlet weak var listButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()

		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "skip", style: .plain, target: self, action: #selector(skip))
    }
	
	func searchStarted() {
		activityIndicator.startAnimating()
		addButton.isEnabled = false
		listButton.isEnabled = false
	}
	
	func searchEnded() {
		activityIndicator.stopAnimating()
		addButton.isEnabled = true
		listButton.isEnabled = true
	}
	
	@IBAction func listOptionSelected(_ sender: Any) {
		if !((UIApplication.shared.delegate as? AppDelegate)?.locationEnabled() ?? false) {
			let alert = UIAlertController(title: "Location Permissions", message: "In order to use location-dependent features in this app, you must grant MealWheel access to your location. You can still access previously saved places.", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {_ in
				(UIApplication.shared.delegate as? AppDelegate)?.locationManager.requestWhenInUseAuthorization()
			}))
			alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: {_ in
				self.performSegue(withIdentifier: "optionsToList", sender: self)
			}))
			self.present(alert, animated: true)
			return
		}
		searchStarted()
		(UIApplication.shared.delegate as! AppDelegate).apiClient.returnDefaultFetch(completion: { results, error in
			self.searchEnded()
			if error != nil {
				let alert = UIAlertController(title: "Error", message: "There was an error fetching a list of nearby restaurants: \(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "Continue Anyway", style: UIAlertActionStyle.default, handler: {_ in
					self.performSegue(withIdentifier: "optionsToList", sender: self)
				}))
				alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
				self.present(alert, animated: true)
			}
			if let results = results {
				if results.count == 0 {
					let alert = UIAlertController(title: "No Results", message: "There are no nearby restaurants matching the filters you have set", preferredStyle: UIAlertControllerStyle.alert)
					alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
					alert.addAction(UIAlertAction(title: "Continue Anyway", style: UIAlertActionStyle.default, handler: {_ in
						self.performSegue(withIdentifier: "optionsToList", sender: self)
					}))
					self.present(alert, animated: true)
				} else {
					self.results = results
					self.performSegue(withIdentifier: "optionsToList", sender: self)
				}
			}
		})
	}
	
	// MARK: Segues
	
	@objc func skip(){
		present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBarController"), animated: true, completion: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "optionsToList" {
			if let vc = segue.destination as? QuickRestaurantListViewController {
				vc.newResults = self.results
			}
		}
	}
	
}
