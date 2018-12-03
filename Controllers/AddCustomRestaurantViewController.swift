//
//  AddCustomRestaurantViewController.swift
//  MealWheel
//
//  Created by benchmark on 11/19/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import CoreLocation
import Cosmos
import UIKit
import MapKit

class AddCustomRestaurantViewController: UIViewController {
	@IBOutlet var nameField: UITextField!
	@IBOutlet var locationField: UITextField!
	@IBOutlet var clusivityControl: UISegmentedControl!
	@IBOutlet var ratingView: CosmosView!
	@IBOutlet var priceView: CosmosView!
	@IBOutlet var frequencyLabel: UILabel!
	@IBOutlet var frequencySlider: UISlider!
	
	@IBOutlet weak var frequencyDisclosure: UIButton!
	@IBOutlet weak var locationDisclosure: UIButton!
	@IBOutlet weak var priceDisclosure: UIButton!
	@IBOutlet weak var ratingDisclosure: UIButton!
	@IBOutlet weak var clusivityDisclosure: UIButton!
	
	var dataController: DataController = (UIApplication.shared.delegate as! AppDelegate).dataController
	var hasChanges: Bool = false
	var shouldShowTips: Bool = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		nameField.delegate = self
		locationField.delegate = self
		
		updateFrequencyLabelText()
		
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		view.addGestureRecognizer(tap)
		
