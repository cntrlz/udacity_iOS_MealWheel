//
//  FirstViewController.swift
//  MealWheel
//
//  Created by benchmark on 8/30/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import CoreData
import CoreLocation
import SpinWheelControl
import UIKit

class WheelViewController: UIViewController {
	@IBOutlet var tableView: UITableView!
	@IBOutlet var toggleExpandButton: UIButton!
	@IBOutlet var detailsViewExpandedConstraint: NSLayoutConstraint!
	@IBOutlet var detailsViewCollapsedConstraint: NSLayoutConstraint!
	@IBOutlet var spinWheelControl: SpinWheelControl! // See https://github.com/joshdhenry/SpinWheelControl
	@IBOutlet var activityView: UIView!
	
	@IBOutlet weak var refreshButton: UIBarButtonItem!
//		{
//		didSet {
//			let refreshImage = UIImage.imageFromSystemBarButton(.refresh, renderingMode: .automatic)
//			let myButton = UIButton()
//			myButton.setImage(refreshImage, for: .normal)
//			myButton.addTarget(self, action: #selector(refresh), for: .touchUpInside)
//			refreshButton.customView = myButton
//		}
//	}
	
	var dataController: DataController!
	var fetchedResultsController: NSFetchedResultsController<YelpRestaurant>!
	var results: [RestaurantsQuery.Data.Search.Business?] = []
//	{
//		didSet {
//			tableView.reloadData()
//			spinWheelControl.reloadData()
//		}
//	}
	
	var tableViewExpanded: Bool = false
	var refreshControl: UIRefreshControl!
	
	let locationManager = CLLocationManager()
	var lastLocation: CLLocation = CLLocation()
	
//	var lastOffset: CGPoint?
//	var lastOffsetCapture : TimeInterval?
//	var isScrollingFast : Bool?
	var previousScrollMoment: Date = Date()
	var previousScrollX: CGFloat = 0
	
	var overlay: UIVisualEffectView = UIVisualEffectView()
	
	fileprivate func yelpSearchWithTerm(_ term: String! = "") {
//		(UIApplication.shared.delegate as! AppDelegate).apiClient.performDefaultFetch()
		(UIApplication.shared.delegate as! AppDelegate).apiClient.returnDefaultFetch(completion: { results, error in
			if error != nil {
				let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
				self.present(alert, animated: true)
				self.activityView.isHidden = true
				if self.overlay.isDescendant(of: self.view) {
					self.toggleBlur()
				}
			}
			if let results = results {
				if results.count == 0 {
					let alert = UIAlertController(title: "Farts", message: "You stink", preferredStyle: UIAlertControllerStyle.alert)
					alert.addAction(UIAlertAction(title: "oh no", style: UIAlertActionStyle.default, handler: nil))
					self.present(alert, animated: true)
					self.activityView.isHidden = true
					if self.overlay.isDescendant(of: self.view) {
						self.toggleBlur()
					}
				} else {
					self.results = results
					self.tableView.reloadData()
					self.spinWheelControl.reloadData()
					self.refreshControl.endRefreshing()
					self.activityView.isHidden = true
					
					if self.overlay.isDescendant(of: self.view) {
						self.toggleBlur()
					}
//					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//						self.refreshControl.endRefreshing()
//					})
//					DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
//						self.refreshControl.attributedTitle = NSAttributedString(string: "Refresh")
//					})
				}
			}
		})
		
//		let apollo = (UIApplication.shared.delegate as! AppDelegate).apollo
//
//		print("Calling query with term: ", term, "long and lat: ", lastLocation.coordinate.longitude, lastLocation.coordinate.latitude)
//
//		apollo.fetch(query: RestaurantsQuery(limit: 25, long: lastLocation.coordinate.longitude, lat: lastLocation.coordinate.latitude, cat: "restaurants", radius: 200), cachePolicy: .returnCacheDataElseFetch) { result, error in
//			print("Query complete")
//			if let error = error {
//				print("Error with RestaurantsQuery: \(error.localizedDescription)")
//				return
//			}
//
//			self.results = result?.data?.search?.business ?? []
//			self.cacheResults()
//		}
	}
	
