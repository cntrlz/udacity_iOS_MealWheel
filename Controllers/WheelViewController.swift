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
	@IBOutlet var pinImageView: UIImageViewWithPreserveVectorDataFix!
	
	var dataController: DataController!
	var fetchedResultsController: NSFetchedResultsController<YelpRestaurant>!
	var searchResults: [RestaurantsQuery.Data.Search.Business?] = []
	var myResults: [UserRestaurant]?
	var temporaryResults: [String]?
	var filteredResults: [RestaurantResult]? {
		didSet {
			tableView.reloadData()
			spinWheelControl.reloadData()
		}
	}
	
	var tableViewExpanded: Bool = false
	var refreshControl: UIRefreshControl!
	let locationManager = CLLocationManager()
	var lastLocation: CLLocation = CLLocation()
	var previousScrollMoment: Date = Date()
	var previousScrollX: CGFloat = 0
	var overlay: UIVisualEffectView = UIVisualEffectView()
	var spinAtLoad: Bool = false
	var needsUpdate: Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		dataController = appDelegate.dataController
		
		setUpSpinWheelControl()
		// Uncomment to add a refresh control to the table view. It's kinda
		// awkward to activate so it's not being used right now.
		//		setUpRefreshControl()
		setUpFetchedResultsController()
		
		tableView.delegate = self
		tableView.dataSource = self
		
		if temporaryResults != nil {
			filterResults(normalizeResults(temporaryResults as Any))
		} else if myResults != nil {
			filterResults(normalizeResults(myResults as Any))
		} else {
			if !(searchResults.count > 0) {
				needsUpdate = true
				yelpSearchWithTerm()
			} else {
				filterResults(normalizeResults(searchResults as Any))
				tableView.reloadData()
				spinWheelControl.reloadData()
			}
		}
		
		if spinAtLoad {
			if filteredResults?.count ?? 0 > 1 {
				spinWheelControl.randomSpin()
			}
			
			spinAtLoad = false
		}
		
		UserDefaults.standard.set(true, forKey: "firstRun")
	}
	
	override func viewWillAppear(_ animated: Bool) {
		// Re-apply filters
		// Check for proper number, as you CAN blacklist things away until
		// you have 1 or no options left
		if temporaryResults != nil && (temporaryResults?.count ?? 0 > 1) {
			filterResults(normalizeResults(temporaryResults as Any))
		} else if myResults != nil && (myResults?.count ?? 0 > 1 ) {
			filterResults(normalizeResults(myResults as Any))
		} else if searchResults.count > 1 {
			filterResults(normalizeResults(searchResults as Any))
		}
		
		checkValidNumberOfResults()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		// TODO: Stop alerts from showing on other controllers.
		// TODO: Stop wheel motion, or suspend until user returns to this tab...?
	}
	
	// MARK: Setup
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
	
	// MARK: Networking
	@objc @IBAction func refresh(_ sender: Any) {
		if temporaryResults != nil {
			let alert = UIAlertController(title: "Temporary Places", message: "Refreshing will run a search using your currently set filters, and you will lose any temporary places you have added that were not otherwise saved.", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
			alert.addAction(UIAlertAction(title: "Refresh", style: UIAlertActionStyle.destructive, handler: { _ in
				self.temporaryResults = nil
				self.refresh([])
			}))
			present(alert, animated: true)
		} else {
			toggleBlur()
			temporaryResults = nil
			myResults = nil
			filteredResults = nil
			yelpSearchWithTerm("")
		}
	}
	
	@objc func refreshControlRefreshed() {
		toggleBlur()
		temporaryResults = nil
		myResults = nil
		yelpSearchWithTerm()
		filteredResults = nil
	}
	
	fileprivate func yelpSearchWithTerm(_ term: String! = "") {
		errorView.isHidden = true
		pinImageView.isHidden = false
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
					self.pinImageView.isHidden = true
					self.errorView.isHidden = false
					if self.overlay.isDescendant(of: self.view) {
						self.toggleBlur()
					}
				} else {
					self.searchResults = results
					self.filterResults(self.normalizeResults(self.searchResults))
					
					self.tableView.reloadData()
					self.spinWheelControl.reloadData()
					self.refreshControl?.endRefreshing()
					self.checkValidNumberOfResults()
					if self.overlay.isDescendant(of: self.view) {
						self.toggleBlur()
					}
				}
			}
			
			self.needsUpdate = false
		})
	}
	
	// MARK: Results validation and filtering
	func checkValidNumberOfResults() {
		if !needsUpdate && filteredResults?.count ?? 0 <= 1 {
			let alert = UIAlertController(title: "Not Enough Places", message: "Please loosen your filters! You must always have at least two places to choose between. Check your filters and reload to make sure you have at least two options.", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
			alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.default, handler: { _ in
				self.refresh([])
			}))
			self.present(alert, animated: true)
			errorView.isHidden = false
			filteredResults = []
		}
	}
	
	func normalizeResults(_ results: Any) -> [RestaurantResult] {
		var newResults: [RestaurantResult] = []
		if results is [RestaurantsQuery.Data.Search.Business?] {
			print("result type is yelp results")
			for result in results as! [RestaurantsQuery.Data.Search.Business?] {
				if let r = result?.fragments.businessDetails {
					let nr = RestaurantResult()
					nr.type = .Yelp
					nr.yelpId = r.id
					nr.name = r.name
					nr.yelpRating = r.rating
					nr.latitude = r.coordinates?.latitude
					nr.longitude = r.coordinates?.longitude
					nr.priceRating = r.price?.count
					nr.yelpUrl = r.url
					nr.category = r.categories?.first??.alias
					nr.address = r.location?.address1
					
					// We can check to see if we already have data on this!
					// sketchy
					if let id = nr.yelpId {
						let fetch: NSFetchRequest<UserRestaurant> = UserRestaurant.fetchRequest()
						fetch.predicate = NSPredicate(format: "yelpId == %@", id)
						do {
							let match = try dataController.viewContext.fetch(fetch)
							if let ur = match.first {
								nr.id = ur.objectID
								nr.clusivity = Int(ur.clusivity)
								nr.visits = Int(ur.visits)
								nr.lastVisited = ur.lastVisited
							}
						} catch {
							fatalError("WheelViewController - The fetch to match a Yelp to local restaurant in \(#function) could not be performed: \(error.localizedDescription)")
						}
					}
					
					newResults.append(nr)
				}
			}
		} else if results is [UserRestaurant] {
			print("result type is fetched coredata objects")
			for r in results as! [UserRestaurant] {
				let nr = RestaurantResult()
				nr.type = .CoreData
				nr.id = r.objectID
				nr.yelpId = r.yelpId
				nr.name = r.name
				nr.userRating = r.rating
				nr.latitude = r.latitude
				nr.longitude = r.longitude
				nr.priceRating = Int(r.price)
				nr.yelpUrl = r.yelpUrl
				nr.category = r.category
				nr.visits = Int(r.visits)
				nr.lastVisited = r.lastVisited
				nr.dateCreated = r.dateCreated
				// nr.address = r.address // TODO: Check - Are we storing addresses this way?
				newResults.append(nr)
			}
		} else if results is [String] {
			print("result type is temporary places")
			for r in results as! [String] {
				let nr = RestaurantResult()
				nr.type = .Custom
				nr.name = r
				newResults.append(nr)
			}
		}
		
		print("normalized: ", newResults)
		return newResults
	}
	
	func filterResults(_ results: [RestaurantResult]) {
		let bl = UserDefaults.standard.bool(forKey: "blacklistEnabled")
		let wl = UserDefaults.standard.bool(forKey: "whitelistEnabled")
		
		var filtered: [RestaurantResult] = results
		errorView.isHidden = true
		
		if bl {
			let fetch: NSFetchRequest<UserRestaurant> = UserRestaurant.fetchRequest()
			fetch.predicate = NSPredicate(format: "clusivity == -1")
			do {
				let blacklisted = try dataController.viewContext.fetch(fetch)
				if blacklisted.count > 0 {
					let yelpIds: [String] = blacklisted.reduce([String]()) { result, item in
						var results = result
						if let id = item.yelpId {
							results.append(id)
						}
						return results
					}
					let objectIds: [NSManagedObjectID] = blacklisted.reduce([NSManagedObjectID]()) { result, item in
						var results = result
						results.append(item.objectID)
						return results
					}
					let srBlRemoved = results.filter { (r) -> Bool in
						if let id = r.yelpId {
							if yelpIds.contains(id) { return false }
						}
						if let objectId = r.id {
							if objectIds.contains(objectId) { return false }
						}
						return true
					}
					filtered = srBlRemoved
				} else {
					print("Nothing blacklisted")
				}
			} catch {
				fatalError("WheelViewController - The fetch for blacklisted places in \(#function) could not be performed: \(error.localizedDescription)")
			}
		}
		
		let frequencySetting = UserDefaults.standard.float(forKey: "filterFrequency")
		let maxFrequency = UserDefaults.standard.float(forKey: "maxFrequency")
		let filterCutoff = Int(round(frequencySetting * maxFrequency))
		
		if filterCutoff <= 9 {
			let frequencyFiltered = filtered.filter({ (rr) -> Bool in
				if rr.id == nil && rr.yelpId == nil { return true } // Don't filer quick adds
				return rr.visits ?? 0 >= filterCutoff
			})
			
			filtered = frequencyFiltered
		}
		
		if wl {
			let fetch: NSFetchRequest<UserRestaurant> = UserRestaurant.fetchRequest()
			fetch.predicate = NSPredicate(format: "clusivity == 1")
			do {
				let whitelisted = try dataController.viewContext.fetch(fetch)
				if whitelisted.count > 0 {
					let add = normalizeResults(whitelisted)
					let existingIds: [String] = filtered.reduce([String]()) { result, item in
						var results = result
						if let id = item.yelpId {
							results.append(id)
						}
						return results
					}
					
					for r in add {
						// If the place has a yelp id,
						// make sure not to insert it twice
						if let id = r.yelpId {
							if !existingIds.contains(id){
								filtered.append(r)
							}
						// If it doesn't have a yelp id,
						// it is a custom restaurant and we
						// always include it
						} else {
							filtered.append(r)
						}
					}
					
				} else {
					print("Nothing whitelisted")
				}
			} catch {
				fatalError("WheelViewController - The fetch for whitelisted places in \(#function) could not be performed: \(error.localizedDescription)")
			}
		}
		
		filteredResults = filtered
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// MARK: WheelView
	@IBAction func wheelControlTouched(_ sender: Any) {
		spinWheelControl.randomSpin()
	}
	
	@objc func spinWheelDidChangeValue(sender: AnyObject) {
		let place = filteredResults?[spinWheelControl.selectedIndex]
		
		let alert = UIAlertController(title: "WINNER", message: "MealWheel hath spoken, and the word is: \(place?.name ?? "")", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Somewhere Else", style: UIAlertActionStyle.destructive, handler: nil))
		alert.addAction(UIAlertAction(title: "I'm Eating Here!", style: UIAlertActionStyle.default, handler: { _ in
			// If we've eaten here before, increment visits and update lastVisited
			// Otherwise make a new object
			let autoSave = UserDefaults.standard.bool(forKey: "autoSave")
			
			// CoreData things are already saved. Custom/Yelp things are the only ones we can actually save
			if autoSave && place?.type != .CoreData {
				// Do we really need to cache anything?
//				(UIApplication.shared.delegate as! AppDelegate).apiClient.cacheResults(results: [searchBusiness])
				
				if place?.type == .Yelp {
					let fetch: NSFetchRequest<UserRestaurant> = UserRestaurant.fetchRequest()
					fetch.predicate = NSPredicate(format: "yelpId == %@", place!.yelpId!) // TODO: Probrems?
					fetch.fetchLimit = 1
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
							r.dateCreated = now
							r.clusivity = 0
							r.visits = 1
							r.lastVisited = now
							
							r.yelpId = place?.yelpId
							r.category = place?.category
							r.name = place?.name
							r.latitude = place?.latitude ?? 0
							r.longitude = place?.longitude ?? 0
						}
					} catch {
						fatalError("WheelViewController - The fetch for existing ID in \(#function) could not be performed: \(error.localizedDescription)")
					}
					
					try? self.dataController.viewContext.save()
				} else {
					let r = UserRestaurant(context: self.dataController.viewContext)
					let now = Date()
					r.dateCreated = now
					r.clusivity = 0
					r.visits = 1
					r.lastVisited = now
					r.name = place?.name
					
					try? self.dataController.viewContext.save()
				}
				
				if let p = place {
					self.showConfirmDialog(p)
				}
			}
		}))
		present(alert, animated: true, completion: nil)
	}
	
	// MARK: UI
	@IBAction func toggleExpandTableView(_ sender: Any) {
		tableViewExpanded = !tableViewExpanded
		
		UIView.animate(withDuration: 0.5, animations: {
			self.detailsViewCollapsedConstraint.isActive = !self.tableViewExpanded
			self.detailsViewExpandedConstraint.isActive = self.tableViewExpanded
			self.view.layoutIfNeeded()
		})
		
		if tableViewExpanded {
			toggleExpandButton.setTitle("Collapse", for: .normal)
			pinImageView.isHidden = true
		} else {
			toggleExpandButton.setTitle("Expand", for: .normal)
			pinImageView.isHidden = false
		}
	}
	
	
	func showConfirmDialog(_ place: RestaurantResult) {
		let details = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "yelpDetails") as! YelpRestaurantDetailsViewController
		details.nb = place
		navigationController?.pushViewController(details, animated: true)
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
		return UInt(filteredResults?.count ?? 0)
	}
	
	func wedgeForSliceAtIndex(index: UInt) -> SpinWheelWedge {
		let wedge = SpinWheelWedge()
		let label = SpinWheelWedgeLabel()
		label.textColor = UIColor.white
		wedge.label = label
		wedge.shape.fillColor = UIColor.randomColor().cgColor
		
		if let fr = filteredResults {
			wedge.label.text = fr[Int(index)].name
		} else {
			wedge.label.text = "Unknown"
		}
		
		return wedge
	}
}

extension WheelViewController: SpinWheelControlDelegate {
	// Triggered at various intervals. The variable radians describes how many radians the spin wheel control has moved since the last time this method was called.
	func spinWheelDidRotateByRadians(radians: Radians) {
		spinWheelControl.isUserInteractionEnabled = false
	}
	
	func spinWheelDidUpdateSelectedIndex(radians: Radians, description: String) {
		print("\(#function) - rotated \(String(describing: radians)) in " + description)
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
			yrd.nb = filteredResults![tableView.indexPathForSelectedRow!.row]
		}
		if segue.destination is LandingViewController {
			// Clear results when "quitting"
			searchResults = []
			myResults = nil
			temporaryResults = nil
		}
	}
}

extension WheelViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredResults?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if indexPath.row >= 8 {
			if !tableViewExpanded {
				// Uncomment this to make the tableview auto-expand once the user has scrolled to the bottom.
				// Situationally useful, but awkward in the same way as the refresh control, and therefore commented-out.
				// toggleExpandTableView([])
			}
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "showYelpRestaurantDetail", sender: nil)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		cell.accessoryType = .disclosureIndicator
		cell.textLabel!.text = filteredResults![indexPath.row].name ?? "Unknown"
		return cell
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
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
