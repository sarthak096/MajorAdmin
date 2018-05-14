//
//  GlobalVariables.swift
//  AKSwiftSlideMenu
//
//  Created by i on 4/5/18.
//  Copyright © 2018 Kode. All rights reserved.
//

import UIKit

class GlobalVariables{
    public var totalprice: Int = 0
    public var tempprice : Int = 0
    public var orderarray : [String] = []
    public var orderscount : Int = 0
    public var item : String = ""
    public var modeofpayment: String = ""
    public var orderlist : [String] = []
    public var barcode: String = ""
    public var codearray: [String] = []
    public var datacount : Int = 0
    public var itemCode : String  = ""
    public var pint : Int = 0
    public var qint : Int = 0
    public var ckey : String = ""
    public var oid : String = ""
    public var Empname : String = ""
    
    class var sharedManager: GlobalVariables{
        struct Static{
            static let instance = GlobalVariables()
        }
        return Static.instance
    }
}
