//
//  CategoriesTableViewController.swift
//  MealWheel
//
//  Created by benchmark on 11/23/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import UIKit
import CoreData

class CategoriesTableViewController: UITableViewController {
	var dataController: DataController = (UIApplication.shared.delegate as! AppDelegate).dataController
	var fetchedResultsController: NSFetchedResultsController<UserCategory>!

    override func viewDidLoad() {
        super.viewDidLoad()
		setupFetchedResultsController()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
		print("merp")
	}
	
    // MARK: - Table view data source

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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
