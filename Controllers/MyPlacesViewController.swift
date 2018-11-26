//
//  MyPlacesViewController.swift
//  MealWheel
//
//  Created by benchmark on 11/16/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import CoreData
import Foundation
import UIKit

class MyPlacesViewController: UIViewController {
	@IBOutlet var tableView: UITableView!
	@IBOutlet var editButton: UIBarButtonItem!
	
	var dataController: DataController = (UIApplication.shared.delegate as! AppDelegate).dataController
	var fetchedResultsController: NSFetchedResultsController<UserRestaurant>!
	var userRestaurants: [UserRestaurant?]!
	var trashButton: UIBarButtonItem = UIBarButtonItem()
	var addButton: UIBarButtonItem = UIBarButtonItem()
	
	override func viewDidLoad() {
		tableView.delegate = self
		tableView.dataSource = self
		
		setupFetchedResultsController()
		
		trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePlaces))
		addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPlace(_:)))
		navigationItem.rightBarButtonItem = addButton
	}
	
	// MARK: - Core Data
	
	fileprivate func setupFetchedResultsController() {
		let fetchRequest: NSFetchRequest<UserRestaurant> = UserRestaurant.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
		fetchRequest.sortDescriptors = [sortDescriptor]
		
		fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		fetchedResultsController.delegate = self
		
		do {
			try fetchedResultsController.performFetch()
//			userRestaurants = fetchedResultsController.fetchedObjects
		} catch {
			fatalError("MyPlacesViewController - The fetch could not be performed: \(error.localizedDescription)")
		}
	}
	
	@IBAction func toggleEditing(_ sender: Any) {
		if tableView.isEditing {
			tableView.setEditing(false, animated: true)
			editButton.title = "Edit"
			navigationItem.rightBarButtonItem = addButton
		} else {
			tableView.setEditing(true, animated: true)
			editButton.title = "Done"
			navigationItem.rightBarButtonItem = trashButton
		}
	}
	
	@IBAction func addPlace(_ sender: Any) {
		print("Gotta add, man!")
		performSegue(withIdentifier: "addCustomRestaurant", sender: self)
	}
	
	func deleteAllPlaces() {
		for restaurant in self.fetchedResultsController.fetchedObjects ?? [] {
			self.dataController.viewContext.delete(restaurant)
			
		}
		try? self.dataController.viewContext.save()
		
//		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserRestaurant")
//		let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//		do {
//			try dataController.viewContext.execute(deleteRequest)
//			try? dataController.viewContext.save()
//		} catch let error as NSError {
//			print("MyPlacesView - There was an error with the batch delete: \(error)")
//		}
	}
	
	@objc func deletePlaces() {
		if tableView.indexPathsForSelectedRows == nil {
			let alert = UIAlertController(title: "Delete All Places?", message: "Are you sure you want to delete all your places?", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
			alert.addAction(UIAlertAction(title: "Delete All", style: UIAlertActionStyle.destructive) { _ in
				for place in self.fetchedResultsController.fetchedObjects ?? [] {
					self.dataController.viewContext.delete(place)
								try? self.dataController.viewContext.save()
				}
				self.toggleEditing([])
			})
			present(alert, animated: true, completion: nil)
		} else {
			let alert = UIAlertController(title: "Delete Selected Places?", message: "Are you sure you want the places you have selected?", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
			alert.addAction(UIAlertAction(title: "Delete Selected", style: UIAlertActionStyle.destructive) { _ in
				let selectedRows = self.tableView.indexPathsForSelectedRows ?? []
				for indexPath in selectedRows {
					let object = self.fetchedResultsController.object(at: indexPath)
					self.dataController.viewContext.delete(object)
				}
				try? self.dataController.viewContext.save()
				self.toggleEditing([])
			})
			present(alert, animated: true, completion: nil)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? UserRestaurantDetailsViewController {
			vc.r = fetchedResultsController.object(at: tableView.indexPathForSelectedRow!)
		}
	}
}

extension MyPlacesViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fetchedResultsController.fetchedObjects?.count ?? 0
//		return userRestaurants.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "myPlacesTableViewCell") as! MyPlacesTableViewCell
//		let r = userRestaurants[indexPath.row]!
		let r = fetchedResultsController.object(at: indexPath)
		cell.label.text = r.name
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if tableView.isEditing {
			return
		}
		performSegue(withIdentifier: "showUserRestaurantDetail", sender: nil)
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			dataController.viewContext.delete(fetchedResultsController.object(at: indexPath))
			try? dataController.viewContext.save()
		}
	}
}

extension MyPlacesViewController: NSFetchedResultsControllerDelegate {
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch type {
		case .insert:
			let ur = anObject as! UserRestaurant
			print("insert:", ur)
			tableView.insertRows(at: [newIndexPath!], with: .automatic)
			break
		case .delete:
			let ur = anObject as! UserRestaurant
			print("delete:", ur, indexPath!, tableView.numberOfRows(inSection: 0))
			tableView.reloadData()
			break
		case .update:
			let ur = anObject as! UserRestaurant
			print("update:", ur)
			tableView.reloadRows(at: [indexPath!], with: UITableViewRowAnimation.automatic)
			break
		case .move:
			let ur = anObject as! UserRestaurant
			print("move:", ur)
			tableView.moveRow(at: indexPath!, to: newIndexPath!)
			break
		}
	}
}
