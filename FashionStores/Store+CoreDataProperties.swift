//
//  Store+CoreDataProperties.swift
//  FashionStores
//
//  Created by Iordan, Raluca on 02/12/2019.
//  Copyright © 2019 Iordan, Raluca. All rights reserved.
//
//

import Foundation
import CoreData


extension Store {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Store> {
        return NSFetchRequest<Store>(entityName: "Store")
    }

    @NSManaged public var favourite: Bool
    @NSManaged public var name: String?
    @NSManaged public var phone: String?
    @NSManaged public var type: Type?
    @NSManaged public var checkin: Checkin?
    @NSManaged public var price: Price?
    @NSManaged public var location: Location?

}
