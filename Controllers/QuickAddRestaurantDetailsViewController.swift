//
//  QuickAddRestaurantDetailsViewController
//  MealWheel
//
//  Created by benchmark on 11/29/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import UIKit

class QuickAddRestaurantDetailsViewController: UIViewController {
	@IBOutlet var nameField: UITextField!
	@IBOutlet var saveSwitch: UISwitch!
	
	var dataController: DataController = (UIApplication.shared.delegate as! AppDelegate).dataController
	var hasChanges: Bool = false
	var addIndex: Int = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		nameField.delegate = self
		
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		view.addGestureRecognizer(tap)
		
		let imageView = UIImageView()
		imageView.backgroundColor = UIColor.clear
		imageView.frame = CGRect(x: 0, y: 0, width: 2.5 * (navigationController?.navigationBar.bounds.height)!, height: (navigationController?.navigationBar.bounds.height)!)
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(back(sender:)))
		imageView.isUserInteractionEnabled = true
		imageView.addGestureRecognizer(tapGestureRecognizer)
		imageView.tag = 1
		navigationController?.navigationBar.addSubview(imageView)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		for view in (navigationController?.navigationBar.subviews)! {
			if view.tag == 1 {
				view.removeFromSuperview()
			}
		}
	}
	
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
	
	@objc @IBAction func back(sender: AnyObject) {
		if hasChanges {
			saveIfNeeded()
			if let count = navigationController?.viewControllers.count, count > 1 {
				if let quickAdd = navigationController?.viewControllers[count - 2] as? QuickAddRestaurantViewController {
					quickAdd.setAddedForView(addIndex, name: nameField.text!)
					dismiss()
				}
			}
		} else {
			dismiss()
		}
	}
	
	func dismiss() {
		navigationController?.popViewController(animated: true)
	}
	
	func saveIfNeeded() {
		if !saveSwitch.isOn { return }
		
		let r = UserRestaurant(context: dataController.viewContext)
		r.dateCreated = Date()
		r.name = nameField.text
		try? dataController.viewContext.save()
	}
}

extension QuickAddRestaurantDetailsViewController: UITextFieldDelegate {
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if string == "" && nameField.text == "" {
			hasChanges = false
		} else {
			hasChanges = true
		}
		return true
	}
	
	func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		return true
	}
}
