//
//  AppDelegate.swift
//  FashionStores
//
//  Created by Iordan, Raluca on 02/12/2019.
//  Copyright © 2019 Iordan, Raluca. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

class CoreDataStack {
    private let modelName: String

     init(modelName: String) {
       self.modelName = modelName
     }

     lazy var managedObjectContext: NSManagedObjectContext = {
       return self.storeContainer.viewContext
     }()

     private lazy var storeContainer: NSPersistentContainer = {
       let container = NSPersistentContainer(name: self.modelName)
       container.loadPersistentStores { (storeDescription, error) in
        if let error = error as NSError? {
            print(error.localizedDescription)
         }
       }
       return container
     }()

     func saveContext () {
       guard managedObjectContext.hasChanges else { return }

       do {
         try managedObjectContext.save()
       } catch let error as NSError {
        print(error.localizedDescription)
       }
     }
}

