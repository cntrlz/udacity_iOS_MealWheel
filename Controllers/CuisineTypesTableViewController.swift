//
//  FirstViewController.swift
//  MealWheel
//
//  Created by benchmark on 8/30/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import SpinWheelControl
import UIKit

class CuisineTypesTableViewController: UITableViewController {
	@IBOutlet var switchCuisine: UISwitch!
	@IBOutlet var switchBlacklist: UISwitch!
	@IBOutlet var switchWhitelist: UISwitch!
	@IBOutlet var switchCustomTypes: UISwitch!
	
	@IBOutlet var labelCuisine: UILabel!
	@IBOutlet var labelBlacklist: UILabel!
	@IBOutlet var labelWhitelist: UILabel!
	
	@IBOutlet weak var cuisineDisclosure: UIButton!
	@IBOutlet weak var blacklistDisclosure: UIButton!
	@IBOutlet weak var whitelistDisclosure: UIButton!
	@IBOutlet weak var customTypesDisclosure: UIButton!
	
	var shouldShowTips: Bool = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		// Check value of filters and update labels
		shouldShowTips = UserDefaults.standard.bool(forKey: "showTips")
		cuisineDisclosure.isHidden = !shouldShowTips
		blacklistDisclosure.isHidden = !shouldShowTips
		whitelistDisclosure.isHidden = !shouldShowTips
		customTypesDisclosure.isHidden = !shouldShowTips
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	// TODO: Rename to Categories
	@IBAction func showCuisine(_ sender: Any) {
//		let alert = UIAlertController(title: "Harro", message: "Birru", preferredStyle: .alert)
//		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//		present(alert, animated: true, completion: nil)
		parent?.performSegue(withIdentifier: "showCategories", sender: "Cuisine Categories") // TODO: sender doesn't need to be anything here
	}
	
	@IBAction func showBlacklist(_ sender: Any) {
//		let alert = UIAlertController(title: "Harro", message: "Birru", preferredStyle: .alert)
//		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//		present(alert, animated: true, completion: nil)
		parent?.performSegue(withIdentifier: "showList", sender: "Blacklist")
	}
	
	@IBAction func showWhitelist(_ sender: Any) {
//		let alert = UIAlertController(title: "Harro", message: "Birru", preferredStyle: .alert)
//		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//		present(alert, animated: true, completion: nil)
		parent?.performSegue(withIdentifier: "showList", sender: "Whitelist")
	}
	
	// TODO: Axe this
	@IBAction func showCustomTypes(_ sender: Any) {
//		let alert = UIAlertController(title: "Harro", message: "Birru", preferredStyle: .alert)
//		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//		present(alert, animated: true, completion: nil)
		parent?.performSegue(withIdentifier: "showList", sender: "Custom Types")
	}
	
	// DISCLOSURES
	@IBAction func showCuisineDisclosure(_ sender: Any) {
		let alert = UIAlertController(title: "Cuisine", message: "Press \"Cuisine\" to define which cuisine types to include. Cuisine includes types such as \"Mexican\", \"Thai\", and \"Fast Food.\" You may also toggle filtering by cuisine on and off.", preferredStyle: .alert)
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
	
	// SWITCHES
	@IBAction func blacklistSwitchValueChanged(_ sender: Any) {
		let isOn = switchBlacklist.isOn
		UserDefaults.standard.set(isOn, forKey: "blacklistEnabled")
		print("Blacklist is now \(isOn ? "on" : "off")")
		labelBlacklist.text = isOn ? "Excluding \(4) types" : "Filter off"
	}
	
	@IBAction func whitelistSwitchValueChanged(_ sender: Any) {
		let isOn = switchWhitelist.isOn
		UserDefaults.standard.set(isOn, forKey: "whitelistEnabled")
		print("Whitelist is now \(isOn ? "on" : "off")")
		labelWhitelist.text = isOn ? "Including \(1) type" : "Filter off"
	}
	
	@IBAction func cuisineSwitchValueChanged(_ sender: Any) {
		let isOn = switchCuisine.isOn
		UserDefaults.standard.set(isOn, forKey: "cuisineEnabled")
		print("Filtering by cuisine is now \(isOn ? "on" : "off")")
		labelCuisine.text = isOn ? "Filtering \(3) types" : "Filter off"
	}
	@IBAction func customTypesSwitchValueChanged(_ sender: Any) {
		let isOn = switchCustomTypes.isOn
		UserDefaults.standard.set(isOn, forKey: "customTypesEnabled")
		print("Filtering by custom types is now \(isOn ? "on" : "off")")
		// TODO: Add label for custom types
	}
	
	// DELEGATE
	
	// DATASOURCE
//	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		return 1
//	}
//
//	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//		return UITableViewCell()
//	}
}
