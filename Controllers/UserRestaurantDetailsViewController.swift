//
//  UserRestaurantDetailsViewController.swift
//  MealWheel
//
//  Created by benchmark on 11/19/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import CoreData
import CoreLocation
import Cosmos
import UIKit
import MapKit

// TODO: Code replication in AddCustomRestaurantDetailsViewController! Fix this.
// TODO: Geocoding is clunky and not working as smoothly as I'd like
class UserRestaurantDetailsViewController: UIViewController {
	@IBOutlet var frequencyLabel: UILabel!
	@IBOutlet var frequencySlider: UISlider!
	@IBOutlet var priceRating: CosmosView!
	@IBOutlet var rating: CosmosView!
	@IBOutlet var clusivityControl: UISegmentedControl!
	@IBOutlet var lastVisitedLabel: UILabel!
	@IBOutlet var locationLabel: UILabel!
	@IBOutlet var yelpButton: UIButton!
	@IBOutlet var editButton: UIBarButtonItem!
	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var nameField: UITextField!
	@IBOutlet var locationField: UITextField!
	@IBOutlet var locationFieldToLabel: NSLayoutConstraint!
	@IBOutlet var locationInfoButton: UIButton!
	@IBOutlet var withNameLabel: NSLayoutConstraint!
	@IBOutlet var withoutNameLabel: NSLayoutConstraint!
	@IBOutlet var withoutLocationField: NSLayoutConstraint!
	@IBOutlet var withLocationField: NSLayoutConstraint!
	@IBOutlet weak var goButton: UIButton!
	
	var r: UserRestaurant?
	var yelpURL: URL?
	var editPlace: Bool = false
	var isYelp: Bool = false
	var shouldShowTips: Bool = false
	var dataController: DataController = (UIApplication.shared.delegate as! AppDelegate).dataController
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setUpInitialViews()
		
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		view.addGestureRecognizer(tap)
		
