//
//  ToDoViewController.swift
//  TOM_ToDoList
//
//  Created by TOM on 7/11/16.
//  Copyright © 2016 TOMApps. All rights reserved.
//

import UIKit

class ToDoViewController: UIViewController {

    //MARK: Outlets
    
    /** Label with the name of the ToDo task */
    @IBOutlet private weak var titleLabel: UILabel!
    
    /** Text view with the description of the ToDo task */
    @IBOutlet private weak var toDoDescriptionTV: UITextView!
    
    /** Button that marks the task as completed */
    @IBOutlet private weak var markAsCompletedButton: UIButton!
    
    //MARK: Properties
    
    /** ToDo task that will be displayed in this controller's view */
    var toDo: ToDo?
    
    //MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ToDo"
        markAsCompletedButton.isEnabled = toDo?.completed == false
        addDoneButton()
        guard let td = toDo else {
            return
        }
        titleLabel.text = td.name
        toDoDescriptionTV.text = td.todoDescription
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let toDoDesc = toDoDescriptionTV.text , toDoDesc != "" else {
            return
        }
        toDo?.todoDescription = toDoDesc
    }
    
    /** Adds a done button to the keyboard when editting the ToDo's description */
    private func addDoneButton() {
        let toolBar = UIToolbar(frame: CGRect(x: 0,y: 0,width: view.bounds.width, height: 40))
        toolBar.barStyle = .default
        toolBar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                         UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))]
        toDoDescriptionTV?.inputAccessoryView = toolBar
    }
    
    /** Makes the UITextView resign to being the first responder */
    func dismissKeyboard() {
        toDoDescriptionTV?.resignFirstResponder()
    }

    //MARK: Actions
    
    /** Removes the ToDo task from the list */
    @IBAction private func markToDoAsCompleted(_ sender: AnyObject) {
        toDo?.completed = true
        _ = self.navigationController?.popViewController(animated: true)
    }
    
}
