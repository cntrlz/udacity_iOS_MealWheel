//
//  FirstViewController.swift
//  MealWheel
//
//  Created by benchmark on 8/30/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import UIKit
import SpinWheelControl

class WheelViewController: UIViewController {

	// See https://github.com/joshdhenry/SpinWheelControl
	@IBOutlet weak var spinWheelControl: SpinWheelControl!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Set up our spinning wheel
		spinWheelControl.dataSource = self
		spinWheelControl.delegate = self
		spinWheelControl.reloadData()
		spinWheelControl.addTarget(self, action: #selector(spinWheelDidChangeValue), for: UIControlEvents.valueChanged)
		
		UserDefaults.standard.set(true, forKey: "firstRun")
	}
	
	override func viewDidAppear(_ animated: Bool) {
//		spinWheelControl.spin(velocityMultiplier: 0.5)
//		spinWheelControl.randomSpin()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@objc func spinWheelDidChangeValue(sender: AnyObject) {
//		print("Value changed to " + String(self.spinWheelControl.selectedIndex))
	}
}

extension WheelViewController: SpinWheelControlDataSource {
	func numberOfWedgesInSpinWheel(spinWheel: SpinWheelControl) -> UInt {
		return 6
	}
	
	func wedgeForSliceAtIndex(index: UInt) -> SpinWheelWedge {
		let wedge = SpinWheelWedge()
		let label = SpinWheelWedgeLabel()
		label.textColor = UIColor.white
		label.shadowColor = UIColor.orange
		wedge.label = label
		wedge.shape.fillColor = UIColor.red.cgColor
		wedge.label.text = "Hey fucker \(index)"
		return wedge
	}
}

extension WheelViewController: SpinWheelControlDelegate {
	//Triggered at various intervals. The variable radians describes how many radians the spin wheel control has moved since the last time this method was called.
	func spinWheelDidRotateByRadians(radians: Radians) {
		print("The wheel did rotate this many radians - " + String(describing: radians))
	}
	
	//Triggered when the spin wheel control has come to rest after spinning.
	func spinWheelDidEndDecelerating(spinWheel: SpinWheelControl) {
		print("The spin wheel did end decelerating.")
	}
}
