//
//  SettingsTableViewController.swift
//  MealWheel
//
//  Created by benchmark on 11/20/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
	var shouldShowTips: Bool = true

	// Add a list of settings here, following the format. The controller will generate the list of settings as appropriate,
	// mapping actions as needed
	let settings: [[String: [String: Any]]]! = [
		["swipeToggleExpansion": ["defaultValue": false, "text": "Quick Swipe", "description": "Scrolling quickly expands and collapses lists, like on the Wheel page"]],
		["showTips": ["defaultValue": true, "text": "Show Tips", "description": "Show tapable disclosure indicators around the app to show more info"]],
		["landingPage": ["defaultValue": true, "text": "Landing Page on Startup", "description": "Shows a landing page by default when opening the app instead of the Wheel tab"]],
		["distrustfulMode": ["defaultValue": false, "text": "Distrustful Mode", "description": "COMING SOON! Do not add a restaurant to 'My Places' until I have actually gone there (GPS required)"]],
		["autoSave": ["defaultValue": true, "text": "Auto Save", "description": "Automatically save confirmed spin results to My Places"]]
	]

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
		shouldShowTips = UserDefaults.standard.bool(forKey: "showTips")
	}

	@objc func showInfo(sender: UIButton) {
		let setting = settings[sender.tag]
		let userDefaultsKey = setting.keys.first!
		let values = setting[userDefaultsKey]!
		let description = values["description"] as! String

		let alert = UIAlertController(title: "Description", message: description, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
		present(alert, animated: true)
	}

	@objc func switchChanged(sender: UISwitch) {
		let setting = settings[sender.tag]
		let userDefaultsKey = setting.keys.first!

		UserDefaults.standard.set(sender.isOn, forKey: userDefaultsKey)
		print("Setting \(userDefaultsKey) is now \(sender.isOn ? "on" : "off")")

		if userDefaultsKey == "showTips" {
			shouldShowTips = UserDefaults.standard.bool(forKey: "showTips")
			tableView.reloadData()
		}
	}
	
	// MARK: TableView
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return settings.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "settingsViewCell", for: indexPath) as! SettingsTableViewCell
		let setting = settings[indexPath.row]
		let userDefaultsKey = setting.keys.first!
		let values = setting[userDefaultsKey]!

		let labelText = values["text"] as! String
		cell.label.text = labelText
		cell.info.isHidden = !shouldShowTips
		cell.info.tag = indexPath.row
		cell.info.addTarget(self, action: #selector(showInfo), for: .touchUpInside)
		cell.switch.tag = indexPath.row
		cell.switch.isOn = UserDefaults.standard.bool(forKey: userDefaultsKey)
		cell.switch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)

		return cell
	}
}
