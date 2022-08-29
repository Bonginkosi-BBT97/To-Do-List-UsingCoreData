//
//  ToDoListItem+CoreDataProperties.swift
//  To-Do-List-UsingCoreData
//
//  Created by Bonginkosi Tshabalala on 2022/08/23.
//
//

import Foundation
import CoreData

//This is an extentions of the above class
extension ToDoListItem {

    //fetch requests queries out all the items saved in the coredata
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoListItem> {
        return NSFetchRequest<ToDoListItem>(entityName: "ToDoListItem")
    }

    //properties saved in the core data
    @NSManaged public var name: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var isChecked: Bool
   //MARK: NSManaged
    /*
     - Anything you work with in coredata needs to be managed by NSManaged object
     - It is the link between the app and the data 
     */
}

extension ToDoListItem : Identifiable {

}
