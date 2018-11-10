//
//  FirstViewController.swift
//  MealWheel
//
//  Created by benchmark on 8/30/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import UIKit
import SpinWheelControl

class CuisineTypesTableViewController: UITableViewController {

	@IBOutlet weak var switchCuisine: UISwitch!
	@IBOutlet weak var switchBlacklist: UISwitch!
	@IBOutlet weak var switchWhitelist: UISwitch!
	@IBOutlet weak var switchCustomTypes: UISwitch!
	
	@IBOutlet weak var labelCuisine: UILabel!
	@IBOutlet weak var labelBlacklist: UILabel!
	@IBOutlet weak var labelWhitelist: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		// Check value of filters and update labels
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	@IBAction func showCuisine(_ sender: Any) {
	}
	@IBAction func showBlacklist(_ sender: Any) {
	}
	@IBAction func showWhitelist(_ sender: Any) {
	}
	@IBAction func showCustomTypes(_ sender: Any) {
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
		print("Blacklist is now \(isOn ? "on" : "off")")
		labelBlacklist.text = isOn ? "Excluding \(4) types" : "Filter off"
	}
	@IBAction func whitelistSwitchValueChanged(_ sender: Any) {
		let isOn = switchWhitelist.isOn
		print("Whitelist is now \(isOn ? "on" : "off")")
		labelWhitelist.text = isOn ? "Including \(1) type" : "Filter off"
	}
	@IBAction func cuisineSwitchValueChanged(_ sender: Any) {
		let isOn = switchCuisine.isOn
		print("Filtering by cuisine is now \(isOn ? "on" : "off")")
		labelCuisine.text = isOn ? "Filtering \(3) types" : "Filter off"
	}
	
	// DELEGATE
	
	// DATASOURCE
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return UITableViewCell()
	}
}
