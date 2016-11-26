//
//  FavoriteController.swift
//  SlideMenuControllerSwift
//
//  Created by Veerav Naidu on 11/23/16.
//  Copyright © 2016 Yuji Hato. All rights reserved.
//

import UIKit

class FavoriteController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarItem()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
