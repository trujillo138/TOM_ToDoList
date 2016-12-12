//
//  ToDoList.swift
//  TOM_ToDoList
//
//  Created by TOM on 7/11/16.
//  Copyright © 2016 TOMApps. All rights reserved.
//

import Foundation

/** List of uncompleted ToDo tasks */
class ToDoList {
    
    /** Title of the list */
    var title: String?
    
    /** List of uncompleted ToDo tasks */
    var toDoTasks = [ToDo]()
    
    /** Creates a ToDo task with the given name and then adds it to the list collection */
    func addToDoWithName(_ name: String) {
        let toDo = ToDo()
        toDo.name = name
        toDoTasks.append(toDo)
    }
    
}
