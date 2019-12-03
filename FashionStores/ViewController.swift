//
//  ViewController.swift
//  FashionStores
//
//  Created by Iordan, Raluca on 02/12/2019.
//  Copyright © 2019 Iordan, Raluca. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var fashionStoresConstraint: NSLayoutConstraint!
    
    lazy var coreDataStack = CoreDataStack(modelName: "Stores")
    var fetchRequest:NSFetchRequest<Store>?
    var stores: [Store] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.animate(withDuration: 1, animations: {
            let newConstraint = self.fashionStoresConstraint.constraintWithMultiplier(0.1)
            self.view.removeConstraint(self.fashionStoresConstraint)
            self.view.addConstraint(newConstraint)
            self.view.layoutIfNeeded()
            self.fashionStoresConstraint = newConstraint
        }, completion: nil)
        
   
        fetchJSONData()
        
        guard let model = coreDataStack.managedObjectContext.persistentStoreCoordinator?.managedObjectModel, let fetchRequest = model.fetchRequestTemplate(forName: "StoresFetchRequest") as? NSFetchRequest<Store> else {
            return
        }
        
        self.fetchRequest = fetchRequest
        do {
            stores =
                try coreDataStack.managedObjectContext.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
    func fetchJSONData() {
        
        let fetchRequest = NSFetchRequest<Store>(entityName: "Store")
        
        guard try! coreDataStack.managedObjectContext.count(for: fetchRequest) == 0 else {return}
        
        do {
            let results = try coreDataStack.managedObjectContext.fetch(fetchRequest)
            results.forEach {
                coreDataStack.managedObjectContext.delete($0)
            }
            
            coreDataStack.saveContext()
            
            saveToCoreData()
        } catch let error as NSError {
            print(error.description)
        }
        
    }
    
    func saveToCoreData() {
        
        let jsonData = try! Data(contentsOf: Bundle.main.url(forResource: "stores", withExtension: "json")!)
        
        let jsonDictionary = try! JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments]) as! [String: Any]
        let responseDictionary = jsonDictionary["response"] as! [String: Any]
        let jsonArray = responseDictionary["stores"] as! [[String: Any]]
        
        for element in jsonArray {
            let storeName = element["name"] as? String
            let contactDictionary = element["contact"] as? [String: String]
            
            let storePhone = contactDictionary?["formattedPhone"]

            let locationDictionary = element["location"] as? [String: Any]
            let priceDictionary = element["price"] as? [String: Any]
            let statsDictionary =  element["stats"] as? [String: Any]
            
            let location = Location(context: coreDataStack.managedObjectContext)
            location.address = locationDictionary?["address"] as? String
            location.city = locationDictionary?["city"] as? String
            location.country = locationDictionary?["country"] as? String
            location.zipCode = locationDictionary?["postalCode"] as? String
           
            
            let type = Type(context: coreDataStack.managedObjectContext)
            
            let price = Price(context: coreDataStack.managedObjectContext)
            price.priceRange = priceDictionary?["message"] as? String
            
            let checkin = Checkin(context: coreDataStack.managedObjectContext)
            let checkins = statsDictionary?["checkinsCount"] as? NSNumber
            checkin.count = checkins!.int32Value
           
            let store = Store(context: coreDataStack.managedObjectContext)
            store.name = storeName
            store.phone = storePhone
            store.location = location
            store.type = type
            store.price = price
            store.checkin = checkin
        }
        
        coreDataStack.saveContext()
    }
    
    
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return stores.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "StoreCell", for: indexPath)
    let store = stores[indexPath.row]
    cell.textLabel?.text = store.name
    cell.detailTextLabel?.text = store.price?.priceRange
    return cell
  }
}

