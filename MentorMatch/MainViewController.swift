//
//  MainViewController.swift
//  MentorMatch
//
//  Created by Yash Nayak on 07/02/19.
//  Copyright © 2019 Yash Nayak. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class MainViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var logdedin: UILabel!
    
    var temp1:String = "User"
    
    //table view
    @IBOutlet var table: UITableView!
    
    var list:[MyStruct] = [MyStruct]()
    
    struct MyStruct
    {
        var userId = ""
        
        
        init(_ userId:String)
        {
            self.userId = userId
        
        }
    }
    //table end
    
    
    
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("mainView"+temp1)
        
        logdedin.text = "Logged in as "+temp1
        
        
        
        //table view
        table.dataSource = self
        table.delegate = self
        
        get_data("https://api.myjson.com/bins/iabt4")
    }
    
    
    func opentalkapi() {
        //test dynamic
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        let url = URL(string: "https://mentormatch-test.herokuapp.com/room/room1")
        let dataTask = session.dataTask(with: url!) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            guard error == nil, let data = data else {
                print(error!)
                return
            }
            
            let dict = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [AnyHashable: Any]
            kApiKey = dict?["apiKey"] as? String ?? ""
            kSessionId = dict?["sessionId"] as? String ?? ""
            kToken = dict?["token"] as? String ?? ""
            print(kApiKey)
            print(kSessionId)
            print(kToken)
           // self.connectToAnOpenTokSession()
        }
        dataTask.resume()
        session.finishTasksAndInvalidate()
    }
    
    //table of view
    func get_data(_ link:String)
    {
        let url:URL = URL(string: link)!
        let session = URLSession.shared
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            self.extract_data(data)
        })
        task.resume()
    }
    
    func extract_data(_ data:Data?)
    {
        let json:Any?
        if(data == nil)
        {
            return
        }
        
        do{
            json = try JSONSerialization.jsonObject(with: data!, options: [])
        }
        catch
        {
            return
        }
        
        guard let data_array = json as? NSArray else
        {
            return
        }
        
        for i in 0 ..< data_array.count
        {
            if let data_object = data_array[i] as? NSDictionary
            {
                if let userId = data_object["userId"] as? String
                  
                {
                    list.append(MyStruct(userId))
                }
            }
        }
        refresh_now()
    }
    
    func refresh_now()
    {
        DispatchQueue.main.async(
            execute:
            {
                self.table.reloadData()
                
        })
    }
    
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return list.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        
        cell.textLabel?.text = list[indexPath.row].userId
        
       return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    
        let alert = UIAlertController(title: "Verify", message: "You sure want to connect with "+list[indexPath.row].userId , preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes",
                                      style: UIAlertAction.Style.destructive,
                                      handler: {(_: UIAlertAction!) in
                                        let vc = self.storyboard!.instantiateViewController(withIdentifier: "ViewController") as!
                                        ViewController
                                        self.navigationController?.pushViewController(vc, animated: true)
                                        
                                        vc.temp1 = self.list[indexPath.row].userId
                                        
        }))
        alert.addAction(UIAlertAction(title: "Nope", style: UIAlertAction.Style.default, handler: { _ in
            
        }))
       
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertWithDistructiveButton() {
        
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
