//
//  Task+CoreDataProperties.swift
//  ToDoList
//
//  Created by Mikhail Chuparnov on 24.07.2022.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var title: String?
    @NSManaged public var isDone: Bool

}

extension Task : Identifiable {

}