		let imageView = UIImageView()
		imageView.backgroundColor = UIColor.clear
		imageView.frame = CGRect(x: 0, y: 0, width: 2.5 * (navigationController?.navigationBar.bounds.height)!, height: (navigationController?.navigationBar.bounds.height)!)
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(back(_ :)))
		imageView.isUserInteractionEnabled = true
		imageView.addGestureRecognizer(tapGestureRecognizer)
		imageView.tag = 1
		navigationController?.navigationBar.addSubview(imageView)
		
		if let url = getURL(yelpId: r?.yelpId) {
			yelpButton.isHidden = false
			yelpURL = url
			yelpButton.addTarget(self, action: #selector(openLink), for: .touchUpInside)
			isYelp = true
		}
		
		// Do any additional setup after loading the view.
		if let r = r {
			navigationItem.title = r.name ?? "No Name"
			frequencySlider.value = Float(r.visits) / 10.0 // TODO: Make max visits
			updateFrequencyLabelText()
			rating.rating = r.rating
			priceRating.rating = Double(r.price)
			clusivityControl.selectedSegmentIndex = Int(r.clusivity) + 1
			
			if let date = r.lastVisited {
				let dateFormatter = DateFormatter()
				dateFormatter.dateStyle = .medium
				dateFormatter.timeStyle = .none
				dateFormatter.locale = Locale(identifier: "en_US")
				lastVisitedLabel.text = "Last Visited: \(dateFormatter.string(from: date))"
			} else {
				lastVisitedLabel.text = "Last Visited: Unknown"
			}
			
			updateLocationLabelName()
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		shouldShowTips = UserDefaults.standard.bool(forKey: "showTips")
		if isYelp && shouldShowTips { locationInfoButton.isHidden = !editPlace }
		
		if r?.longitude == 0, r?.latitude == 0 { goButton.isHidden = true }
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		for view in (navigationController?.navigationBar.subviews)! {
			if view.tag == 1 {
				view.removeFromSuperview()
			}
		}
	}
	
	fileprivate func setUpInitialViews() {
		nameField.isHidden = true
		nameLabel.isHidden = true
		withNameLabel.isActive = false
		withoutNameLabel.isActive = true
		locationField.isHidden = true
	}
	
	// MARK: UI Events
	@IBAction func frequencySliderValueChanged(_ sender: Any) {
		updateFrequencyLabelText()
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
	
	fileprivate func updateLocationLabelName() {
		if let r = r {
			if r.longitude != 0 && r.latitude != 0 {
				let location = (UIApplication.shared.delegate as! AppDelegate).lastLocation
				let distance = location.distance(from: CLLocation(latitude: r.latitude, longitude: r.longitude))
				let metersInMiles = 1609.344 // move to constants
				locationLabel.text = "Distance: \(String(format: "%.2f", distance / metersInMiles)) mi"
			} else {
				locationLabel.text = "Unknown Distance"
				print("Distance couldn't be calculated because lat/long values are \(r.latitude) / \(r.longitude)")
			}
		}
	}
	
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
	
	@IBAction func showLocationInfo(_ sender: Any) {
		let alert = UIAlertController(title: "Location", message: "You cannot change the location of places added from Yelp", preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
		present(alert, animated: true)
	}
	
	// MARK: Navigation
	@objc func back(_ sender: Any) {
		if hasChanges() {
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
	
	// MARK: Geocoding
	fileprivate func geocodeLocation(_ r: UserRestaurant) {
		let geocoder = CLGeocoder()
		geocoder.geocodeAddressString(locationField.text!) { placemarks, error in
			if error != nil {
				let alert = UIAlertController(title: "Error", message: "We couldn't geocode that location: \(error!.localizedDescription.contains("error 2") ? "The internet connection appears to be offline" : error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.alert)
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
	}
	
	// This is an unused implementation
	//	func geocodeAddress(_ address: String) -> CLLocation? {
	//		let geocoder = CLGeocoder()
	//		var location: CLLocation?
	//
	//		geocoder.geocodeAddressString(locationField.text!) { placemarks, _ in
	//			let placemark = placemarks?.first
	//			let lat = placemark?.location?.coordinate.latitude
	//			let lon = placemark?.location?.coordinate.longitude
	//			print("Lat: \(String(describing: lat)), Lon: \(String(describing: lon))")
	//			location = placemark?.location ?? nil
	//		}
	//
	//		return location
	//	}
	
	// MARK: Editing and Saving
	@IBAction func toggleEditPlace(_ sender: Any) {
		if editPlace {
			editButton.title = "Edit"
			navigationItem.title = r?.name ?? "No Name"
			editPlace = false
			back([])
		} else {
			editButton.title = "Done"
			navigationItem.title = r?.name != nil ? "Editing \(r!.name!)" : "Editing"
			editPlace = true
		}
		
		if isYelp && shouldShowTips { locationInfoButton.isHidden = !editPlace }
		if !isYelp { locationField.isHidden = !editPlace }
		frequencySlider.isUserInteractionEnabled = editPlace
		priceRating.isUserInteractionEnabled = editPlace
		rating.isUserInteractionEnabled = editPlace
		clusivityControl.isUserInteractionEnabled = editPlace
		UIView.animate(withDuration: 0.5) {
			self.nameField.isHidden = !self.editPlace
			self.nameLabel.isHidden = !self.editPlace
			self.nameField.placeholder = self.r?.name ?? ""
			self.view.layoutIfNeeded()
		}
		UIView.animate(withDuration: 0.2) {
			self.withNameLabel.isActive = self.editPlace
			self.withoutNameLabel.isActive = !self.editPlace
			if !self.isYelp {
				if self.editPlace {
					self.locationLabel.text = "Location"
				} else {
					self.updateLocationLabelName()
				}
				self.withLocationField.isActive = self.editPlace
				self.withoutLocationField.isActive = !self.editPlace
			}
			self.view.layoutIfNeeded()
		}
	}
	
	// TODO: Figure out some proper validation that's logical but doesn't bog
	// the user down with alerts
	func fieldsAreOkay() -> Bool {
		//		if nameField.text == "" || locationField.text == "" { return false }
		return true
	}
	
	func hasChanges() -> Bool {
		if nameField.text != "" && nameField.text != r?.name { return true }
		if Int16(priceRating.rating) != r?.price { return true }
		if rating.rating != r?.rating { return true }
		if let clusivity = r?.clusivity, clusivityControl.selectedSegmentIndex != clusivity + 1 { return true }
		let visits = UserDefaults.standard.float(forKey: "maxFrequency") * frequencySlider.value
		if Int16(round(visits)) != r?.visits { return true }
		if locationField.text != "" { return true }
		return false
	}
	
	func save() {
		if let r = dataController.viewContext.object(with: self.r!.objectID) as? UserRestaurant {
			r.name = nameField.text != "" ? nameField.text : r.name
			r.visits = Int16(frequencySlider.value * 10)
			r.clusivity = Int16(clusivityControl.selectedSegmentIndex - 1)
			r.rating = rating.rating
			r.price = Int16(priceRating.rating)
			
			// Implement categories!
			r.category = ""
			
			if !isYelp {
				geocodeLocation(r)
			}
		}
		
		// TODO: Figure out how to deal with
		//			r.lastVisited = Date()
		// and
		//			r.yelpId = // Cuz we might not have one, eh?
		
		try? dataController.viewContext.save()
	}
	
	// MARK: Maps Links
	@IBAction func goToPlace(_ sender: Any) {
		if r?.longitude != 0, r?.latitude != 0 {
			let url = "http://maps.apple.com/maps?daddr=\(r!.latitude),\(r!.longitude)"
			UIApplication.shared.open(URL(string: url)!, options: [:]) { (success) in
				print("Success I guess")
			}
		} else {
			print("Invalid Coordinates")
		}
	}
	
	@objc func openLink() {
		if yelpURL != nil {
			UIApplication.shared.open(yelpURL!)
		}
	}
	
	func getURL(yelpId: String?) -> URL? {
		if let id = yelpId {
			let appDelegate = UIApplication.shared.delegate as! AppDelegate
			let dataController = appDelegate.dataController
			
			let yrRequest: NSFetchRequest<YelpRestaurant> = YelpRestaurant.fetchRequest()
			let predicate = NSPredicate(format: "id == %@", id)
			yrRequest.predicate = predicate
			yrRequest.fetchLimit = 1
			do {
				let result = try dataController.viewContext.fetch(yrRequest)
				if let r = result.first {
					if let u = r.url {
						return URL(string: u)
					}
				}
				return nil
			} catch let error as NSError {
				print("UserRestaurantDetailsViewController - There was an error with the yelpId fetch: \(error)")
				return nil
			}
		} else {
			return nil
		}
	}
}
