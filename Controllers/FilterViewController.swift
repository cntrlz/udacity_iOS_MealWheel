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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		distanceSlider.value = UserDefaults.standard.float(forKey: "filterDistance")
		frequencySlider.value = UserDefaults.standard.float(forKey: "filterFrequency")
		distanceLabel.text = "\(String(format: "%.2f", distanceSlider.value * UserDefaults.standard.float(forKey: "maxDistance"))) mi"
		frequencyLabel.text = "\(Int(round(frequencySlider.value * UserDefaults.standard.float(forKey: "maxFrequency")))) times"
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func distanceChanged(_ sender: UISlider) {
		distanceLabel.text = "\(String(format: "%.2f", sender.value * UserDefaults.standard.float(forKey: "maxDistance"))) mi"
		UserDefaults.standard.set(sender.value, forKey: "filterDistance")
	}
	
	@IBAction func frequencyChanged(_ sender: UISlider) {
		frequencyLabel.text = "\(Int(round(sender.value * UserDefaults.standard.float(forKey: "maxFrequency")))) times"
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
	
}

