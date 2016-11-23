//
//  LegCell.swift
//  Pods
//
//  Created by Veerav Naidu on 11/17/16.
//
//

import UIKit

class LegCell: UITableViewCell {

    @IBOutlet var legstate: UILabel!
    @IBOutlet var legname: UILabel!
    @IBOutlet var legimage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
