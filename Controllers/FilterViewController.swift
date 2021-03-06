//
//  SecondViewController.swift
//  MealWheel
//
//  Created by benchmark on 8/30/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import UIKit

// TODO: The frequency slider should be more intuitive. Making it maxed out to
// filter "any frequency" is counterintuitive.
class FilterViewController: UIViewController {
	@IBOutlet var frequencyLabel: UILabel!
	@IBOutlet var distanceLabel: UILabel!
	@IBOutlet var distanceSlider: UISlider!
	@IBOutlet var frequencySlider: UISlider!
	@IBOutlet weak var resultTypeControl: UISegmentedControl!
	@IBOutlet var distanceDisclosure: UIButton!
	@IBOutlet var frequencyDisclosure: UIButton!
	@IBOutlet var cuisineTypesDisclosure: UIButton!
	
	var shouldShowTips: Bool = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		distanceSlider.value = UserDefaults.standard.float(forKey: "filterDistance")
		frequencySlider.value = UserDefaults.standard.float(forKey: "filterFrequency")
		
		updateDistanceLabelText()
		updateFrequencyLabelText()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		shouldShowTips = UserDefaults.standard.bool(forKey: "showTips")
		distanceDisclosure.isHidden = !shouldShowTips
		frequencyDisclosure.isHidden = !shouldShowTips
		cuisineTypesDisclosure.isHidden = !shouldShowTips
	}
	
	// MARK: UI Events
	@IBAction func distanceChanged(_ sender: UISlider) {
		updateDistanceLabelText()
		UserDefaults.standard.set(distanceSlider.value, forKey: "filterDistance")
	}
	
	@IBAction func frequencyChanged(_ sender: UISlider) {
		updateFrequencyLabelText()
		UserDefaults.standard.set(frequencySlider.value, forKey: "filterFrequency")
	}
	
	func updateDistanceLabelText() {
		let max = UserDefaults.standard.float(forKey: "maxDistance")
		let distance = distanceSlider.value * max
		let text: String!
		if distanceSlider.value < 0.05 {
			text = "Within 1 mi"
		} else if distanceSlider.value > 0.95 { // Perhaps not necessary. Yelp API doesn't do anything past 25mi anyway
			text = "Within 25 mi"
		} else {
			text = "Within \(Int(round(distance))) mi"
		}
		distanceLabel.text = text
	}
	
	func updateFrequencyLabelText() {
		let max = UserDefaults.standard.float(forKey: "maxFrequency")
		let frequency = frequencySlider.value * max
		let text: String!
		if frequencySlider.value < 0.05 {
			text = "New places only"
		} else if frequencySlider.value > 0.95 {
			text = "Any number of visits"
		} else if Int(round(frequency)) == 1 {
			text = "Visited at least once"
		} else {
			text = "Visited at least \(Int(round(frequency))) times"
		}
		frequencyLabel.text = text
	}
	
	// MARK: Disclosures
	@IBAction func showDistanceDisclosure(_ sender: Any) {
		let alert = UIAlertController(title: "Distance", message: "Drag the slider to filter out any restaurants that are too far", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	@IBAction func showFrequencyDisclosure(_ sender: Any) {
		let alert = UIAlertController(title: "Frequency", message: "Adjust the slider to filter places based on how often you've been there", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
		present(alert, animated: true, completion: nil)
	}

	@IBAction func showFiltersDisclosure(_ sender: Any) {
		let alert = UIAlertController(title: "Custom Filters", message: "Use the filters below to have more control over the things that go into your MealWheel!", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	// MARK: Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showList" {
			let listTvc = segue.destination as! ListTableViewController
			listTvc.listType = sender as? String ?? "Error"
		}
	}
}
