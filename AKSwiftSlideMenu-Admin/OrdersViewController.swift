//
//  OrdersViewController.swift
//  AKSwiftSlideMenu
//
//  Created by i on 3/15/18.
//  Copyright © 2018 Kode. All rights reserved.
//

import UIKit
import Firebase
import CRRefresh

class OrdersViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource{
    
    var ref: DatabaseReference! = Database.database().reference()
    var Uid:String = (Auth.auth().currentUser?.uid)!
    var tt: String = ""
    var titlesArray:[String] = []
    @IBOutlet var tableView: UITableView!
    var newitem = [String]()
    var arr:[String] = []
    var arrquant:[String] = []
    var new:[String] = []
    @IBOutlet var addBtn: UIBarButtonItem!
    var add : NewItemScan?
    var info : ItemInfo?
    public var invent: ((String) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Order Cell")
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        tableView.rowHeight = 110.0
        tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()){[weak self] in
            self?.ref.child("Database").observeSingleEvent(of: .value, with: { (DataSnapshot) in
                GlobalVariables.sharedManager.orderscount = Int(DataSnapshot.childrenCount)
                print(GlobalVariables.sharedManager.orderscount)
                print("Load")
            })
            self?.tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self?.tableView.cr.endHeaderRefresh()
            })
        }
        tableView.cr.beginHeaderRefresh()
        add = self.storyboard!.instantiateViewController(withIdentifier: "NewItemScanScene") as? NewItemScan
        info = self.storyboard!.instantiateViewController(withIdentifier: "ItemInfo") as? ItemInfo
    }
    //Reload TableView
    @objc func loadList(){
        self.isEditing = !self.isEditing
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
 }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ref.child("Database").observeSingleEvent(of: .value, with: { (DataSnapshot) in
            GlobalVariables.sharedManager.orderscount = Int(DataSnapshot.childrenCount)
            print(GlobalVariables.sharedManager.orderscount)
        })
        print("see")
         tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()){[weak self] in
         self?.ref.child("Database").observeSingleEvent(of: .value, with: { (DataSnapshot) in
         GlobalVariables.sharedManager.orderscount = Int(DataSnapshot.childrenCount)
         print(GlobalVariables.sharedManager.orderscount)
         print("Load")
         })
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
         self?.tableView.cr.endHeaderRefresh()
         })
         }
        tableView.cr.beginHeaderRefresh()
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if GlobalVariables.sharedManager.orderscount > 0 {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
        else {
            let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No items"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
     return GlobalVariables.sharedManager.orderscount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Order Cell")
        //let cell = table.dequeueReusableCell(withIdentifier: "Order Cell")
        //Fetch Firebase Data
        let qref = self.ref.child("Database").queryOrderedByKey()
        qref.observeSingleEvent(of: .value, with: { (snapshot) in
            GlobalVariables.sharedManager.orderarray.removeAll()
            for snap in snapshot.children{
                let usersnap = snap as! DataSnapshot
                let code = (usersnap.key as? String)
                GlobalVariables.sharedManager.orderarray.append(code!)
            }
            print(GlobalVariables.sharedManager.orderarray.count)
            let tt = GlobalVariables.sharedManager.orderarray[indexPath.row]
            cell.textLabel?.text = "ItemCode: " + GlobalVariables.sharedManager.orderarray[indexPath.row]
            self.ref.child("Database").child(tt).observeSingleEvent(of: .value, with: { DataSnapshot in
                if !DataSnapshot.exists(){
                    return
                }
                let userDict = DataSnapshot.value as! [String: Any]
                let qdesc = userDict["Description"] as! String
                let qprice = userDict["Price"] as! String
                let quanti = userDict["Quantity"] as! String
                var text = "Description: " + qdesc + "\n" + "Price: " + qprice + "\n" + "Quantity: " + quanti
                cell.detailTextLabel?.numberOfLines = 5
                cell.detailTextLabel?.text = text
            })
        })
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.info?.infoview = { (barcode: String) in
            GlobalVariables.sharedManager.itemCode = GlobalVariables.sharedManager.orderarray[indexPath.row]
            _ = self.navigationController?.popViewController(animated: true)
            print("see")/*
            tableView.cr.addHeadRefresh(animator: NormalHeaderAnimator()){[weak self] in
                self?.ref.child("Database").observeSingleEvent(of: .value, with: { (DataSnapshot) in
                    GlobalVariables.sharedManager.orderscount = Int(DataSnapshot.childrenCount)
                    print(GlobalVariables.sharedManager.orderscount)
                    print("Load")
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self?.tableView.cr.endHeaderRefresh()
                })
            }
            tableView.cr.beginHeaderRefresh()*/
            self.tableView.reloadData()
            
        }
        if let info = self.info{
            GlobalVariables.sharedManager.itemCode = GlobalVariables.sharedManager.orderarray[indexPath.row]
            print("This")
            self.navigationController?.pushViewController(info, animated: true)
            self.tableView.reloadData()
        }
    }
    
    @IBAction func newItem(_ sender: Any) {
        add?.itemscanned = { (barcode: String) in
            _ = self.navigationController?.popViewController(animated: true)
        }
        if let add = self.add{
            self.navigationController?.pushViewController(add, animated: true)
        }
    }
}