		// Clever Girl. Intercepts Back button action by placing a clear
		// button on top of the Back item
		// from https://stackoverflow.com/a/43932624/8346298
		let imageView = UIImageView()
		imageView.backgroundColor = UIColor.clear
		imageView.frame = CGRect(x: 0, y: 0, width: 2.5 * (navigationController?.navigationBar.bounds.height)!, height: (navigationController?.navigationBar.bounds.height)!)
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(back(sender:)))
		imageView.isUserInteractionEnabled = true
		imageView.addGestureRecognizer(tapGestureRecognizer)
		imageView.tag = 1
		navigationController?.navigationBar.addSubview(imageView)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		for view in (navigationController?.navigationBar.subviews)! {
			if view.tag == 1 {
				view.removeFromSuperview()
			}
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		shouldShowTips = UserDefaults.standard.bool(forKey: "showTips")
		frequencyDisclosure.isHidden = !shouldShowTips
		locationDisclosure.isHidden = !shouldShowTips
		priceDisclosure.isHidden = !shouldShowTips
		ratingDisclosure.isHidden = !shouldShowTips
		clusivityDisclosure.isHidden = !shouldShowTips
	}
	
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
	
	func fieldsAreOkay() -> Bool {
		if nameField.text == "" || locationField.text == "" { return false }
		return true
	}
	
	func updateFrequencyLabelText() {
		let max = UserDefaults.standard.float(forKey: "maxFrequency")
		let frequency = frequencySlider.value * max
		let text: String!
		if frequencySlider.value < 0.05 {
			text = "Never been here"
		} else if frequencySlider.value > 0.95 {
			text = "\(Int(round(max)))+ visits"
		} else if Int(round(frequency)) == 1 {
			text = "Visited once"
		} else {
			text = "Visited \(Int(round(frequency))) times"
		}
		frequencyLabel.text = text
	}
	
	@IBAction func frequencySliderValueChanged(_ sender: Any) {
		updateFrequencyLabelText()
	}
	
	@IBAction func showPriceInfo(_ sender: Any) {
		let alert = UIAlertController(title: "Price Range", message: "Guidelines: 1 dollar sign: $10 and under, 2: $11-30, 3: $31-60, 4: $61+. Per person for a meal including drink, tax, and tip.", preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
		present(alert, animated: true)
	}
	
	@IBAction func showRatingInfo(_ sender: Any) {
		let alert = UIAlertController(title: "Rating", message: "Use your rating to keep track of how great this place is! Also used as a search filter.", preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
		present(alert, animated: true)
	}
	
	@IBAction func showListInfo(_ sender: Any) {
		let alert = UIAlertController(title: "Inclusion Lists", message: "A blacklisted place will never appear as an option on the Wheel, regardless of other filters. A whitelisted place will always be an option.", preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
		present(alert, animated: true)
	}
	
	@objc func back(sender: AnyObject) {
		if hasChanges {
			if !fieldsAreOkay() {
				let alert = UIAlertController(title: "Empty Fields", message: "Some fields are empty. Leave without saving changes?", preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "Keep Editing", style: UIAlertActionStyle.default, handler: nil))
				alert.addAction(UIAlertAction(title: "Discard", style: UIAlertActionStyle.destructive, handler: { _ in
					self.navigationController?.popViewController(animated: true)
				}))
				present(alert, animated: true)
				return
			} else {
				save()
				navigationController?.popViewController(animated: true)
			}
		} else {
			cancel([])
		}
	}
	
	@IBAction func cancel(_ sender: Any) {
		navigationController?.popViewController(animated: true)
	}
	
	@IBAction func findLocation(_ sender: Any) {
		let prefix = "http://maps.apple.com/maps?"
		let formattedAddress: String
		
		if locationField.text != nil && locationField.text != "" {
			formattedAddress = "daddr=\(locationField.text!.replacingOccurrences(of: " ", with: "+"))"
			UIApplication.shared.open(URL(string: prefix+formattedAddress)!, options: [:]) { (success) in
				print("Success I guess")
			}
		} else if nameField.text != nil && nameField.text != "" {
			let formattedString = nameField.text!.replacingOccurrences(of: " ", with: "+")
			let url = "http://maps.apple.com/maps?q=\(formattedString)"
			UIApplication.shared.open(URL(string: url)!, options: [:]) { (success) in
				print("Success I guess")
			}
		} else {
			let alert = UIAlertController(title: "Invalid Location", message: "Please enter a location or add a restaurant name to search", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
			self.present(alert, animated: true)
		}
	}
	
	func save() {
		let r = UserRestaurant(context: dataController.viewContext)
		r.dateCreated = Date()
		
		r.name = nameField.text
		r.visits = Int16(frequencySlider.value * 10)
		r.clusivity = Int16(clusivityControl.selectedSegmentIndex - 1)
		r.rating = ratingView.rating
		r.price = Int16(priceView.rating)
		
		// TODO: we need to geocode this
		let geocoder = CLGeocoder()
		geocoder.geocodeAddressString(locationField.text!) { placemarks, error in
			if error != nil {
				let alert = UIAlertController(title: "Error", message: "We couldn't geocode the location you entered: \(error!.localizedDescription.contains("error 2") ? "The internet connection appears to be offline" : error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
				self.present(alert, animated: true)
			} else {
				let placemark = placemarks?.first
				r.latitude = placemark?.location?.coordinate.latitude ?? 0
				r.longitude = placemark?.location?.coordinate.longitude ?? 0
				print("GEOCODER - Lat: \(r.latitude), Lon: \(r.longitude)")
				try? self.dataController.viewContext.save()
			}
		}
		
		// Implement cats!
		r.category = "ohshit"
		
		// What do with these?
		//			r.lastVisited = Date()
		//			r.yelpId = // don't have one, yeeee
		
		try? dataController.viewContext.save()
	}
	
	func geocodeAddress(_ address: String) -> CLLocation? {
		let geocoder = CLGeocoder()
		var location: CLLocation?
		
		geocoder.geocodeAddressString(locationField.text!) { placemarks, _ in
			let placemark = placemarks?.first
			let lat = placemark?.location?.coordinate.latitude
			let lon = placemark?.location?.coordinate.longitude
			print("Lat: \(String(describing: lat)), Lon: \(String(describing: lon))")
			location = placemark?.location ?? nil
		}
		
		return location
	}
}

extension AddCustomRestaurantViewController: UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if string == "" && (nameField.text == "" || locationField.text == "") {
			hasChanges = false
		} else {
			hasChanges = true
		}
		return true
	}
	
	func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == nameField {
			locationField.becomeFirstResponder()
		} else {
			view.endEditing(true)
		}
		return true
	}
}
