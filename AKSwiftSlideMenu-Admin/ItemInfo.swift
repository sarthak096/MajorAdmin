//
//  ItemInfo.swift
//  AKSwiftSlideMenu
//
//  Created by i on 5/9/18.
//  Copyright © 2018 Kode. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

protocol ItemInfoDelegate: class {
    
    func textChanged(text:String?)
    
}
class ItemInfo:UIViewController,UITextFieldDelegate{
    
    //Outlets and Variables
    @IBOutlet weak var logOut: UIButton!
    @IBOutlet weak var editBtn: UIBarButtonItem!
    @IBOutlet weak var ItemCode: UITextField!
    @IBOutlet weak var Description: UITextField!
    @IBOutlet weak var Price: UITextField!
    @IBOutlet weak var Quantity: UITextField!
    var userid:String = (Auth.auth().currentUser?.uid)!
    var editTextFieldToggle: Bool = false
    // var username = abc.globalVariable.userName;
    var ref : DatabaseReference!
    var flag = true
    var address: String = ""
    public var infoview: ((String) -> ())?
    @IBOutlet weak var priceStepper: UIStepper!
    @IBOutlet weak var quantityStepper: UIStepper!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref =  Database.database().reference()
        
        ItemCode.delegate = self
        Description.delegate = self
        Price.delegate = self
        Quantity.delegate = self
        ItemCode.tag = 0
        Description.tag = 1
        Price.tag = 2
        Quantity.tag = 3
        ItemCode.returnKeyType = UIReturnKeyType.next
        Description.returnKeyType = UIReturnKeyType.done
        Price.returnKeyType = UIReturnKeyType.done
        Quantity.returnKeyType = UIReturnKeyType.done
        quantityStepper.isHidden = true
        priceStepper.isHidden = true
        logOut.isHidden = true
        
        //Make Round LogOutBtn
        logOut.layer.cornerRadius = 0.1 * logOut.bounds.size.width
        logOut.clipsToBounds = true
        let temp = GlobalVariables.sharedManager.itemCode
        print(temp)
        //Fetch userdata from the Firebase
        ref.child("Database").child(temp).observeSingleEvent(of: .value, with: { DataSnapshot in
            if !DataSnapshot.exists(){
                return
            }
            let userDict = DataSnapshot.value as! [String: Any]
            let desc = userDict["Description"] as! String
            let price = userDict["Price"] as! String
            let quantity = userDict["Quantity"] as! Int
            self.ItemCode.text = GlobalVariables.sharedManager.itemCode
            self.Quantity.text = "\(quantity)"
            self.Description.text = desc
            self.Price.text = price
            GlobalVariables.sharedManager.pint = Int((price as NSString).integerValue)
            GlobalVariables.sharedManager.qint = quantity
            self.priceStepper.value = Double(GlobalVariables.sharedManager.pint)
            self.quantityStepper.value = Double(GlobalVariables.sharedManager.qint)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let temp = GlobalVariables.sharedManager.itemCode
        print(temp)
        //Fetch userdata from the Firebase
        ref.child("Database").child(temp).observeSingleEvent(of: .value, with: { DataSnapshot in
            if !DataSnapshot.exists(){
                return
            }
            let userDict = DataSnapshot.value as! [String: Any]
            let desc = userDict["Description"] as! String
            let price = userDict["Price"] as! String
            let quantity = userDict["Quantity"] as! Int
            self.ItemCode.text = GlobalVariables.sharedManager.itemCode
            self.Quantity.text = "\(quantity)"
            self.Description.text = desc
            self.Price.text = price
            GlobalVariables.sharedManager.pint = Int((price as NSString).integerValue)
            GlobalVariables.sharedManager.qint = quantity
            self.priceStepper.value = Double(GlobalVariables.sharedManager.pint)
            self.quantityStepper.value = Double(GlobalVariables.sharedManager.qint)
        })
    }
    //Assign First responder
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        /*
        if textField == ItemCode {
            textField.resignFirstResponder()
            //Description.becomeFirstResponder()
        }*/if textField == Description {
            textField.resignFirstResponder()
            //Price.becomeFirstResponder()
        }else if textField == Price{
            textField.resignFirstResponder()
           // Quantity.becomeFirstResponder()
        }else if textField == Quantity{
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func editPressed(_ sender: UIBarButtonItem) {
        editTextFieldToggle = !editTextFieldToggle
        flag = true
        if editTextFieldToggle == true {
            navigationItem.rightBarButtonItem = editBtn
            let edit = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(editPressed(_:)))
            navigationItem.rightBarButtonItem = edit
            textFieldActive()
            
        } else {
            let temp = GlobalVariables.sharedManager.itemCode
            let desc = Description.text
            let price = Price.text
            let quantity = Int(Quantity.text!)
            ref.child("Database").child(temp).child("Description").setValue(desc)
            ref.child("Database").child(temp).child("Price").setValue(price)
            ref.child("Database").child(temp).child("Quantity").setValue(quantity)
            flag = false
            navigationItem.rightBarButtonItem = editBtn
            let edit = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editPressed(_:)))
            navigationItem.rightBarButtonItem = edit
            textFieldDeactive()
            
        }
    }
    
    //Enable Textfields
    func textFieldActive(){
        priceStepper.isHidden = false
        quantityStepper.isHidden = false
        logOut.isHidden = false
        
        Description.isUserInteractionEnabled = true
        Description.becomeFirstResponder()
        Price.isUserInteractionEnabled = true
        Quantity.isUserInteractionEnabled = true
        //userAddress.isUserInteractionEnabled = true*/
    }
    
    //Disable Textdfields
    func textFieldDeactive(){
        priceStepper.isHidden = true
        quantityStepper.isHidden = true
        logOut.isHidden = true
        
        Description.isUserInteractionEnabled = false
        Price.isUserInteractionEnabled = false
        Quantity.isUserInteractionEnabled = false
        //userAddress.isUserInteractionEnabled = false
        
    }
    
    //Logout user
    @IBAction func logoutAction(_ sender: Any) {
        let temp = GlobalVariables.sharedManager.itemCode
        ref.child("Database").child(temp).removeValue()
        ref.child("Database").observeSingleEvent(of: .value, with: { (DataSnapshot) in
            GlobalVariables.sharedManager.orderscount = Int(DataSnapshot.childrenCount)
            print(GlobalVariables.sharedManager.orderscount)
        })
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func priceChanged(_ sender: UIStepper) {
        Price.text = Int(sender.value).description
    }
    
    @IBAction func quantityChanged(_ sender: UIStepper) {
        Quantity.text = Int(sender.value).description
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
