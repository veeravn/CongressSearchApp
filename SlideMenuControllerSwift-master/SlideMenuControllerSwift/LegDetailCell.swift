//
//  LegDetailCell.swift
//  CongressSearchApp
//
//  Created by Veerav Naidu on 11/17/16.
//  Copyright © 2016 Veerav Naidu. All rights reserved.
//

import UIKit

class LegDetailCell: UITableViewCell {

    @IBOutlet var hyperLink: UIButton!
    @IBOutlet var detail: UILabel!
    @IBOutlet var title: UILabel!
    var website : URL! = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBAction func openLinks(_ sender: UIButton) {
        if sender.titleLabel?.text == "Twitter Link"{
           sender.titleLabel?.text = "Twitter Link"
        } else if sender.titleLabel?.text == "Facebook Link" {
            sender.titleLabel?.text = "Facebook Link"
        } else {
            sender.titleLabel?.text = "Website Link"
        }
        if hyperLink != nil {
            UIApplication.shared.openURL(website)
        }

    }


}
