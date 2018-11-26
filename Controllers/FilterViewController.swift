//
//  SecondViewController.swift
//  MealWheel
//
//  Created by benchmark on 8/30/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {
	@IBOutlet weak var frequencyLabel: UILabel!
	@IBOutlet weak var distanceLabel: UILabel!
	@IBOutlet weak var distanceSlider: UISlider!
	@IBOutlet weak var frequencySlider: UISlider!
	
	@IBOutlet weak var distanceDisclosure: UIButton!
	@IBOutlet weak var frequencyDisclosure: UIButton!
	@IBOutlet weak var cuisineTypesDisclosure: UIButton!
	
	var shouldShowTips: Bool = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		distanceSlider.value = UserDefaults.standard.float(forKey: "filterDistance")
		frequencySlider.value = UserDefaults.standard.float(forKey: "filterFrequency")
		
		let maxDist = UserDefaults.standard.float(forKey: "maxDistance")
		let distance = distanceSlider.value * maxDist
		distanceLabel.text = "Within \(Int(round(distance))) mi"
		
		let maxFreq = UserDefaults.standard.float(forKey: "maxFrequency")
		let frequency = frequencySlider.value * maxFreq
		frequencyLabel.text = "\(Int(round(frequency))) times"
	}
	
	override func viewWillAppear(_ animated: Bool) {
		shouldShowTips = UserDefaults.standard.bool(forKey: "showTips")
		distanceDisclosure.isHidden = !shouldShowTips
		frequencyDisclosure.isHidden = !shouldShowTips
		cuisineTypesDisclosure.isHidden = !shouldShowTips
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func distanceChanged(_ sender: UISlider) {
		let max = UserDefaults.standard.float(forKey: "maxDistance")
		let distance = sender.value * max
		let text : String!
		if sender.value < 0.05 {
			text = "Within 1 mi"
		} else if sender.value > 0.95 { // Perhaps not necessary. Yelp API doesn't do anything past 25mi anyway
			text = "Within 25 mi"
		} else {
			text = "Within \(Int(round(distance))) mi"
		}
		distanceLabel.text = text
		UserDefaults.standard.set(sender.value, forKey: "filterDistance")
		
		
		
//		distanceLabel.text = "\(String(format: "%.1f", floorf(sender.value * UserDefaults.standard.float(forKey: "maxDistance")))) mi"
//		UserDefaults.standard.set(sender.value, forKey: "filterDistance")
	}
	
	@IBAction func frequencyChanged(_ sender: UISlider) {
		let max = UserDefaults.standard.float(forKey: "maxFrequency")
		let frequency = sender.value * max
		let text : String!
		if sender.value < 0.05 {
			text = "Fresh!"
		} else if sender.value > 0.95 {
			text = "\(Int(round(max)))+ times"
		} else {
			text = "\(Int(round(frequency))) times"
		}
		frequencyLabel.text = text
		UserDefaults.standard.set(sender.value, forKey: "filterFrequency")
	}
	
	@IBAction func showDistanceDisclosure(_ sender: Any) {
		let alert = UIAlertController(title: "Distance", message: "Drag the slider to filter out any restaurants that are too far. You can make more adjustments in Settings.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	@IBAction func showFrequencyDisclosure(_ sender: Any) {
		let alert = UIAlertController(title: "Frequency", message: "Adjust the slider to filter places based on how often you've eaten there. A setting closer to \"familiar\" will prefer places that you've eaten at, and a setting all the way at \"new\" will show only places you've never eaten at before! You can make more adjustments in Settings.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showList" {
			let listTvc = segue.destination as! ListTableViewController
			listTvc.listType = sender as? String ?? "Error"
		}
	}
	
}

