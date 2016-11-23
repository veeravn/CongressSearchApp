//
//  LeftViewController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 12/3/14.
//

import UIKit

enum LeftMenu: Int {
    case main = 0
    case leg
    case bill
    case com
    case fav
    case about
}

protocol LeftMenuProtocol : class {
    func changeViewController(_ menu: LeftMenu)
}

class LeftViewController : UIViewController, LeftMenuProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    var menus = ["Main", "Legislators", "Bills", "Committees", "Favorites", "About"]
    var mainViewController: UIViewController!
    var legTabController: UIViewController!
    var billTabController: UIViewController!
    var comViewController: UIViewController!
    var favViewController: UIViewController!
    var imageHeaderView: ImageHeaderView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1.0)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let legTabController = storyboard.instantiateViewController(withIdentifier: "legTabController") as! LegislatorController
        self.legTabController = UINavigationController(rootViewController: legTabController)
        
        let billTabController = storyboard.instantiateViewController(withIdentifier: "billTabController") as! BillController
        self.billTabController = UINavigationController(rootViewController: billTabController)
        
        let goViewController = storyboard.instantiateViewController(withIdentifier: "ComViewController") as! ComViewController
        self.comViewController = UINavigationController(rootViewController: goViewController)
        
        let favViewController = storyboard.instantiateViewController(withIdentifier: "FavViewController") as! FavViewController
        self.favViewController = UINavigationController(rootViewController: favViewController)
        
        self.tableView.registerCellClass(BaseTableViewCell.self)
        
        self.imageHeaderView = ImageHeaderView.loadNib()
        self.view.addSubview(self.imageHeaderView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.imageHeaderView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 160)
        self.view.layoutIfNeeded()
    }
    
    func changeViewController(_ menu: LeftMenu) {
        switch menu {
        case .main:
            self.slideMenuController()?.changeMainViewController(self.mainViewController, close: true)
        case .leg:
            self.slideMenuController()?.changeMainViewController(self.legTabController, close: true)
        case .bill:
            self.slideMenuController()?.changeMainViewController(self.billTabController, close: true)
        case .com:
            self.slideMenuController()?.changeMainViewController(self.comViewController, close: true)
        case .fav:
            self.slideMenuController()?.changeMainViewController(self.favViewController, close: true)
        case .about:
            self.slideMenuController()?.changeMainViewController(self.favViewController, close: true)
        }
    }
}

extension LeftViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let menu = LeftMenu(rawValue: indexPath.row) {
            switch menu {
            case .main, .leg, .bill, .com, .fav, .about:
                return BaseTableViewCell.height()
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let menu = LeftMenu(rawValue: indexPath.row) {
            self.changeViewController(menu)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.tableView == scrollView {
            
        }
    }
}

extension LeftViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let menu = LeftMenu(rawValue: indexPath.row) {
            switch menu {
            case .main, .leg, .bill, .com, .fav, .about:
                let cell = BaseTableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: BaseTableViewCell.identifier)
                cell.setData(menus[indexPath.row])
                return cell
            }
        }
        return UITableViewCell()
    }
    
    
}
