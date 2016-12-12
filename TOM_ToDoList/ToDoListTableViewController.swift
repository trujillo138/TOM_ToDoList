//
//  ToDoListTableViewController.swift
//  TOM_ToDoList
//
//  Created by TOM on 7/11/16.
//  Copyright © 2016 TOMApps. All rights reserved.
//

import UIKit

class ToDoListTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {

    //MARK: Properties
    
    /** List containing the user's tasks */
    private var list = ToDoList()
    
    /** Tasks that have not been completed */
    private var pendingToDos: [ToDo] {
        return list.toDoTasks.filter { !$0.completed }
    }
    
    /** Tasks that have not been completed */
    private var completedToDos: [ToDo] {
        return list.toDoTasks.filter { $0.completed }
    }
    
    /** Tasks that have whose name applies to the text being searched */
    private var filteredToDos = [ToDo]()
    
    /** Search controller that will handle the filtering of ToDos in the list */
    private let searchController = UISearchController(searchResultsController: nil)
    
    /** Contains all of this controllers constants */
    private struct ToDoListConstants {
        /** Identifier of the UITableViewCell that displays a ToDo title in a table */
        static let ToDoCellIdentifier = "ToDoCell"
        /** Segue identifier that takes to the UIViewController that displays the ToDo detail */
        static let ToDoCellDetailSegue = "ShowToDoDetail"
        /** Number of the section in the table that contains the pending tasks */
        static let PendingToDosSection = 0
        /** Number of the section in the table that contains the completed tasks */
        static let CompletedToDosSection = 1
        /** Title of the scope in the search bar that indicates that all of the ToDo tasks are being searched */
        static let AllScopeTitle = "All"
        /** Title of the scope in the search bar that indicates that only the pending ToDo tasks are being searched */
        static let PendingScopeTitle = "Pending"
        /** Title of the scope in the search bar that indicates that only the completed ToDo tasks are being searched */
        static let CompletedScopeTitle = "Completed"
    }
    
    //MARK: ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ToDo List"
        initializeModel()
        createSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    //MARK: Initialization
    
    /** Creates a mock of the model */
    private func initializeModel() {
        list.addToDoWithName("Do the laundry")
        list.addToDoWithName("Take out the trash")
        list.addToDoWithName("Clean the dishes")
    }
    
    //MARK: Actions
    
    /** Displays an alert that adds a ToDo task to the list */
    @IBAction private func addToDo(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Add Task", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addTextField { textField in
            textField.placeholder = "New task name"
        }
        alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { [unowned self] _ in
            guard let name  = alertController.textFields?.first?.text else {
                return
            }
            self.list.addToDoWithName(name)
            self.tableView.reloadData()
        }))
        present(alertController, animated: true, completion: nil)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive {
            return 1
        }
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive {
            return searchController.searchBar.text
        } else{
            return section == ToDoListConstants.PendingToDosSection ? "Pending" : "Completed"
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return filteredToDos.count
        } else {
            return section == ToDoListConstants.PendingToDosSection ? pendingToDos.count : completedToDos.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ToDoListConstants.ToDoCellIdentifier, for: indexPath)
        var todo: ToDo?
        if searchController.isActive {
            todo = filteredToDos[indexPath.row]
            cell.detailTextLabel?.text = todo!.completed ? ToDoListConstants.CompletedScopeTitle : ToDoListConstants.PendingScopeTitle
        } else {
            todo = indexPath.section == ToDoListConstants.PendingToDosSection ? pendingToDos[(indexPath as NSIndexPath).row] : completedToDos[indexPath.row]
            cell.detailTextLabel?.text = ""
        }
        cell.textLabel?.text = todo?.name

        return cell
    }
    
    // MARK: - Search Controller
    
    /** Creates a standrad search results controller with this controller as the Updater */
    private func createSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = [ToDoListConstants.AllScopeTitle, ToDoListConstants.PendingScopeTitle,
                                                        ToDoListConstants.CompletedScopeTitle]
        searchController.searchBar.delegate = self
        self.tableView.tableHeaderView = searchController.searchBar
    }
    
    /** Filters the ToDo List based on the searched text */
    private func filterToDos(searchText: String, scope: String = ToDoListConstants.AllScopeTitle) {
        let filter: (ToDo) -> Bool = { toDo in
            guard let toDoName = toDo.name else {
                return false
            }
            return toDoName.localizedCaseInsensitiveContains(searchText)
        }
        if scope == ToDoListConstants.AllScopeTitle {
            filteredToDos = list.toDoTasks.filter(filter)
        } else if scope == ToDoListConstants.PendingScopeTitle {
            filteredToDos = pendingToDos.filter(filter)
        } else {
            filteredToDos = completedToDos.filter(filter)
        }
        tableView.reloadData()
    }
    
    // MARK: - Search Results Updating
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchbar = searchController.searchBar
        filterToDos(searchText: searchController.searchBar.text ?? "", scope: searchbar.scopeButtonTitles![searchbar.selectedScopeButtonIndex])
    }
    
    //MARK: - Search Bar Delegate
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterToDos(searchText: searchBar.text ?? "", scope: searchBar.scopeButtonTitles![selectedScope])
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueIdentifier = segue.identifier else {
            return
        }
        switch (segueIdentifier) {
        case ToDoListConstants.ToDoCellDetailSegue:
            if let toDoDetailVC = segue.destination as? ToDoViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell) {
                if searchController.isActive {
                    toDoDetailVC.toDo = filteredToDos[indexPath.row]
                } else {
                    toDoDetailVC.toDo = indexPath.section == ToDoListConstants.PendingToDosSection ? pendingToDos[indexPath.row] : completedToDos[indexPath.row]
                }
            }
        default:
            print("Nothing to do yet")
        }
    }

}
