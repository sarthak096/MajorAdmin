//
//  LoginViewController.swift
//  AKSwiftSlideMenu
//
//  Created by i on 3/10/18.
//  Copyright © 2018 Kode. All rights reserved.
//


import UIKit
import Firebase
import FirebaseAuth
import ChameleonFramework

class LoginViewController: UIViewController,UITextFieldDelegate{
    
    //Outlets and Variables
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //Load ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set Gradient Background
        let colors:[UIColor] = [UIColor.flatRedDark,UIColor.flatOrange]
        view.backgroundColor = GradientColor(.topToBottom, frame: view.frame, colors: colors)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.tag = 0
        passwordTextField.tag = 1
        login.tag = 2
        emailTextField.returnKeyType = UIReturnKeyType.next
        passwordTextField.returnKeyType = UIReturnKeyType.done
    }
    
    //Assign first responder
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailTextField {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField{
            textField.resignFirstResponder()
            login.becomeFirstResponder()
        } else if textField == login {
            textField.resignFirstResponder()
        }
        return true
    }
    
    //LoginAction
    @IBAction func loginAction(_ sender: UIButton) {
        if self.emailTextField.text == "" || self.passwordTextField.text == "" || isValidEmail(testEmail: emailTextField.text!, domain: "emp") == false {
        
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            //Authenticate User
            Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                
                if error == nil {
                    
                    
                    print("You have successfully logged in")
                    
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "abc")
                    self.present(vc!, animated: true, completion: nil)
                    
                } else {
                    
                    
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func isValidEmail(testEmail:String, domain:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[\(domain)]+\\.[com]{3,\(domain.characters.count)}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testEmail)
        return result
        
    }
    
}