	func filterResults(results: [RestaurantsQuery.Data.Search.Business?]) {
		// Does the id match one stored in our personal DB? If so, we have data on it
		// Apply frequency filters
		// Apply black/whitelist
		
		// Does the category or parents category of this match a category filter we have?
		// Apply category filters
	}
	
	fileprivate func setUpFetchedResultsController() {
		let fetchRequest: NSFetchRequest<YelpRestaurant> = YelpRestaurant.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "dateFetched", ascending: false)
		fetchRequest.sortDescriptors = [sortDescriptor]
		
		// TODO: Figure out "couldn't read cache file to update store info timestamps" error
		// for cache name "pins". For now, made cachename nil
		// Might be related to http://www.openradar.me/28361550
		fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		fetchedResultsController.delegate = self
		
		do {
			try fetchedResultsController.performFetch()
			if fetchedResultsController.sections?[0].numberOfObjects == 0 {
				print("WheelViewController - NO RESULTS")
			} else {
				spinWheelControl.reloadData()
			}
		} catch {
			fatalError("WheelViewController - The fetch in \(#function) could not be performed: \(error.localizedDescription)")
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		dataController = appDelegate.dataController
		
		// Set up spin wheel control
		spinWheelControl.dataSource = self
		spinWheelControl.delegate = self
		spinWheelControl.reloadData()
		spinWheelControl.addTarget(self, action: #selector(spinWheelDidChangeValue), for: UIControlEvents.valueChanged)
		
		// Set up table view
		tableView.delegate = self
		tableView.dataSource = self
		
//		setUpLocationManager()
		setUpFetchedResultsController()
		
		UserDefaults.standard.set(true, forKey: "firstRun")
		
		refreshControl = UIRefreshControl()
		tableView.addSubview(refreshControl)
		refreshControl.attributedTitle = NSAttributedString(string: "Refreshing")
		refreshControl.tintColor = UIColor.purple
		refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
		
		if !(results.count > 0) {
//			activityView.isHidden = false
			yelpSearchWithTerm()
		} else {
			activityView.isHidden = true
			print("We already have results, SO GOOD")
			tableView.reloadData()
			spinWheelControl.reloadData()
		}
	}
	
//	override func viewWillAppear(_ animated: Bool) {
//		activityView.isHidden = false
//	}
	
	@objc func refreshData() {
		toggleBlur()
		yelpSearchWithTerm()
	}
	
	// MARK: - Location
	
//	func setUpLocationManager() {
//		locationManager.delegate = self
//		locationManager.desiredAccuracy = kCLLocationAccuracyBest
//		locationManager.requestWhenInUseAuthorization()
//		locationManager.startUpdatingLocation()
//	}
//
//	func updateLocation(_ location: CLLocation) {
//		//		print("updated location")
//		lastLocation = location
//	}
//
	override func viewDidAppear(_ animated: Bool) {
		//		spinWheelControl.spin(velocityMultiplier: 0.5)
		//		spinWheelControl.randomSpin()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func toggleExpandTableView(_ sender: Any) {
		tableViewExpanded = !tableViewExpanded
		
		UIView.animate(withDuration: 0.5, animations: {
			self.detailsViewCollapsedConstraint.isActive = !self.tableViewExpanded
			self.detailsViewExpandedConstraint.isActive = self.tableViewExpanded
			self.view.layoutIfNeeded()
		})
		
		if tableViewExpanded {
			toggleExpandButton.setTitle("Collapse", for: .normal)
		} else {
			toggleExpandButton.setTitle("Expand", for: .normal)
		}
	}
	
	@objc func spinWheelDidChangeValue(sender: AnyObject) {
		let business = results[spinWheelControl.selectedIndex]!
//		let business = fetchedResultsController.object(at: IndexPath(row: spinWheelControl.selectedIndex, section: 0))
//		let alert = UIAlertController(title: "We have a winner!", message: "You're eating at: \(business.name!)", preferredStyle: .alert)
		let alert = UIAlertController(title: "We have a winner!", message: "You're eating at: \(business.fragments.businessDetails.name!)", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "YOSH!", style: UIAlertActionStyle.default, handler: { _ in
			// If we've eaten here before, increment visits and update lastVisited
			// Otherwise make a new object
			if let id = business.fragments.businessDetails.id {
				(UIApplication.shared.delegate as! AppDelegate).apiClient.cacheResults(results: [business])
				let fetch: NSFetchRequest<UserRestaurant> = UserRestaurant.fetchRequest()
				fetch.predicate = NSPredicate(format: "yelpId == %@", id)
				fetch.fetchLimit = 1
//				fetch.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
				let r: UserRestaurant
				do {
					let result = try self.dataController.viewContext.fetch(fetch)
					if result.count > 0 {
						r = self.dataController.viewContext.object(with: result.first!.objectID) as! UserRestaurant
						r.visits += 1
						r.lastVisited = Date()
					} else {
						print("Adding to userRestaurants")
						r = UserRestaurant(context: self.dataController.viewContext)
						let now = Date()
						r.yelpId = business.fragments.businessDetails.id
						r.dateCreated = now
						r.category = business.fragments.businessDetails.categories?.first!?.alias
						r.clusivity = 0
						r.name = business.fragments.businessDetails.name
						r.visits = 1
						r.lastVisited = now
						r.latitude = business.fragments.businessDetails.coordinates?.latitude ?? 0.0
						r.longitude = business.fragments.businessDetails.coordinates?.longitude ?? 0.0
					}
				} catch {
					fatalError("WheelViewController - The fetch for existing ID in \(#function) could not be performed: \(error.localizedDescription)")
				}
				
				try? self.dataController.viewContext.save()
			}
		}))
		alert.addAction(UIAlertAction(title: "nah", style: UIAlertActionStyle.cancel, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	func toggleBlur() {
		if overlay.isDescendant(of: view) {
			overlay.effect = nil
			overlay.removeFromSuperview()
		} else {
			overlay.frame = view.frame
			view.addSubview(overlay)
			UIView.animate(withDuration: 0.5) {
				self.overlay.effect = UIBlurEffect(style: .light)
			}
		}
	}
	
	@objc @IBAction func refresh(_ sender: Any) {
		toggleBlur()
		animateRefreshButton()
		yelpSearchWithTerm("mexican")
	}
	
	func animateRefreshButton() {
		UIView.animate(withDuration: 1.0, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: .curveLinear, animations: {
			if let b = self.navigationItem.rightBarButtonItem {
				print("buttan!")
				if let view = b.customView {
					print("vbiuu!")
					self.navigationItem.rightBarButtonItem?.customView?.transform = .identity
				}
			}
		}, completion: nil)
	}
}

extension WheelViewController: SpinWheelControlDataSource {
	func numberOfWedgesInSpinWheel(spinWheel: SpinWheelControl) -> UInt {
		return UInt(results.count)
//		let count = fetchedResultsController?.fetchedObjects?.count
//		return UInt(count ?? 0)
	}
	
	func wedgeForSliceAtIndex(index: UInt) -> SpinWheelWedge {
		let wedge = SpinWheelWedge()
		let label = SpinWheelWedgeLabel()
		label.textColor = UIColor.white
		label.shadowColor = UIColor.orange
		wedge.label = label
		wedge.shape.fillColor = UIColor.red.cgColor
		if let business = results[Int(index)] {
			wedge.label.text = business.fragments.businessDetails.name
		} else {
			wedge.label.text = "Unknown"
		}
		
//		wedge.label.text = fetchedResultsController.object(at: IndexPath(row: Int(index), section: 0)).name
		return wedge
	}
}

extension WheelViewController: SpinWheelControlDelegate {
	// Triggered at various intervals. The variable radians describes how many radians the spin wheel control has moved since the last time this method was called.
	func spinWheelDidRotateByRadians(radians: Radians) {
//		print("rotated \(String(describing: radians))")
		spinWheelControl.isUserInteractionEnabled = false
	}
	
	func spinWheelDidUpdateSelectedIndex(radians: Radians, description: String) {
		// print("rotated \(String(describing: radians)) in " + description)
		print(description)
	}
	
	// Triggered when the spin wheel control has come to rest after spinning.
	func spinWheelDidEndDecelerating(spinWheel: SpinWheelControl) {
		print("The spin wheel did end decelerating.")
		spinWheelControl.isUserInteractionEnabled = true
		let wedge = wedgeForSliceAtIndex(index: UInt(spinWheel.selectedIndex))
		wedge.shape.fillColor = UIColor.green.cgColor
		spinWheelControl.reloadInputViews()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let yrd = segue.destination as? YelpRestaurantDetailsViewController {
			let business = results[tableView.indexPathForSelectedRow!.row]!
			yrd.b = business
		}
		if let lv = segue.destination as? LandingViewController {
			// Clear results when "quitting"
			results = []
		}
	}
}

extension WheelViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return results.count
//		return fetchedResultsController.fetchedObjects?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if indexPath.row >= 8 {
			if !tableViewExpanded {
//				toggleExpandTableView([])
			}
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "showYelpRestaurantDetail", sender: nil)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		cell.accessoryType = .disclosureIndicator
		if let business = results[indexPath.row] {
			cell.textLabel!.text = business.fragments.businessDetails.name
		} else {
			cell.textLabel!.text = "Unknown"
		}
		
//		let r = fetchedResultsController.object(at: indexPath)
//		cell.textLabel!.text = r.name
		return cell
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
}

extension WheelViewController: NSFetchedResultsControllerDelegate {
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch type {
		case .insert:
			let yr = anObject as! YelpRestaurant
			print("insert:", yr)
			break
		case .delete:
			let yr = anObject as! YelpRestaurant
			print("delete:", yr)
			break
		case .update:
			let yr = anObject as! YelpRestaurant
			print("update:", yr)
			break
		case .move:
			let yr = anObject as! YelpRestaurant
			print("move:", yr)
			break
		}
	}
}

