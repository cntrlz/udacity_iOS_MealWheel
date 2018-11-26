//
//  LandingViewController.swift
//  MealWheel
//
//  Created by benchmark on 11/16/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import UIKit

// TODO: Check wireless connectivity
// TODO: Ask for all relevant permissions
class LandingViewController: UIViewController {
	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var searchButton: UIButton!
	@IBOutlet var searchTermField: UITextField!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	var results: [RestaurantsQuery.Data.Search.Business?] = []
	@IBOutlet weak var exploreButton: UIButton!
	@IBOutlet weak var customizeButton: UIButton!
	@IBOutlet weak var activityView: UIView!
	var overlay: UIVisualEffectView = UIVisualEffectView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

		searchTermField.delegate = self

		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		view.addGestureRecognizer(tap)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		activityView.isHidden = true
	}

	@IBAction func skipLanding(_ sender: Any) {
		self.performSegue(withIdentifier: "landingToTabBar", sender: nil)
	}
	
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
	
	func toggleBlur() {
		if overlay.isDescendant(of: view) {
			activityView.isHidden = true
//			overlay.effect = nil
//			overlay.removeFromSuperview()
		} else {
			activityView.isHidden = false
//			overlay.frame = view.frame
//			view.addSubview(overlay)
//			UIView.animate(withDuration: 0.5) {
//				self.overlay.effect = UIBlurEffect(style: .light)
//			}
		}
	}

//	override func viewWillAppear(_ animated: Bool) {
//		super.viewWillAppear(animated)
//		registerNotifications()
//	}
//
//	override func viewWillDisappear(_ animated: Bool) {
//		super.viewWillDisappear(animated)
//		unregisterNotifications()
//	}
//
//	private func registerNotifications() {
//		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//	}
//
//	private func unregisterNotifications() {
//		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//	}
//
//	@objc func keyboardWillShow(notification: NSNotification){
//		guard let keyboardFrame = notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
//		scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
//	}
//
//	@objc func keyboardWillHide(notification: NSNotification){
//		scrollView.contentInset.bottom = 0
//	}

	@IBAction func performSearch(_ sender: Any) {
		activityIndicator.startAnimating()
		exploreButton.isEnabled = false
		customizeButton.isEnabled = false
		(UIApplication.shared.delegate as! AppDelegate).apiClient.returnFetchWithTerm(term: searchTermField.text ?? "", completion: { results, error in
			if error != nil {
				let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
				self.present(alert, animated: true)
			}
			if results != nil {
				self.results = results!
				self.performSegue(withIdentifier: "landingToTabBar", sender: nil)
			} else {
				let alert = UIAlertController(title: "Error", message: "Your search sucks", preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "sad face", style: UIAlertActionStyle.default, handler: nil))
				self.present(alert, animated: true)
			}
			self.exploreButton.isEnabled = true
			self.customizeButton.isEnabled = true
			self.activityIndicator.stopAnimating()
		})
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		view.endEditing(true)
	}

	@objc func keyboardWillShow(notification: NSNotification) {
		var userInfo = notification.userInfo!
		var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
		keyboardFrame = view.convert(keyboardFrame, from: nil)

		var contentInset: UIEdgeInsets = scrollView.contentInset
		contentInset.bottom = keyboardFrame.size.height
		scrollView.contentOffset = CGPoint(x: 0, y: (view.frame.size.height - searchButton.frame.origin.y) - keyboardFrame.size.height)
	}

	@objc func keyboardWillHide(notification: NSNotification) {
//		let contentInset: UIEdgeInsets = UIEdgeInsets.zero
		scrollView.contentOffset = .zero
	}

	// MARK: - Navigation

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "landingToTabBar" && results.count > 0 {
			if let tabBar = segue.destination as? UITabBarController {
				if let nav = tabBar.customizableViewControllers?.first as? UINavigationController {
					if let wvc = nav.viewControllers.first as? WheelViewController {
						wvc.results = results
					}
				}
			}
		}
	}
}

extension LandingViewController: UITextFieldDelegate {
	func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		return true
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool { // called when 'return' key pressed. return NO to ignore.
		view.endEditing(true)
		return true
	}
}
