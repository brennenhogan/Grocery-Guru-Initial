//
//  ListTableViewController.swift
//  Grocery Guru
//
//  Created by Brennen Hogan on 3/14/21.
//

import UIKit
import CoreData

class ListTableViewController: UITableViewController {
    
    // MARK: Properties
    
    var resultsController: NSFetchedResultsController<List>!
    let coreDataStack = CoreDataStack()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Request
        let request: NSFetchRequest<List> = List.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "title", ascending: true)
        
        // Init
        request.sortDescriptors = [sortDescriptors]
        resultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataStack.managedContex,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        resultsController.delegate = self
        
        // Fetch
        do {
            try resultsController.performFetch()
        } catch {
            print("Perform fetch error: \(error)")
        }

    }
    
    //MARK: Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController.sections?[section].numberOfObjects ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)

        // Configure the cell...
        let list = resultsController.object(at: indexPath)
        cell.textLabel?.text = list.title
        
        return cell
    }
    
    // MARK: Table view delegate
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            let list = self.resultsController.object(at: indexPath)
            self.resultsController.managedObjectContext.delete(list)
            do {
                try self.resultsController.managedObjectContext.save()
                completion(true)
            } catch {
                print("delete failed: \(error)")
                completion(false)
            }
        }
        //action.image = trash
        action.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Check") { (action, view, completion) in
            let list = self.resultsController.object(at: indexPath)
            self.resultsController.managedObjectContext.delete(list)
            do {
                try self.resultsController.managedObjectContext.save()
                completion(true)
            } catch {
                print("complete failed: \(error)")
                completion(false)
            }
        }
        //action.image = COPYFILE_CHECK
        action.backgroundColor = .green
        return UISwipeActionsConfiguration(actions: [action])
    }

    // Loads the add menu when clicking on a list
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowAddList", sender: tableView.cellForRow(at: indexPath))
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = sender as? UIBarButtonItem, let vc = segue.destination as? AddListViewController {
            vc.managedContext = resultsController.managedObjectContext
        }
        
        // Loads the add menu when clicking on a list
        if let cell = sender as? UITableViewCell, let vc = segue.destination as? AddListViewController {
            vc.managedContext = resultsController.managedObjectContext
            if let indexPath = tableView.indexPath(for: cell){
                let list = resultsController.object(at: indexPath)
                vc.list = list
            }
        }
    }
    

}

extension ListTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath{
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                let list = resultsController.object(at: indexPath)
                cell.textLabel?.text = list.title
            }
        default:
            break
        }
    }
}

