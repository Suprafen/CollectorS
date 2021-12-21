//
//  CollectionTableViewController.swift
//  collector
//
//  Created by Ivan Pryhara on 13.12.21.
//

import UIKit
import RealmSwift


class CollectionTableViewController: UITableViewController {
    
    var items: [Item] = []
    let realm = RealmManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Uncomment line below to show Realm's location in the console.
//        print(realm.realm.configuration.fileURL)
        
        if !realm.getData().isEmpty{
            items = realm.getData()
        } else {
        }
        navigationItem.leftBarButtonItem = editButtonItem
    }

    //MARK: - Working with segues
    
    @IBAction func unwindToCollectionTableViewController(with segue: UIStoryboardSegue) {
        guard segue.identifier == "saveUnwind" else {
            if let indexPath = tableView.indexPathForSelectedRow {
                //Deselect row if cancel button was tapped.
                tableView.deselectRow(at: indexPath, animated: true)
            }
            return
        }
        
        if let addCollectionTableViewController = segue.source as? AddCollectionTableViewController,
           let item = addCollectionTableViewController.item {
                if let indexOfExistingItem = tableView.indexPathForSelectedRow {
                    realm.save(item)
                    items[indexOfExistingItem.row] = item
                    tableView.reloadRows(at: [indexOfExistingItem], with: .automatic)
                } else {
                    let newIndexPath = IndexPath(row: items.count, section: 0)
                    items.append(item)
                    realm.save(item)
                    tableView.insertRows(at: [newIndexPath], with: .automatic)
                }
        }
    }
    
    @IBSegueAction func addEditItem(_ coder: NSCoder, sender: Any?) -> AddCollectionTableViewController? {
        if  let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell) {
            let itemToEdit = items[indexPath.row]
            return AddCollectionTableViewController(coder: coder, item: itemToEdit)
        } else {
            return AddCollectionTableViewController(coder: coder, item: nil)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCellIdentifier", for: indexPath) as! CollectionTableViewCell
        let item = items[indexPath.row]

        //Configure cell with custom function in the CollectionTableViewCell class.
        cell.updateCell(with: item)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete particular row from the data source
            Item.deleteData(inDirectory: items[indexPath.row].imageDataDirectory!)
            realm.delete(item: items[indexPath.row])
            items.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
