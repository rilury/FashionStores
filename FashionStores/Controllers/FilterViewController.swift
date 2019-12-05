//
//  FilterViewController.swift
//  FashionStores
//
//  Created by Iordan, Raluca on 02/12/2019.
//  Copyright © 2019 Iordan, Raluca. All rights reserved.
//

import UIKit
import CoreData

enum PriceRange: String, CaseIterable {
    case economy = "Economy"
    case medium = "Medium"
    case luxury = "Luxury"
}

protocol FilterViewControllerDelegate: class {
    func filterViewController(filter: FilterViewController, didSelectPredicate predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?)
}

class FilterViewController: UITableViewController {
    
    //MARK: Variables
    var priceRange: PriceRange = .economy
    var coreDataStack: CoreDataStack!
    weak var delegate: FilterViewControllerDelegate?
    var selectedSortDescriptor: NSSortDescriptor?
    var selectedPredicate: NSPredicate?
    lazy var checkInsPredicate: NSPredicate = {
        return NSPredicate(format: "%K > 0", #keyPath(Store.checkin.count))
    }()
    let locationPredicate: NSPredicate = {
        return NSPredicate(format: "%K < 10000", #keyPath(Store.location.distance))
    }()

    lazy var nameSortDescriptor: NSSortDescriptor = {
        let compareSelector =
            #selector(NSString.localizedStandardCompare(_:))
        return NSSortDescriptor(key: #keyPath(Store.name),
                                ascending: true,
                                selector: compareSelector)
    }()
    lazy var distanceSortDescriptor: NSSortDescriptor = {
        return NSSortDescriptor(
            key: #keyPath(Store.location.distance),
            ascending: true)
    }()
    lazy var priceSortDescriptor: NSSortDescriptor = {
        return NSSortDescriptor(
            key: #keyPath(Store.price.priceRange),
            ascending: true)
    }()
    
    //MARK: Outlets
    @IBOutlet weak var economyLabel: UILabel!
    @IBOutlet weak var mediumLabel: UILabel!
    @IBOutlet weak var luxuryLabel: UILabel!

    @IBOutlet weak var economyeCell: UITableViewCell!
    @IBOutlet weak var mediumCell: UITableViewCell!
    @IBOutlet weak var luxuryCell: UITableViewCell!

    @IBOutlet weak var checkInsCell: UITableViewCell!
    @IBOutlet weak var proximityCell: UITableViewCell!
    @IBOutlet weak var highestPriceCell: UITableViewCell!
    
    @IBOutlet weak var nameAZSortCell: UITableViewCell!
    @IBOutlet weak var distanceSortCell: UITableViewCell!
    @IBOutlet weak var priceSortCell: UITableViewCell!
    
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        setupPriceLabels()
        setupTotalCheckIns()
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }

    //MARK: Helpers
    func setupPriceLabels() {
        
        for element in PriceRange.allCases {
            priceRange = element
            let storePredicate = NSPredicate(format: "%K = %@", #keyPath(Store.price.priceRange), priceRange.rawValue)
            let fetchRequest =
                NSFetchRequest<NSNumber>(entityName: "Store")
            fetchRequest.resultType = .countResultType
            fetchRequest.predicate = storePredicate
            do {
                let count =
                    try coreDataStack.managedObjectContext.count(for:fetchRequest)
                let pluralized = count == 1 ? "store" : "stores"
                if element == .economy {
                    economyLabel.text = "\(count) fashion \(pluralized)"
                } else if element == .medium {
                    mediumLabel.text = "\(count) fashion \(pluralized)"
                } else {
                    luxuryLabel.text = "\(count) fashion \(pluralized)"
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func setupTotalCheckIns() {
        
        let fetchRequest =
            NSFetchRequest<NSDictionary>(entityName: "Checkin")
        fetchRequest.resultType = .dictionaryResultType
        let sumExpressionDesc = NSExpressionDescription()
        sumExpressionDesc.name = "sumCheckIns"
        
        let sumCheckIns = NSExpression(forKeyPath: #keyPath(Checkin.count))
        sumExpressionDesc.expression = NSExpression(forFunction: "sum:", arguments: [sumCheckIns])
        sumExpressionDesc.expressionResultType = .integer32AttributeType
        
        fetchRequest.propertiesToFetch = [sumExpressionDesc]
        do {
            let results = try coreDataStack.managedObjectContext.fetch(fetchRequest)
            let resultDict = results.first!
            let numberOfCheckIns = resultDict["sumCheckIns"] as! Int
            checkInsCell.textLabel?.text = "Total CheckIns: \(numberOfCheckIns)"
            
        } catch let error as NSError {
            print(error.description)
        }
        
    }
    
    //MARK: Actions
    @IBAction func search(_ sender: UIBarButtonItem) {
        delegate?.filterViewController(filter: self, didSelectPredicate: selectedPredicate, sortDescriptor: selectedSortDescriptor)
        dismiss(animated: true)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
       }
    
    
    //MARK: TableView
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.tintColor = .backgroundRose
        header.textLabel?.textColor = .lightGray
        header.textLabel?.font = UIFont(name: "Hirangino Mincho ProN", size: 18)
        header.textLabel?.frame = header.frame
        header.textLabel?.textAlignment = NSTextAlignment.left
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }  

        cell.contentView.backgroundColor = UIColor.lightGray
        
        switch cell {
        case economyeCell:
            priceRange = .economy
            selectedPredicate = NSPredicate(format: "%K = %@", #keyPath(Store.price.priceRange), priceRange.rawValue)
        case mediumCell:
            priceRange = .medium
            selectedPredicate = NSPredicate(format: "%K = %@", #keyPath(Store.price.priceRange), priceRange.rawValue)
        case luxuryCell, highestPriceCell:
            priceRange = .luxury
            selectedPredicate = NSPredicate(format: "%K = %@", #keyPath(Store.price.priceRange), priceRange.rawValue)
        case checkInsCell:
            selectedPredicate = checkInsPredicate
        case proximityCell:
            self.selectedPredicate = locationPredicate
        case nameAZSortCell:
            selectedSortDescriptor = nameSortDescriptor
        case distanceSortCell:
            selectedSortDescriptor = distanceSortDescriptor
        case priceSortCell:
            selectedSortDescriptor = priceSortDescriptor
        default: break
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        cell.contentView.backgroundColor = UIColor.backgroundRose
    }
    
    
}

