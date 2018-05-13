//
//  NewItem.swift
//  MajorProjectAdmin
//
//  Created by i on 4/3/18.
//  Copyright © 2018 com.sarthakkapadiya. All rights reserved.
//

import UIKit
import Firebase

class NewItem : UIViewController,UITextFieldDelegate{
    
    public var new: ((String) -> ())?
    
    @IBOutlet weak var itemDesc: UITextField!
    @IBOutlet weak var itemPrice: UITextField!
    @IBOutlet weak var itemQuantity: UITextField!
    @IBOutlet weak var additemBtn: UIButton!
    var ref: DatabaseReference!
    var scan : OrdersViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemDesc.delegate = self
        itemPrice.delegate = self
        itemQuantity.delegate = self
        itemDesc.tag = 1
        itemPrice.tag = 2
        itemQuantity.tag = 3
        itemDesc.text = ""
        itemPrice.text = ""
        itemQuantity.text = ""
        
        scan = self.storyboard!.instantiateViewController(withIdentifier: "Orders") as? OrdersViewController
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func addPressed(_ sender: Any) {
        
        if (itemDesc.text! == "" || itemPrice.text! == "" || itemQuantity.text! == "" || isNumberValidInput(Input: itemPrice.text!) == false) || isNumberValidInput(Input: itemQuantity.text!) == false{
            let alert =  UIAlertController(title: "Incomplete details", message: "Please fill in all the above details to add the item", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            }
            alert.addAction(ok)
            present(alert,animated: true,completion: nil)
        }
        else{
            ref = Database.database().reference()
            let data = ["Description":itemDesc.text! as String,"Price":itemPrice.text! as String,"Quantity":Int(itemQuantity.text! as String)] as [String : Any]
            ref.child("Database").child(GlobalVariables.sharedManager.barcode).setValue(data)
            self.ref.child("Database").observeSingleEvent(of: .value, with: { (DataSnapshot) in
                GlobalVariables.sharedManager.orderscount = Int(DataSnapshot.childrenCount)
                print(GlobalVariables.sharedManager.orderscount)
            })
            
            self.scan?.invent = { (barcode: String) in
                _ = self.navigationController?.popViewController(animated: true)
            }
            if let scan = self.scan{
                self.navigationController?.pushViewController(scan, animated: true)
            }
        }
        
    }
    
    func isNumberValidInput(Input:String) -> Bool {
        let myCharSet=CharacterSet(charactersIn:"0123456789")
        let output: String = Input.trimmingCharacters(in: myCharSet.inverted)
        let isValid: Bool = (Input == output)
        return isValid
    }
    
}
