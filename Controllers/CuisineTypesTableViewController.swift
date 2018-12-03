//
//  FirstViewController.swift
//  MealWheel
//
//  Created by benchmark on 8/30/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import CoreData
import SpinWheelControl
import UIKit

class CuisineTypesTableViewController: UITableViewController {
	@IBOutlet var switchCategories: UISwitch!
	@IBOutlet var switchBlacklist: UISwitch!
	@IBOutlet var switchWhitelist: UISwitch!
	@IBOutlet var switchCustomTypes: UISwitch!
	
	@IBOutlet var labelCategories: UILabel!
	@IBOutlet var labelBlacklist: UILabel!
	@IBOutlet var labelWhitelist: UILabel!
	
	@IBOutlet weak var categoriesDisclosure: UIButton!
	@IBOutlet weak var blacklistDisclosure: UIButton!
	@IBOutlet weak var whitelistDisclosure: UIButton!
	@IBOutlet weak var customTypesDisclosure: UIButton!
	
	var shouldShowTips: Bool = true
	var numberOfBlacklistedPlaces = 0
	var numberOfWhitelistedPlaces = 0
	var numberOfCategories = 0
	
	var dataController: DataController = (UIApplication.shared.delegate as! AppDelegate).dataController
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		// Check value of filters and update labels
		shouldShowTips = UserDefaults.standard.bool(forKey: "showTips")
		categoriesDisclosure.isHidden = !shouldShowTips
		blacklistDisclosure.isHidden = !shouldShowTips
		whitelistDisclosure.isHidden = !shouldShowTips
		customTypesDisclosure.isHidden = !shouldShowTips
		
		switchBlacklist.isOn = UserDefaults.standard.bool(forKey: "blacklistEnabled")
		switchWhitelist.isOn = UserDefaults.standard.bool(forKey: "whitelistEnabled")
		switchCategories.isOn = UserDefaults.standard.bool(forKey: "categoriesEnabled")
		
