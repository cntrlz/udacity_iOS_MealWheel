//
//  SettingsTableViewCell.swift
//  MealWheel
//
//  Created by benchmark on 11/20/18.
//  Copyright © 2018 Viktor Lantos. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var info: UIButton!
	@IBOutlet weak var `switch`: UISwitch!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
