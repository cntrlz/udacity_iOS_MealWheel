//
//  QuickRestaurantListViewController.swift
//  MealWheel
//
//  Created by benchmark on 11/27/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import CoreData
import UIKit

class QuickRestaurantListViewController: UIViewController {
	@IBOutlet var tableView: UITableView!
	@IBOutlet var spinButton: UIButton!
	@IBOutlet var segmentedControl: UISegmentedControl!
	
	var newResults: [RestaurantsQuery.Data.Search.Business?] = []
	var dataController: DataController = (UIApplication.shared.delegate as! AppDelegate).dataController
	var fetchedResultsController: NSFetchedResultsController<UserRestaurant>!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "skip", style: .plain, target: self, action: #selector(skip))
		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.backgroundView = nil
		tableView.backgroundColor = UIColor.clear
		tableView.isEditing = true
		
		setupFetchedResultsController()
		
		let preferMine = UserDefaults.standard.bool(forKey: "quickAddListPreferMyPlaces")
		if preferMine {
			if !((UIApplication.shared.delegate as? AppDelegate)?.locationEnabled() ?? false) {
				let alert = UIAlertController(title: "Location Permissions", message: "You will only be able to view saved places until you grant MealWheel access to your location.", preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { _ in
					(UIApplication.shared.delegate as? AppDelegate)?.locationManager.requestWhenInUseAuthorization()
					self.segmentedControl.setEnabled(false, forSegmentAt: 1)
				}))
				present(alert, animated: true)
				return
			}
			
			if fetchedResultsController.fetchedObjects?.count == 0 {
				segmentedControl.selectedSegmentIndex = 0
			} else {
				segmentedControl.selectedSegmentIndex = 1
			}
		} else {
			segmentedControl.selectedSegmentIndex = 1
		}
		
		if newResults.count < 1 {
			segmentedControl.setEnabled(false, forSegmentAt: 1)
			segmentedControl.selectedSegmentIndex = 0
		}
	}
	
	fileprivate func setupFetchedResultsController(_ clusivity: Int? = nil) {
		let fetchRequest: NSFetchRequest<UserRestaurant> = UserRestaurant.fetchRequest()
		
		let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
		fetchRequest.sortDescriptors = [sortDescriptor]
		if UserDefaults.standard.bool(forKey: "blacklistEnabled") {
			fetchRequest.predicate = NSPredicate(format: "clusivity != %d", -1)
		}
		fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		
		do {
			try fetchedResultsController.performFetch()
			if fetchedResultsController.fetchedObjects?.count == 0 {
				segmentedControl.setEnabled(false, forSegmentAt: 0)
			}
		} catch {
			fatalError("QuickRestaurantListViewController - The fetch could not be performed: \(error.localizedDescription)")
		}
	}
	
	@IBAction func spin(_ sender: Any) {
		if tableView.indexPathsForSelectedRows?.count ?? 0 < 2 {
			let alert = UIAlertController(title: "Invalid Selections", message: "Select at least two options from the list above", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
			present(alert, animated: true)
		} else {
			performSegue(withIdentifier: "listToWheel", sender: segmentedControl.selectedSegmentIndex == 0 ? fetchedResultsController.fetchedObjects : newResults)
		}
	}
	
	@objc func skip() {
		present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBarController"), animated: true, completion: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "listToWheel" {
			if tableView.indexPathsForSelectedRows != nil {
				if let tbc = segue.destination as? UITabBarController {
					if let nc = tbc.customizableViewControllers?.first as? UINavigationController {
						if let wvc = nc.viewControllers.first as? WheelViewController {
							if segmentedControl.selectedSegmentIndex == 0 {
								if let paths = tableView.indexPathsForSelectedRows {
									let allResults = fetchedResultsController.fetchedObjects ?? []
									let selectedResults = allResults.filter { (userRestaurant) -> Bool in
										if let ip = fetchedResultsController.indexPath(forObject: userRestaurant) {
											return paths.contains(ip)
										}
										return false
									}
									wvc.spinAtLoad = true
									wvc.myResults = selectedResults
								} else {
									print("whacko")
								}
							} else {
								let paths = tableView.indexPathsForSelectedRows!
								wvc.searchResults = paths.map { newResults[$0.row] }
								wvc.spinAtLoad = true
							}
						}
					}
				}
			}
		}
	}
	
	@IBAction func segmentedControlValueChanged(_ sender: Any) {
		if segmentedControl.selectedSegmentIndex == 0 {
			UserDefaults.standard.set(true, forKey: "quickAddListPreferMyPlaces")
			setupFetchedResultsController()
		} else {
			UserDefaults.standard.set(false, forKey: "quickAddListPreferMyPlaces")
		}
		
		tableView.reloadData()
	}
}

extension QuickRestaurantListViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if segmentedControl.selectedSegmentIndex == 0 {
			return fetchedResultsController.fetchedObjects?.count ?? 0
		} else {
			return newResults.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		cell.backgroundColor = UIColor.clear
		cell.textLabel?.textColor = UIColor.white
		let bgColorView = UIView()
		bgColorView.backgroundColor = UIColor.orange
		cell.selectedBackgroundView = bgColorView
		
		if segmentedControl.selectedSegmentIndex == 0 {
			let r = fetchedResultsController.object(at: indexPath) as UserRestaurant
			cell.textLabel?.text = r.name
		} else {
			if let business = newResults[indexPath.row] {
				cell.textLabel!.text = business.fragments.businessDetails.name
			} else {
				cell.textLabel!.text = "No Name"
			}
		}
		return cell
	}
}
