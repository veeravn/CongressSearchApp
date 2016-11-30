//
//  BillListCell.swift
//  SlideMenuControllerSwift
//
//  Created by Veerav Naidu on 11/29/16.
//  Copyright © 2016 Yuji Hato. All rights reserved.
//

import UIKit

class BillListCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet var id: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var title: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
