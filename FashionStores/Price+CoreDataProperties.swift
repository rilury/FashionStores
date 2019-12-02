//
//  Price+CoreDataProperties.swift
//  FashionStores
//
//  Created by Iordan, Raluca on 02/12/2019.
//  Copyright © 2019 Iordan, Raluca. All rights reserved.
//
//

import Foundation
import CoreData


extension Price {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Price> {
        return NSFetchRequest<Price>(entityName: "Price")
    }

    @NSManaged public var priceRange: String?
    @NSManaged public var store: Store?

}
