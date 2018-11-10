//
//  FirstViewController.swift
//  MealWheel
//
//  Created by benchmark on 8/30/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import UIKit
import SpinWheelControl
import YelpAPI
import CoreLocation

class WheelViewController: UIViewController {
	@IBOutlet weak var tableView: UITableView!
	// See https://github.com/joshdhenry/SpinWheelControl
	@IBOutlet weak var spinWheelControl: SpinWheelControl!
	var yelpAPI = YLPClient.init(apiKey: "bKy9HpK1uX0ukd0M76LKDkmzo95_HLLZl4UXHjiT7u9HTe5b__14M3Fc-94e0tc1OJvcRiNdd2Bh4lvbZVsDUOlNs0nVoD3IkEpPqzVNYBAZWEOV_IypslulKXOZW3Yx")
	var results: [YLPBusiness] = []
	let locationManager =  CLLocationManager()
	var lastLocation: CLLocation = CLLocation()
	
	fileprivate func yelpSearchWithTerm(_ term: String!) {
		yelpAPI.search(with: YLPCoordinate(latitude: 34.128137, longitude: -118.217336), term: term, limit: 10, offset: 0, sort: YLPSortType.highestRated) { (search: YLPSearch?, error: Error?) in
			if search != nil {
				print("we have some results: \(search!.businesses)")
				self.results = search!.businesses
				DispatchQueue.main.async {
					self.tableView.reloadData()
					self.spinWheelControl.reloadData()
				}
			}
			if error != nil {
				print("we have some error: \(error!.localizedDescription)")
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Set up spin wheel control
		spinWheelControl.dataSource = self
		spinWheelControl.delegate = self
		spinWheelControl.reloadData()
		spinWheelControl.addTarget(self, action: #selector(spinWheelDidChangeValue), for: UIControlEvents.valueChanged)
		
		// Set up table view
		tableView.delegate = self
		tableView.dataSource = self
		
		setUpLocationManager()
		
		UserDefaults.standard.set(true, forKey: "firstRun")
		
		yelpSearchWithTerm("mexican");
	}
	
	// MARK: - Location
	func setUpLocationManager() {
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
	}
	
	func updateLocation(_ location: CLLocation) {
		print("updated location")
		lastLocation = location
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
		print("Value changed to " + String(self.spinWheelControl.selectedIndex))
	}
	
	@IBAction func refresh(_ sender: Any) {
		yelpSearchWithTerm("italian");
	}
	
}

extension WheelViewController: SpinWheelControlDataSource {
	func numberOfWedgesInSpinWheel(spinWheel: SpinWheelControl) -> UInt {
		return UInt(self.results.count)
	}
	
	func wedgeForSliceAtIndex(index: UInt) -> SpinWheelWedge {
		let wedge = SpinWheelWedge()
		let label = SpinWheelWedgeLabel()
		label.textColor = UIColor.white
		label.shadowColor = UIColor.orange
		wedge.label = label
		wedge.shape.fillColor = UIColor.red.cgColor
		wedge.label.text = "\(index)" + self.results[Int(index)].name
		return wedge
	}
}

extension WheelViewController: SpinWheelControlDelegate {
	//Triggered at various intervals. The variable radians describes how many radians the spin wheel control has moved since the last time this method was called.
	func spinWheelDidRotateByRadians(radians: Radians) {
		print("rotated \(String(describing: radians))")
		spinWheelControl.isUserInteractionEnabled = false
	}
	
	func spinWheelDidUpdateSelectedIndex(radians: Radians, description: String) {
		// print("rotated \(String(describing: radians)) in " + description)
		print(description)
	}
	
	//Triggered when the spin wheel control has come to rest after spinning.
	func spinWheelDidEndDecelerating(spinWheel: SpinWheelControl) {
		print("The spin wheel did end decelerating.")
		spinWheelControl.isUserInteractionEnabled = true
		let wedge = wedgeForSliceAtIndex(index: UInt(spinWheel.selectedIndex))
		wedge.shape.fillColor = UIColor.green.cgColor
		spinWheelControl.reloadInputViews()
	}
}

extension WheelViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.results.count
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		//
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		cell.textLabel!.text = self.results[indexPath.row].name + "\(indexPath.row)"
		return cell
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
}

extension WheelViewController: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		updateLocation(locations.last! as CLLocation)
	}
}
