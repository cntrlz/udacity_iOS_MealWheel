//
//  QuickAddRestaurantView.swift
//  MealWheel
//
//  Created by benchmark on 11/26/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import Foundation
import UIKit

// TODO: Fix Xcode perma-build bug with nib (file owner vs. file class type)
// QuickAddRestaurantView
@IBDesignable class QuickAddRestaurantView: UIView, NibLoadable {
	@IBOutlet weak var button: UIButton!
	@IBOutlet weak var imageView: UIImageViewWithPreserveVectorDataFix!
	@IBOutlet weak var backgroundView: UIView!
	
	private var added: Bool = false
	
	var delegate: QuickAddRestaurantViewDelegate?
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupFromNib()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupFromNib()
	}
	
	@IBAction func buttonPressed(_ sender: Any) {
		delegate?.buttonPressed(sender)
	}
	
	func isAdded() -> Bool {
		return added
	}
	
	func toggleAdded(){
		if (added){
			imageView.image = UIImage(named: "restaurantIconVector")
			backgroundView.backgroundColor = UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1)
			button.setTitle("ADD", for: .normal)
			setNeedsLayout()
		} else {
			imageView.image = UIImage(named: "checkIconVector")
			backgroundView.backgroundColor = UIColor(red: 59/255.0, green: 181/255.0, blue: 23/255.0, alpha: 1)
			button.setTitle("ADDED", for: .normal)
			setNeedsLayout()
		}
		added = !added
	}
}

protocol QuickAddRestaurantViewDelegate {
	func buttonPressed(_ sender: Any)
}


// See: https://stackoverflow.com/questions/9282365/load-view-from-an-external-xib-file-in-storyboard
public protocol NibLoadable {
	static var nibName: String { get }
}

public extension NibLoadable where Self: UIView {
	
	public static var nibName: String {
		return String(describing: Self.self) // defaults to the name of the class implementing this protocol.
	}
	
	public static var nib: UINib {
		let bundle = Bundle(for: Self.self)
		return UINib(nibName: Self.nibName, bundle: bundle)
	}
	
	func setupFromNib() {
		guard let view = Self.nib.instantiate(withOwner: self, options: nil).first as? UIView else { fatalError("Error loading \(self) from nib") }
		addSubview(view)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
		view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
		view.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
		view.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
	}
}
