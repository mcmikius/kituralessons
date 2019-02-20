//
//  DishesTableViewController.swift
//  NadiasGarden
//
//  Created by Michail Bondarenko on 2/20/19.
//  Copyright © 2019 Michail Bondarenko. All rights reserved.
//

import Foundation
import UIKit

typealias JSONDictionary = [String:Any]

class DishesTableViewController : UITableViewController, AddNewDishViewControllerDelegate {
    
    private let url = URL(string: "http://localhost:8090/dishes")!
    private var dishes :[Dish]!
    private var selectedSegmentedIndex :Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTableView()
    }
    
    private func createCourseSelectionView() -> UIView {
        
        let courseSelectionView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: self.tableView.frame.width, height: 44)))
        
        let courseSelectionSegmentedControl = UISegmentedControl(items: ["Starters","Entrees","Desserts"])
        
        courseSelectionSegmentedControl.addTarget(self, action: #selector(courseSelected), for: .valueChanged)
        
        courseSelectionSegmentedControl.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: self.tableView.frame.width, height: 33))
        courseSelectionSegmentedControl.backgroundColor = UIColor.white
        
        courseSelectionSegmentedControl.selectedSegmentIndex = self.selectedSegmentedIndex
        
        courseSelectionView.addSubview(courseSelectionSegmentedControl)
        
        return courseSelectionView
        
    }
    
    @objc func courseSelected(segmentedControl :UISegmentedControl) {
        
        self.selectedSegmentedIndex = segmentedControl.selectedSegmentIndex
        
        // get the selected course
        if let title = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex) {
            
            filterDishesByCourse(title: title)
        }
        
    }
    
    private func filterDishesByCourse(title :String) {
        
        let url = URL(string: "http://localhost:8090/dishes-by-course?course=" + title)!
        
        self.dishes = [Dish]()
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let data = data {
                
                let json = try! JSONSerialization.jsonObject(with: data, options: [])
                let dictionaries = json as! [JSONDictionary]
                
                self.dishes = dictionaries.flatMap { dictionary in
                    let dish = Dish(dictionary: dictionary)
                    return dish
                }
                
                dictionaries.forEach { dictionary in
                    
                    if let dish = Dish(dictionary: dictionary) {
                        // Next we add the dish to the dishes collection
                        self.dishes.append(dish)
                    }
                }
                
                // Finally we reload the table view control so it can display
                // the updated records in based on our filter criteria
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
            
            }.resume()
        
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // get the selected dish
            let dish = self.dishes[indexPath.row]
            
            var request = URLRequest(url: URL(string: "http://localhost:8090/dish")!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "DELETE"
            
            request.httpBody = try! JSONSerialization.data(withJSONObject: ["id":dish.id], options: .prettyPrinted)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                
                if error != nil {
                    print(error?.localizedDescription)
                    return
                }
                
                DispatchQueue.main.async {
                    
                    self.updateTableView()
                }
                
                }.resume()
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createCourseSelectionView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dishes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let dish = self.dishes[indexPath.row]
        cell.textLabel?.text = dish.title
        cell.imageView?.image = UIImage(named: "placeholder")
        
        cell.detailTextLabel?.text = dish.description
        
        cell.imageView?.setImageFor(url: URL(string: dish.imageURL)!) { image in
            
            cell.imageView?.image = image
            cell.setNeedsLayout()
        }
        
        return cell
        
    }
    
    func addNewDishViewControllerDidSaveDish(dish: Dish) {
        
        var request = URLRequest(url: URL(string: "http://localhost:8090/dish")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: dish.toDictionary(), options: .prettyPrinted)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let data = data {
                
                let json = try! JSONSerialization.jsonObject(with: data, options: [])
                let dictionary = json as! JSONDictionary
                let success = dictionary["success"] as! Bool
                
                if success {
                    
                    self.dishes.append(dish)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
            }
            
            }.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let navigationController = segue.destination as! UINavigationController
        guard let addDishViewController = navigationController.viewControllers.first as? AddNewDishViewController else {
            fatalError("AddDishViewController not found")
        }
        
        addDishViewController.delegate = self
    }
    
    private func updateTableView() {
        
        self.dishes = [Dish]()
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if error != nil {
                return
            }
            
            if let data = data {
                
                let json = try! JSONSerialization.jsonObject(with: data, options: [])
                
                let dictionaries = json as! [JSONDictionary]
                
                dictionaries.forEach { dictionary in
                    
                    if let dish = Dish(dictionary: dictionary) {
                        self.dishes.append(dish)
                    }
                }
                
                // reload the table view on the main thread
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                }
            }
            
            
            }.resume()
    }
    
}
