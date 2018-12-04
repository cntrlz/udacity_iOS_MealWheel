//
//  DataController.swift
//  MealWheel
//
//  Created by benchmark on 11/15/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import Foundation
import CoreData

class DataController {
	let persistentContainer:NSPersistentContainer
	
	var viewContext: NSManagedObjectContext {
		// To log cool stuff out, add concurrency debug flag to product schema
		// -com.apple.CoreData.ConcurrencyDebug 1 < level 1, 2, or 3 detail
		return persistentContainer.viewContext
	}
	
// Uncomment for background context use
//	 var backgroundContext: NSManagedObjectContext!
	
	init(modelName:String){
		persistentContainer = NSPersistentContainer(name: modelName)
// Uncomment for background context use
//		backgroundContext = persistentContainer.newBackgroundContext()
		
		//	Cool methods, for reference
		//		On the container...
		//			persistentContainer.performBackgroundTask { (context) in
		//				doSomeWork()
		//				try save
		//			}
		//		And on the context...
		//			viewContext.perform {
		//				someStuffAsynchronouslyOnCorrectQueueForContext()
		//			}
		//
		//			viewContext.performAndWait {
		//				someStuffSynchronouslyOnCorrectQueue()
		//			}
	}
	
	func configureContexts() {
		// Both contexts will merge in chages from parent
		viewContext.automaticallyMergesChangesFromParent = true
		
// Uncomment for background context use
//		backgroundContext.automaticallyMergesChangesFromParent = true
// 		Background changes will override view context
//		backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
		
		viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
	}
	
	func load(completion: (() -> Void)? = nil) {
		persistentContainer.loadPersistentStores { storeDescription, error in
			guard error == nil else {
				fatalError(error!.localizedDescription)
			}
			self.autoSaveContext()
			self.configureContexts()
			completion?()
		}
	}
}

extension DataController {
	func autoSaveContext(interval:TimeInterval = 30){
		print("DataController - Autosaving context")
		guard interval > 0 else {
			print("DataController - Autosave time interval must be a positive integer")
			return
		}
		if viewContext.hasChanges {
			try? viewContext.save()
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
			self.autoSaveContext(interval: interval)
		}
	}
}

extension DataController {
	func addOrUpdateUserRestaurant(r: UserRestaurant){
		
	}
}
