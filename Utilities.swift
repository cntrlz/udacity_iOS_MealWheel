//
//  Utilities.swift
//  MealWheel
//
//  Created by benchmark on 11/26/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
	class func randomColor(randomAlpha randomApha: Bool = false) -> UIColor {
		let redValue = CGFloat(arc4random_uniform(255)) / 255.0
		let greenValue = CGFloat(arc4random_uniform(255)) / 255.0
		let blueValue = CGFloat(arc4random_uniform(255)) / 255.0
		let alphaValue = randomApha ? CGFloat(arc4random_uniform(255)) / 255.0 : 1
		
		return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: alphaValue)
	}
}

// https://gist.github.com/viccalexander/0224ab078f76a3af6d79986369d5240b
extension String {
	/**
	 Truncates the string to the specified length number of characters and appends an optional trailing string if longer.
	
	 - Parameter length: A `String`.
	 - Parameter trailing: A `String` that will be appended after the truncation.
	
	 - Returns: A `String` object.
	 */
	func truncate(length: Int, trailing: String = "…") -> String {
		if self.count > length {
			return String(self.prefix(length)) + trailing
		} else {
			return self
		}
	}
}

// https://stackoverflow.com/questions/21187885/use-uibarbuttonitem-icon-in-uibutton
extension UIImage {
	class func imageFromSystemBarButton(_ systemItem: UIBarButtonSystemItem, renderingMode: UIImageRenderingMode = .automatic) -> UIImage {
		let tempItem = UIBarButtonItem(barButtonSystemItem: systemItem, target: nil, action: nil)
		
		let bar = UIToolbar()
		bar.setItems([tempItem], animated: false)
		bar.snapshotView(afterScreenUpdates: true)
		
		let itemView = tempItem.value(forKey: "view") as! UIView
		
		for view in itemView.subviews {
			if view is UIButton {
				let button = view as! UIButton
				let image = button.imageView!.image!
				image.withRenderingMode(renderingMode)
				return image
			}
		}
		
		return UIImage()
	}
}
