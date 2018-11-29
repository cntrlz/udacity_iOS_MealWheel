//
//  FirstViewController.swift
//  MealWheel
//
//  Created by benchmark on 8/30/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

// TODO: Perhaps implement this: https://www.thorntech.com/2015/08/how-to-animate-a-bar-button-item-swift/
// TODO: Check out dropdowns:
/*
 https://github.com/hyperoslo/Dropdowns
 https://github.com/Cokile/CCDropDownMenu
 https://www.cocoacontrols.com/controls/lmdropdownview
 https://www.cocoacontrols.com/controls/btnavigationdropdownmenu
 */

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
	@IBOutlet var refreshButton: UIBarButtonItem!
	@IBOutlet var errorView: UIView!
	
	var dataController: DataController!
	var fetchedResultsController: NSFetchedResultsController<YelpRestaurant>!
	var searchResults: [RestaurantsQuery.Data.Search.Business?] = []
	var myResults: [UserRestaurant]? = nil
	var tableViewExpanded: Bool = false
	var refreshControl: UIRefreshControl!
	let locationManager = CLLocationManager()
	var lastLocation: CLLocation = CLLocation()
	var previousScrollMoment: Date = Date()
	var previousScrollX: CGFloat = 0
	var overlay: UIVisualEffectView = UIVisualEffectView()
	var spinAtLoad: Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		dataController = appDelegate.dataController
		
		setUpSpinWheelControl()
		//		setUpRefreshControl()
		setUpFetchedResultsController()
		
		tableView.delegate = self
		tableView.dataSource = self
		
		if myResults == nil {
			if !(searchResults.count > 0) {
				yelpSearchWithTerm()
			} else {
				tableView.reloadData()
				spinWheelControl.reloadData()
			}
		}
		
		if spinAtLoad {
			spinWheelControl.randomSpin()
			spinAtLoad = false
		}
		
		// Maybe move this to AppDelegate? Or do we perhaps want this only once
		// they've viewed this VC...
		UserDefaults.standard.set(true, forKey: "firstRun")
	}
	
	fileprivate func setUpSpinWheelControl() {
		spinWheelControl.dataSource = self
		spinWheelControl.delegate = self
		spinWheelControl.reloadData()
		spinWheelControl.addTarget(self, action: #selector(spinWheelDidChangeValue), for: UIControlEvents.valueChanged)
	}
	
	fileprivate func setUpRefreshControl() {
		refreshControl = UIRefreshControl()
		refreshControl.attributedTitle = NSAttributedString(string: "Refreshing")
		refreshControl.tintColor = UIColor.purple
		refreshControl.addTarget(self, action: #selector(refreshControlRefreshed), for: .valueChanged)
		tableView.addSubview(refreshControl)
	}
	
	fileprivate func setUpFetchedResultsController() {
		let fetchRequest: NSFetchRequest<YelpRestaurant> = YelpRestaurant.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "dateFetched", ascending: false)
		fetchRequest.sortDescriptors = [sortDescriptor]
		
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
	
	@IBAction func wheelControlTouched(_ sender: Any) {
		spinWheelControl.randomSpin()
	}
	
	fileprivate func yelpSearchWithTerm(_ term: String! = "") {
		errorView.isHidden = true
		(UIApplication.shared.delegate as! AppDelegate).apiClient.returnDefaultFetch(completion: { results, error in
			if error != nil {
				let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
				self.present(alert, animated: true)
				self.errorView.isHidden = false
				if self.overlay.isDescendant(of: self.view) {
					self.toggleBlur()
				}
			}
			if let results = results {
				if results.count == 0 {
					let alert = UIAlertController(title: "No Results", message: "There are no nearby restaurants matching the filters you have set", preferredStyle: UIAlertControllerStyle.alert)
					alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
					self.present(alert, animated: true)
					if self.overlay.isDescendant(of: self.view) {
						self.toggleBlur()
					}
				} else {
					self.searchResults = results
					self.tableView.reloadData()
					self.spinWheelControl.reloadData()
					self.refreshControl?.endRefreshing()
					
					if self.overlay.isDescendant(of: self.view) {
						self.toggleBlur()
					}
				}
			}
		})
	}
	
	func filterResults(results: [RestaurantsQuery.Data.Search.Business?]) {
		// Does the id match one stored in our personal DB? If so, we have data on it
		// Apply frequency filters
		// Apply black/whitelist
		
		// Does the category or parents category of this match a category filter we have?
		// Apply category filters
	}
	
	@objc @IBAction func refresh(_ sender: Any) {
		toggleBlur()
		myResults = nil
		yelpSearchWithTerm("")
	}
	
	@objc func refreshControlRefreshed() {
		toggleBlur()
		myResults = nil
		yelpSearchWithTerm()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
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
		// sloppy flipflop
		var searchBusiness: RestaurantsQuery.Data.Search.Business? = nil
		var myPlace: UserRestaurant? = nil
		if let mr = myResults {
			myPlace = mr[spinWheelControl.selectedIndex]
		} else {
			searchBusiness = searchResults[spinWheelControl.selectedIndex]!
		}
		

		let alert = UIAlertController(title: "WINNER!", message: "You're eating at: \(searchBusiness?.fragments.businessDetails.name! ?? myPlace?.name ?? "" )", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive, handler: nil))
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { _ in
			// If we've eaten here before, increment visits and update lastVisited
			// Otherwise make a new object
			let autoSave = UserDefaults.standard.bool(forKey: "autoSave")
			
			if autoSave, let id = searchBusiness?.fragments.businessDetails.id ?? myPlace?.yelpId {
				(UIApplication.shared.delegate as! AppDelegate).apiClient.cacheResults(results: [searchBusiness])
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
						r.yelpId = searchBusiness?.fragments.businessDetails.id ?? myPlace?.yelpId
						r.dateCreated = now
						r.category = searchBusiness?.fragments.businessDetails.categories?.first!?.alias ?? myPlace?.category
						r.clusivity = 0
						r.name = searchBusiness?.fragments.businessDetails.name ?? myPlace?.name
						r.visits = 1
						r.lastVisited = now
						r.latitude = searchBusiness?.fragments.businessDetails.coordinates?.latitude ?? myPlace?.latitude ?? 0.0
						r.longitude = searchBusiness?.fragments.businessDetails.coordinates?.longitude ?? myPlace?.longitude ?? 0.0
					}
				} catch {
					fatalError("WheelViewController - The fetch for existing ID in \(#function) could not be performed: \(error.localizedDescription)")
				}
				
				try? self.dataController.viewContext.save()
			}
		}))
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
}

