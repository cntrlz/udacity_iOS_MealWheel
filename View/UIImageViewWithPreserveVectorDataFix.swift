//
//  UIImageViewWithPreserveVectorDataFix.swift
//  MealWheel
//
//  Created by benchmark on 11/23/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import Foundation
import UIKit

// There's an XCode bug with vector scaling
// see https://stackoverflow.com/a/52552457/8346298

class UIImageViewWithPreserveVectorDataFix: UIImageView {
	override func awakeFromNib() {
		super.awakeFromNib()
		let image = self.image
		self.image = nil
		self.image = image
	}
}
