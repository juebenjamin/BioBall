//
//  ListViewController.swift
//  BioBall
//
//  Created by Jeremiah Benjamin on 12/11/22.
//  Copyright © 2022 Jeremiah Benjamin. All rights reserved.
//
//FIXME: Slow first segue.
import UIKit
import CoreData
class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    var dataArray = [NSManagedObject]() 
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          if dataArray.isEmpty {
              // If the data array is empty, show the label and return 0 rows
              tableView.backgroundView?.isHidden = false
              return 0
          } else {
              // If the data array is not empty, hide the label and return the number of rows
              tableView.backgroundView?.isHidden = true
              return dataArray.count
          }
      }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! BallTableViewCell
        cell.backgroundColor = UIColor.white
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 197/255, green: 0/255, blue: 197/255, alpha: 1)
        cell.selectedBackgroundView = backgroundView
        let data = dataArray[indexPath.row]
        cell.ballLabel.text = data.value(forKey: "titles") as? String
        let uploadedImg = data.value(forKey: "images") as? Data
        let img = UIImage(data: uploadedImg!)
        cell.ballimgView.image = img
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // show alert to confirm delete
            let alert = UIAlertController(title: "Delete Ball", message: "Are you sure you want to delete this ball?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                // handle delete (by removing the data from your array and updating the tableview)
                let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                managedObjectContext.delete(self.dataArray[indexPath.row] as NSManagedObject)
                do {
                    try managedObjectContext.save()
                } catch {
                    print("Failed to save")
                }
                self.dataArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            alert.addAction(cancelAction)
            alert.addAction(deleteAction)
            present(alert, animated: true, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let managedObject = dataArray[indexPath.row]
        performSegue(withIdentifier: "startEdit", sender: managedObject)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newBall" {
            if dataArray.count >= 10 {
                let alert = UIAlertController(title: "Cannot Add New Ball", message: "Only 10 or less balls are currently supported.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
            }
        }
        if segue.identifier == "startEdit" {
            if let destinationViewController = segue.destination as? NewBallViewController {
                destinationViewController.managedObject = sender as? NSManagedObject
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // deselect the selected row if any
        let selectedRow: IndexPath? = tableView.indexPathForSelectedRow
        if let selectedRowNotNill = selectedRow {
            tableView.deselectRow(at: selectedRowNotNill, animated: true)
        }
    }
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor =  UIColor(red: 197/255, green: 0/255, blue: 197/255, alpha: 1)
        let label = UILabel()
        label.text = "Press the Add button to create a ball!"
        label.textAlignment = .center
        label.isHidden = true
        tableView.backgroundView = label
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Balls")
                do {
                    dataArray = try managedObjectContext.fetch(fetchRequest)
                } catch {
                    print("Error fetching data from Core Data: \(error)")
                }
        title = "Balls"
        // Perform transition to playing screen when swiped right
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeFunc(gesture:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // Function for swipe right to playing screen
    @objc func swipeFunc(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .right {
            performSegue(withIdentifier: "toLeft", sender: self)
        }
    }
    
}
