//
//  QuickAddRestaurantViewController.swift
//  MealWheel
//
//  Created by benchmark on 11/26/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import UIKit

class QuickAddRestaurantViewController: UIViewController {
	// We don't want to clutter the UI, so we'll limit the manual inputs to six
	@IBOutlet weak var add1: QuickAddRestaurantView!
	@IBOutlet weak var add2: QuickAddRestaurantView!
	@IBOutlet weak var add3: QuickAddRestaurantView!
	@IBOutlet weak var add4: QuickAddRestaurantView!
	@IBOutlet weak var add5: QuickAddRestaurantView!
	@IBOutlet weak var add6: QuickAddRestaurantView!
	
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
	
	override func viewWillAppear(_ animated: Bool) {
//		navigationController?.isNavigationBarHidden = true
	}
	
	@objc func skip(){
		present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBarController"), animated: true, completion: nil)
	}
}

extension QuickAddRestaurantViewController: QuickAddRestaurantViewDelegate {
	func buttonPressed(_ sender: Any) {
		if let s = sender as? UIButton {
			let view = addViews[s.tag]
			
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let add = storyboard.instantiateViewController(withIdentifier: "addCustomRestaurant")
			navigationController?.pushViewController(add, animated: true)
			
			
			
			view.toggleAdded()
			if s.tag < addViews.count - 1 {
				addViews[s.tag + 1].isHidden = false
			}
		}
	}
}
