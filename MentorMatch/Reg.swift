//
//  Reg.swift
//  MentorMatch
//
//  Created by Yash Nayak on 06/02/19.
//  Copyright © 2019 Yash Nayak. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class Reg: UIViewController {

    @IBOutlet weak var nametxt: UITextField!
    @IBOutlet weak var usernametxt: UITextField!
    @IBOutlet weak var emailtxt: UITextField!
    @IBOutlet weak var passwordtxt: UITextField!
    
    var ref: DatabaseReference!
    
    @IBAction func reg(_ sender: UIButton) {
        
        if  ((nametxt.text?.isEmpty)!||(usernametxt.text?.isEmpty)!||(emailtxt.text?.isEmpty)!||(passwordtxt.text?.isEmpty)!)
        {
            print("Registration Failed")
            self.myalert("Failed", "Please enter all the field")
            
        }else {
            
              self.ref.child("User").child(nametxt.text!).setValue(["First Name" : nametxt.text,"Last Name" : usernametxt.text,"E-mail" : emailtxt.text,"Password" : passwordtxt.text] )
            
            Auth.auth().createUser(withEmail: emailtxt.text!, password: passwordtxt.text!, completion:{
                (user,error) in
                
                if error  != nil  {
                    print(error!)
                    
                }else {
                    print("Registration Successful")
                    
                }
                
            })
            
    }
        clear()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
    }
    
    func clear()
    {
            nametxt.text=""
            usernametxt.text=""
            emailtxt.text=""
            passwordtxt.text=""
    }
    
        
    func myalert(_ mytitle:String, _ mymessage:String)
    {
            let alert = UIAlertController(title: mytitle, message: mymessage, preferredStyle: .actionSheet)
            let ok = UIAlertAction(title: "Done", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert,animated: true,completion: nil)
    }

}

