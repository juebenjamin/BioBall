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
    @IBAction func settingsButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Settings coming soon!", message: "\n Change Colors\n\n Change Speed\n\n Change Size\n\n Rate/Write Review\n\n Version Viewer", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    @IBOutlet var settingsButton: UIBarButtonItem!
    var dataArray = [NSManagedObject]()
    let label = UILabel()
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let isEmpty = dataArray.isEmpty
        label.isHidden = !isEmpty
        return isEmpty ? 0 : dataArray.count
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
        if segue.identifier == "toLeft" {
            if let PlayViewController = segue.destination as? PlayViewController {
                    PlayViewController.pageControl = pageControl
                }
        }
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
        // Update the page control's current page
        pageControl.currentPage = 1
        // deselect the selected row if any
        let selectedRow: IndexPath? = tableView.indexPathForSelectedRow
        if let selectedRowNotNill = selectedRow {
            tableView.deselectRow(at: selectedRowNotNill, animated: true)
        }
    }
    @IBOutlet var tableView: UITableView!
    let pageControl = UIPageControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        pageControl.numberOfPages = 2 // Set the number of pages to 2
        pageControl.currentPage = 1 // Set the current page to 1 (The second page)
        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
        navigationController?.navigationBar.tintColor =  UIColor(red: 197/255, green: 0/255, blue: 197/255, alpha: 1)
        // Add a label to the view that will be shown when the data array is empty
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Press the Add button to create a ball!"
        label.textAlignment = .center
        print(dataArray.count)
        label.isHidden = dataArray.count > 0
        view.addSubview(label)

        // Add constraints to center the label vertically and horizontally
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
//        tableView.backgroundView = label
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
            if pageControl.currentPage > 0 {
                        pageControl.currentPage -= 1
                    }
            performSegue(withIdentifier: "toLeft", sender: self)
        }
    }
    @objc func pageControlTapped(_ sender: UIPageControl) {
        // Update the current page of the page control to the tapped page
        pageControl.currentPage = sender.currentPage
        // Segue to the other screen in the indicator
        performSegue(withIdentifier: "toLeft", sender: self)
    }
}
