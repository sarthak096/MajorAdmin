//
//  Payverify.swift
//  AKSwiftSlideMenu
//
//  Created by i on 5/14/18.
//  Copyright © 2018 Kode. All rights reserved.
//

import UIKit
import Firebase
var ref : DatabaseReference!

class Payverify: UIViewController{
    
    @IBOutlet weak var Cname: UILabel!
    @IBOutlet weak var amt: UILabel!
    @IBOutlet weak var paymode: UILabel!
    @IBOutlet weak var verify: UIButton!
    public var Scanned: ((String) -> ())?
    var ref : DatabaseReference!
    @IBOutlet weak var verified: UILabel!
    var newView: HomeVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newView = self.storyboard!.instantiateViewController(withIdentifier: "Home") as? HomeVC
        let ckey = GlobalVariables.sharedManager.ckey
        let oid = GlobalVariables.sharedManager.oid
        ref =  Database.database().reference()
        let aref = self.ref.child("users").child(ckey).queryOrderedByKey()
        aref.observe(.value, with: { (snapshot) in
            
            let newcount = snapshot.childrenCount
            let userDictt = snapshot.value as! [String: Any]
            let uname = userDictt["name"] as! String
            let contact = userDictt["mobile"] as! String
            self.Cname.text = uname
        })
        
        let newref = self.ref.child("users").child(ckey).child("orders").child(oid).queryOrderedByKey()
        newref.observe(.value, with: { (snapshot) in
            
            let newcount = snapshot.childrenCount
            let userDictt = snapshot.value as! [String: Any]
            
            let mode = userDictt["Payment mode: "] as! String
            let verify = userDictt["Verified: "] as! String
            print("Sarthak")
            print(userDictt)
            var amt = mode.components(separatedBy: "-")
            print(amt[0])
            print(amt[1])
            self.paymode.text = amt[0]
            self.amt.text = amt[1]
            self.verified.text = verify
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func verifyclicked(_ sender: UIButton) {
        let ckey = GlobalVariables.sharedManager.ckey
        let oid = GlobalVariables.sharedManager.oid
        let Ename = GlobalVariables.sharedManager.Empname
        self.ref.child("users").child(ckey).child("orders").child(oid).child("Verified: ").setValue("Yes - \(Ename)")
        self.newView?.appDone = { (barcode: String) in
            _ = self.navigationController?.popViewController(animated: true)
            print("Received following barcode: \(barcode)")
        }
        
        if let newView = self.newView{
            self.navigationController?.pushViewController(newView, animated: true)
        }
    }
    
}