extension WheelViewController: SpinWheelControlDataSource {
	func numberOfWedgesInSpinWheel(spinWheel: SpinWheelControl) -> UInt {
		return UInt(myResults != nil ? myResults!.count : searchResults.count)
//		let count = fetchedResultsController?.fetchedObjects?.count
//		return UInt(count ?? 0)
	}
	
	func wedgeForSliceAtIndex(index: UInt) -> SpinWheelWedge {
		let wedge = SpinWheelWedge()
		let label = SpinWheelWedgeLabel()
		label.textColor = UIColor.white
//		label.shadowColor = UIColor.orange
		wedge.label = label
		wedge.shape.fillColor = UIColor.randomColor().cgColor
		if let mr = myResults {
			wedge.label.text = mr[Int(index)].name ?? "Unknown"
		} else if let business = searchResults[Int(index)] {
			wedge.label.text = business.fragments.businessDetails.name?.truncate(length: 15)
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
			if let mr = myResults {
				let alert = UIAlertController(title: "Shit", message: "You Done Goofed. YelpRestaurantDetails needs a funny business type. Make a fucking enum already.", preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "NOT OK", style: UIAlertActionStyle.default, handler: nil))
				self.present(alert, animated: true)
			} else {
				let business = searchResults[tableView.indexPathForSelectedRow!.row]!
				yrd.b = business
			}
		}
		if segue.destination is LandingViewController {
			// Clear results when "quitting"
			searchResults = []
			myResults = nil
		}
	}
}

extension WheelViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return myResults != nil ? myResults!.count : searchResults.count
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
		
		if myResults != nil {
			cell.textLabel?.text = myResults![indexPath.row].name ?? "Unknown"
		} else {
			if let business = searchResults[indexPath.row] {
				cell.textLabel!.text = business.fragments.businessDetails.name
			} else {
				cell.textLabel!.text = "Unknown"
			}
		}
		
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
