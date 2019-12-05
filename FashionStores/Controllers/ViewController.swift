//
//  ViewController.swift
//  FashionStores
//
//  Created by Iordan, Raluca on 02/12/2019.
//  Copyright © 2019 Iordan, Raluca. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class ViewController: UIViewController {
    
    
    //MARK: Outlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var fashionStoresConstraint: NSLayoutConstraint!
    
    //MARK: Variables
    lazy var coreDataStack = CoreDataStack(modelName: "Stores")
    var fetchRequest:NSFetchRequest<Store>?
    var stores: [Store] = []
    var predicate: NSPredicate?
    var sortDescriptor: NSSortDescriptor?
    let locationManager = CLLocationManager()
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        tableView.tableFooterView = UIView()
        
        UIView.animate(withDuration: 1, animations: {
            let newConstraint = self.fashionStoresConstraint.constraintWithMultiplier(0.1)
            self.view.removeConstraint(self.fashionStoresConstraint)
            self.view.addConstraint(newConstraint)
            self.view.layoutIfNeeded()
            self.fashionStoresConstraint = newConstraint
        }, completion: nil)
        
        fetchJSONData()
        
        fetchRequest = Store.fetchRequest()
        fetchAndReloadData()
        
    }
    
    //MARK: Core Data Methods
    
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
    
    func fetchAndReloadData() {
        
        guard let fetchRequest = fetchRequest else {
            return
        }
        
        do {
            stores = try coreDataStack.managedObjectContext.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error as NSError {
            print(error.description)
        }
        
    }
    
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowFilterScreen", let filterVC = (segue.destination as? UINavigationController)?.topViewController as? FilterViewController else {
            return
        }
        
        filterVC.coreDataStack = coreDataStack
        filterVC.delegate = self
    }
    
}

extension ViewController: UITableViewDataSource {
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreCell", for: indexPath)
        let store = stores[indexPath.row]
        cell.textLabel?.text = store.name
        
        if predicate != nil && predicate!.description.contains("checkin") {
            cell.detailTextLabel?.text = "\(store.checkin?.count ?? 0)"
        } else if (predicate != nil && predicate!.description.contains("location")) || (sortDescriptor != nil && sortDescriptor!.description.contains("location")){
            cell.detailTextLabel?.text = "\(Int(store.location?.distance ?? 0.0))"
        } else {
            cell.detailTextLabel?.text = store.price?.priceRange
        }
        return cell
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    //MARK: LocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocation = manager.location else { return }
        
        for store in stores {
            let geocoder = CLGeocoder()
            if let address = store.location?.address, let city = store.location?.city, let country = store.location?.country {
                geocoder.geocodeAddressString("\(address) \(city) \(country)") {
                    placemarks, error in
                    let placemark = placemarks?.first
                    if let storeLocation = placemark?.location {
                        store.location?.distance = storeLocation.distance(from: locValue)
                        self.coreDataStack.saveContext()
                        
                    }
                }
            }
            
        }
    }
}

extension ViewController: FilterViewControllerDelegate {
    
    //MARK: FilterViewControllerDelegate
    func filterViewController(filter: FilterViewController, didSelectPredicate predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?) {
        guard let fetchRequest = fetchRequest else {
            return
        }
        fetchRequest.predicate = nil
        fetchRequest.sortDescriptors = nil
        fetchRequest.predicate = predicate
        if let sr = sortDescriptor {
            fetchRequest.sortDescriptors = [sr]
            self.sortDescriptor = sr
        }
        
        self.predicate = predicate
        
        fetchAndReloadData()
    }
}
