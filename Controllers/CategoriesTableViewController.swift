//
//  CategoriesTableViewController.swift
//  MealWheel
//
//  Created by benchmark on 11/23/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import UIKit
import CoreData

// TODO: Implement this fully as time permits.
class CategoriesTableViewController: UITableViewController {
	var dataController: DataController = (UIApplication.shared.delegate as! AppDelegate).dataController
	var fetchedResultsController: NSFetchedResultsController<UserCategory>!

    override func viewDidLoad() {
        super.viewDidLoad()
		setupFetchedResultsController()
    }
	
	fileprivate func setupFetchedResultsController(_ clusivity: Int? = nil) {
		let fetchRequest: NSFetchRequest<UserCategory> = UserCategory.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
		fetchRequest.sortDescriptors = [sortDescriptor]
		fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
		fetchedResultsController.delegate = self
		
		do {
			try fetchedResultsController.performFetch()
		} catch {
			fatalError("CategoriesTableViewController - The fetch could not be performed: \(error.localizedDescription)")
		}
	}
	
	@IBAction func addNewCategory(_ sender: Any) {
		print("Hey, implement categories, yeah?")
	}
	
    // MARK: - TableView data source
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fetchedResultsController.fetchedObjects?.count ?? 0
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "categoryTableViewCell", for: indexPath)
		let c = fetchedResultsController.object(at: indexPath) as UserCategory
		cell.textLabel?.text = c.name
		return cell
	}
}

extension CategoriesTableViewController: NSFetchedResultsControllerDelegate {
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch type {
		case .insert:
			let uc = anObject as! UserCategory
			print("insert:", uc)
			tableView.insertRows(at: [newIndexPath!], with: .automatic)
			break
		case .delete:
			let uc = anObject as! UserCategory
			print("delete:", uc, indexPath!, tableView.numberOfRows(inSection: 0))
			tableView.reloadData()
			break
		case .update:
			let uc = anObject as! UserCategory
			print("update:", uc)
			tableView.reloadRows(at: [indexPath!], with: UITableViewRowAnimation.automatic)
			break
		case .move:
			let uc = anObject as! UserCategory
			print("move:", uc)
			tableView.moveRow(at: indexPath!, to: newIndexPath!)
			break
		}
	}
}
