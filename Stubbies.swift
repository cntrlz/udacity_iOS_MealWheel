//
//  Stubbies.swift
//  MealWheel
//
//  Created by benchmark on 11/26/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import Foundation

// ========== [LandingViewController] ========== //
var overlay: UIVisualEffectView = UIVisualEffectView()
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

viewDidLoad {
	NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
	NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	
	searchTermField.delegate = self
	
	let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
	view.addGestureRecognizer(tap)
}

@objc func dismissKeyboard() {
	view.endEditing(true)
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

//	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//		super.touchesBegan(touches, with: event)
//		view.endEditing(true)
//	}

@objc func keyboardWillShow(notification: NSNotification) {
	var userInfo = notification.userInfo!
	var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
	keyboardFrame = view.convert(keyboardFrame, from: nil)
	
	var contentInset: UIEdgeInsets = scrollView.contentInset
	contentInset.bottom = keyboardFrame.size.height
	scrollView.contentOffset = CGPoint(x: 0, y: (view.frame.size.height - searchButton.frame.origin.y) - keyboardFrame.size.height)
}

@objc func keyboardWillHide(notification: NSNotification) {
	scrollView.contentOffset = .zero
}

extension LandingViewController: UITextFieldDelegate {
	func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		view.endEditing(true)
		return true
	}
}

// ========== [WheelViewController] ========== //
@IBOutlet weak var refreshButton: UIBarButtonItem!
//		{
//		didSet {
//			let refreshImage = UIImage.imageFromSystemBarButton(.refresh, renderingMode: .automatic)
//			let myButton = UIButton()
//			myButton.setImage(refreshImage, for: .normal)
//			myButton.addTarget(self, action: #selector(refresh), for: .touchUpInside)
//			refreshButton.customView = myButton
//		}
//	}
var results: [RestaurantsQuery.Data.Search.Business?] = []
//	{
//		didSet {
//			tableView.reloadData()
//			spinWheelControl.reloadData()
//		}
//	}
//	var lastOffset: CGPoint?
//	var lastOffsetCapture : TimeInterval?
//	var isScrollingFast : Bool?

//					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//						self.refreshControl.endRefreshing()
//					})
//					DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
//						self.refreshControl.attributedTitle = NSAttributedString(string: "Refresh")
//					})

//		let apollo = (UIApplication.shared.delegate as! AppDelegate).apollo
//
//		print("Calling query with term: ", term, "long and lat: ", lastLocation.coordinate.longitude, lastLocation.coordinate.latitude)
//
//		apollo.fetch(query: RestaurantsQuery(limit: 25, long: lastLocation.coordinate.longitude, lat: lastLocation.coordinate.latitude, cat: "restaurants", radius: 200), cachePolicy: .returnCacheDataElseFetch) { result, error in
//			print("Query complete")
//			if let error = error {
//				print("Error with RestaurantsQuery: \(error.localizedDescription)")
//				return
//			}
//
//			self.results = result?.data?.search?.business ?? []
//			self.cacheResults()
//		}
// MARK: - Location

//	func setUpLocationManager() {
//		locationManager.delegate = self
//		locationManager.desiredAccuracy = kCLLocationAccuracyBest
//		locationManager.requestWhenInUseAuthorization()
//		locationManager.startUpdatingLocation()
//	}
//
//	func updateLocation(_ location: CLLocation) {
//		//		print("updated location")
//		lastLocation = location
//	}
//
func animateRefreshButton() {
	UIView.animate(withDuration: 1.0, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: .curveLinear, animations: {
		if let b = self.navigationItem.rightBarButtonItem {
			print("buttan!")
			if let view = b.customView {
				print("vbiuu!")
				self.navigationItem.rightBarButtonItem?.customView?.transform = .identity
			}
		}
	}, completion: nil)
}