extension WheelViewController: UIScrollViewDelegate {
	func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		if !(UserDefaults.standard.bool(forKey: "swipeToggleExpansion")) { return }
		if abs(velocity.y) > 2.5 {
			if (velocity.y < 0 && tableViewExpanded) || (velocity.y > 0 && !tableViewExpanded) {
				UIView.animate(withDuration: 0.5) {
					self.toggleExpandTableView([])
					self.view.layoutIfNeeded()
				}
			}
		}
	}
}

// https://stackoverflow.com/questions/21187885/use-uibarbuttonitem-icon-in-uibutton
extension UIImage{
	
	class func imageFromSystemBarButton(_ systemItem: UIBarButtonSystemItem, renderingMode:UIImageRenderingMode = .automatic)-> UIImage {
		
		let tempItem = UIBarButtonItem(barButtonSystemItem: systemItem, target: nil, action: nil)
		
		// add to toolbar and render it
		let bar = UIToolbar()
		bar.setItems([tempItem], animated: false)
		bar.snapshotView(afterScreenUpdates: true)
		
		// got image from real uibutton
		let itemView = tempItem.value(forKey: "view") as! UIView
		
		for view in itemView.subviews {
			if view is UIButton {
				let button = view as! UIButton
				let image = button.imageView!.image!
				image.withRenderingMode(renderingMode)
				return image
			}
		}
		
		return UIImage()
	}
}
