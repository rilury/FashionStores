//
//  FilterViewController.swift
//  FashionStores
//
//  Created by Iordan, Raluca on 02/12/2019.
//  Copyright © 2019 Iordan, Raluca. All rights reserved.
//

import UIKit

class FilterViewController: UITableViewController {
    
    @IBOutlet weak var economyLabel: UILabel!
    @IBOutlet weak var mediumLabel: UILabel!
    @IBOutlet weak var luxuryLabel: UILabel!

    
    // MARK: - Price section
    @IBOutlet weak var economyeCell: UITableViewCell!
    @IBOutlet weak var mediumCell: UITableViewCell!
    @IBOutlet weak var luxuryCell: UITableViewCell!
    
    // MARK: - Most popular section
    @IBOutlet weak var checkInsCell: UITableViewCell!
    @IBOutlet weak var proximityCell: UITableViewCell!
    @IBOutlet weak var highestPriceCell: UITableViewCell!
    
    // MARK: - Sort section
    @IBOutlet weak var nameAZSortCell: UITableViewCell!
    @IBOutlet weak var distanceSortCell: UITableViewCell!
    @IBOutlet weak var priceSortCell: UITableViewCell!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
    }
    
    
    @IBAction func search(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
       }
    
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.tintColor = .backgroundRose
        header.textLabel?.textColor = .lightGray
        header.textLabel?.font = UIFont(name: "Hirangino Mincho ProN", size: 18)
        header.textLabel?.frame = header.frame
        header.textLabel?.textAlignment = NSTextAlignment.left
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

