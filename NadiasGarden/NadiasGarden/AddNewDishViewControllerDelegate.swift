//
//  AddNewDishViewControllerDelegate.swift
//  NadiasGarden
//
//  Created by Michail Bondarenko on 2/20/19.
//  Copyright © 2019 Michail Bondarenko. All rights reserved.
//

import Foundation
import UIKit

protocol AddNewDishViewControllerDelegate {
    
    func addNewDishViewControllerDidSaveDish(dish :Dish)
}

class AddNewDishViewController : UITableViewController {
    
    @IBOutlet weak var titleTextField :UITextField!
    @IBOutlet weak var priceTextField :UITextField!
    @IBOutlet weak var descriptionTextView :UITextView!
    @IBOutlet weak var imageURLTextField :UITextField!
    @IBOutlet weak var courseSegmentedControl :UISegmentedControl!
    
    var delegate :AddNewDishViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save() {
        
        let title = titleTextField.text!
        let price = Double(priceTextField.text!)!
        
        let description = descriptionTextView.text!
        let imageURL = imageURLTextField.text!
        
        let course = self.courseSegmentedControl.titleForSegment(at: self.courseSegmentedControl.selectedSegmentIndex)!
        
        let dish = Dish(title: title, description: description, price: price, course: course, imageURL: imageURL)
        
        self.delegate.addNewDishViewControllerDidSaveDish(dish: dish)
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
