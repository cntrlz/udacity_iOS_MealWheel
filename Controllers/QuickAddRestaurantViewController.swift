//
//  QuickAddRestaurantViewController.swift
//  MealWheel
//
//  Created by benchmark on 11/26/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import UIKit

class QuickAddRestaurantViewController: UIViewController {
	// We don't want to clutter the UI, so we've limited the manual inputs to six
	@IBOutlet var add1: QuickAddRestaurantView!
	@IBOutlet var add2: QuickAddRestaurantView!
	@IBOutlet var add3: QuickAddRestaurantView!
	@IBOutlet var add4: QuickAddRestaurantView!
	@IBOutlet var add5: QuickAddRestaurantView!
	@IBOutlet var add6: QuickAddRestaurantView!
	
	var addViews: [QuickAddRestaurantView]!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "skip", style: .plain, target: self, action: #selector(skip))
		
		addViews = [add1, add2, add3, add4, add5, add6]
		for (index, q) in addViews.enumerated() {
			q.delegate = self
			q.button.tag = index
			if index != 0 {
				q.isHidden = true
			}
		}
	}
	
	@IBAction func spin(_ sender: Any) {
		let addedViews = addViews.filter { $0.isAdded() }
		if addedViews.count < 2 {
			let alert = UIAlertController(title: "Add More Places", message: "Add at least two places to spin the wheel", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
			present(alert, animated: true)
		} else {
			performSegue(withIdentifier: "quickAddToWheel", sender: self)
		}
	}
	
	@objc func skip() {
		present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBarController"), animated: true, completion: nil)
	}
	
	func setAddedForView(_ tag: Int, name: String) {
		let view = addViews[tag]
		view.toggleAdded()
		if tag < addViews.count - 1 {
			addViews[tag + 1].isHidden = false
		}
		view.button.setTitle(name, for: .normal)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "quickAddToWheel" {
			if let tbc = segue.destination as? UITabBarController {
				if let nc = tbc.customizableViewControllers?.first as? UINavigationController {
					if let wvc = nc.viewControllers.first as? WheelViewController {
						wvc.temporaryResults = addViews.filter{ $0.isAdded() }.map{ $0.button.titleLabel!.text! }
						wvc.spinAtLoad = true
					}
				}
			}
		}
	}
}

extension QuickAddRestaurantViewController: QuickAddRestaurantViewDelegate {
	func buttonPressed(_ sender: Any) {
		if let s = sender as? UIButton {
			let view = addViews[s.tag]
			if !view.isAdded() {
				let storyboard = UIStoryboard(name: "Main", bundle: nil)
				let add = storyboard.instantiateViewController(withIdentifier: "quickAddDetails") as! QuickAddRestaurantDetailsViewController
				add.addIndex = s.tag
				navigationController?.pushViewController(add, animated: true)
			}
		}
	}
}