		getFilterNumbers()
		updateCategoryLabelText()
		updateWhitelistLabelText()
		updateBlacklistLabelText()
	}
	
	func getFilterNumbers() {
		numberOfCategories = 0
		numberOfBlacklistedPlaces = 0
		numberOfWhitelistedPlaces = 0
		
		let categoryFetchRequest: NSFetchRequest<UserCategory> = UserCategory.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
		categoryFetchRequest.sortDescriptors = [sortDescriptor]
		let categoryResultsController: NSFetchedResultsController<UserCategory>! = NSFetchedResultsController(fetchRequest: categoryFetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		do {
			try categoryResultsController.performFetch()
			numberOfCategories = categoryResultsController.fetchedObjects?.count ?? 0
		} catch {
			fatalError("MyPlacesViewController - The fetch could not be performed: \(error.localizedDescription)")
		}
		
		let blacklistFetchRequest: NSFetchRequest<UserRestaurant> = UserRestaurant.fetchRequest()
		blacklistFetchRequest.sortDescriptors = [sortDescriptor]
		blacklistFetchRequest.predicate = NSPredicate(format: "clusivity == %d", -1)
		let blacklistResultsController: NSFetchedResultsController<UserRestaurant>! = NSFetchedResultsController(fetchRequest: blacklistFetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		do {
			try blacklistResultsController.performFetch()
			numberOfBlacklistedPlaces = blacklistResultsController.fetchedObjects?.count ?? 0
		} catch {
			fatalError("MyPlacesViewController - The fetch could not be performed: \(error.localizedDescription)")
		}
		
		let whitelistFetchRequest: NSFetchRequest<UserRestaurant> = UserRestaurant.fetchRequest()
		whitelistFetchRequest.sortDescriptors = [sortDescriptor]
		whitelistFetchRequest.predicate = NSPredicate(format: "clusivity == %d", 1)
		let whitelistResultsController: NSFetchedResultsController<UserRestaurant>! = NSFetchedResultsController(fetchRequest: whitelistFetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		do {
			try whitelistResultsController.performFetch()
			numberOfWhitelistedPlaces = whitelistResultsController.fetchedObjects?.count ?? 0
		} catch {
			fatalError("MyPlacesViewController - The fetch could not be performed: \(error.localizedDescription)")
		}
	}
	
	// TODO: Rename to Categories
	@IBAction func showCategories(_ sender: Any) {
		parent?.performSegue(withIdentifier: "showCategories", sender: "Categories") // TODO: sender doesn't need to be anything here
	}
	
	@IBAction func showBlacklist(_ sender: Any) {
		parent?.performSegue(withIdentifier: "showList", sender: "Blacklist")
	}
	
	@IBAction func showWhitelist(_ sender: Any) {
		parent?.performSegue(withIdentifier: "showList", sender: "Whitelist")
	}
	
	// TODO: Axe this
	@IBAction func showCustomTypes(_ sender: Any) {
		parent?.performSegue(withIdentifier: "showList", sender: "Custom Types")
	}
	
	// DISCLOSURES
	@IBAction func showCategoriesDisclosure(_ sender: Any) {
		let alert = UIAlertController(title: "Categories", message: "Press \"Categories\" to define which cuisine types to include. Categories includes types such as \"Mexican\", \"Thai\", and \"Fast Food.\" You may also toggle filtering by cuisine on and off.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	@IBAction func showBlacklistDisclosure(_ sender: Any) {
		let alert = UIAlertController(title: "Blacklist", message: "Press \"Blacklist\" to define which restaurants/places should always be excluded, without regard to other filters. You may also toggle the use of the blacklist on and off. Use this if there is a place that you just never want to see again.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	@IBAction func showWhitelistDisclosure(_ sender: Any) {
		let alert = UIAlertController(title: "Whitelist", message: "Press \"Whitelist\" to define which restaurants/places should always be included, without regard to other filters. You may also toggle the use of the whitelist on and off. Use this if there is a place that should always be \"on the menu.\"", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	@IBAction func showCustomTypesDisclosure(_ sender: Any) {
		let alert = UIAlertController(title: "Custom Types", message: "You can add your own custom cuisine types, which can be used in conjunction with your custom restaurants and places. Filtering by these custom types can be toggled on and off. Note that custom cuisine types will only work with your custom restaurants and places. Having a custom type identical to a default type will have no effect.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	func updateCategoryLabelText() {
		let isOn = switchCategories.isOn
		labelCategories.text = isOn ? numberOfCategories > 0 ? "Filtering \(numberOfCategories) types" : "No categories" : "Filter off"
	}
	
	func updateBlacklistLabelText() {
		let isOn = switchBlacklist.isOn
		labelBlacklist.text = isOn ? numberOfBlacklistedPlaces > 0 ? "Excluding \(numberOfBlacklistedPlaces) places" : "Nothing blacklisted" : "Filter off"
	}
	
	func updateWhitelistLabelText() {
		let isOn = switchWhitelist.isOn
		labelWhitelist.text = isOn ? numberOfWhitelistedPlaces > 0 ? "Including \(numberOfWhitelistedPlaces) places" : "Nothing whitelisted" : "Filter off"
	}
	
	// SWITCHES
	@IBAction func blacklistSwitchValueChanged(_ sender: Any) {
		UserDefaults.standard.set(switchBlacklist.isOn, forKey: "blacklistEnabled")
		updateBlacklistLabelText()
	}
	
	@IBAction func whitelistSwitchValueChanged(_ sender: Any) {
		UserDefaults.standard.set(switchWhitelist.isOn, forKey: "whitelistEnabled")
		updateWhitelistLabelText()
	}
	
	@IBAction func categoriesSwitchValueChanged(_ sender: Any) {
		UserDefaults.standard.set(switchCategories.isOn, forKey: "categoriesEnabled")
		updateCategoryLabelText()
	}
	
	@IBAction func customTypesSwitchValueChanged(_ sender: Any) {
		let isOn = switchCustomTypes.isOn
		UserDefaults.standard.set(isOn, forKey: "customTypesEnabled")
		print("Filtering by custom types is now \(isOn ? "on" : "off")")
		// TODO: Add label for custom types
	}
}
