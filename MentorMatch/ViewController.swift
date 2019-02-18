//
//  ViewController.swift
//  MentorMatch
//
//  Created by Yash Nayak on 06/02/19.
//  Copyright © 2019 Yash Nayak. All rights reserved.
//

import UIKit
import OpenTok

// Replace with your OpenTok API key
var kApiKey = "Key"
// Replace with your generated session ID
var kSessionId = "Sessionid"
// Replace with your generated token
var kToken = "Token"


let kWidgetHeight = 320
let kWidgetWidth = 240


class ViewController: UIViewController {
    
    var temp1:String = ""
 
    
    var userCount = 0
    
    lazy var session: OTSession = {
        return OTSession(apiKey: kApiKey, sessionId: kSessionId, delegate: self)!
    }()
    
    lazy var publisher: OTPublisher = {
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        return OTPublisher(delegate: self, settings: settings)!
    }()
    
    var subscriber: OTSubscriber?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doConnect()
        
        
        
        //test dynamic
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        let url = URL(string: "https://mentormatch-test.herokuapp.com/room/\(temp1)")
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
            self.connectToAnOpenTokSession()
        }
        dataTask.resume()
        session.finishTasksAndInvalidate()
        
    }
    
    func connectToAnOpenTokSession() {
        session = OTSession(apiKey: kApiKey, sessionId: kSessionId, delegate: self)!
        var error: OTError?
        session.connect(withToken: kToken, error: &error)
        if error != nil {
            print(error!)
        }
    }
    

    @IBAction func exitq(_ sender: Any) {
     //session.
        let alert = UIAlertController(title: "End Call", message: "You sure want to end call" , preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes",
                                      style: UIAlertAction.Style.destructive,
                                      handler: {(_: UIAlertAction!) in
                                        self.session.disconnect()
                                        let vc = self.storyboard!.instantiateViewController(withIdentifier: "MainViewController") as!
                                        MainViewController
                                        self.navigationController?.pushViewController(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Nope", style: UIAlertAction.Style.default, handler: { _ in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    /**
     * Asynchronously begins the session connect process. Some time later, we will
     * expect a delegate method to call us back with the results of this action.
     */
    fileprivate func doConnect() {
        var error: OTError?
        defer {
            processError(error)
        }
        
        session.connect(withToken: kToken, error: &error)
    }
    
    /**
     * Sets up an instance of OTPublisher to use with this session. OTPubilsher
     * binds to the device camera and microphone, and will provide A/V streams
     * to the OpenTok session.
     */
    fileprivate func doPublish() {
        var error: OTError?
        defer {
            processError(error)
        }
        
        session.publish(publisher, error: &error)
        
        if let pubView = publisher.view {
            //view test
            pubView.frame = CGRect(x: 0, y: 0, width: Int(100 * UIScreen.main.bounds.width/100), height: Int(90 * UIScreen.main.bounds.height/100))
            view.addSubview(pubView)
            
        }
    }
    
    /**
     * Instantiates a subscriber for the given stream and asynchronously begins the
     * process to begin receiving A/V content for this stream. Unlike doPublish,
     * this method does not add the subscriber to the view hierarchy. Instead, we
     * add the subscriber only after it has connected and begins receiving data.
     */
    fileprivate func doSubscribe(_ stream: OTStream) {
        var error: OTError?
        defer {
            processError(error)
        }
        subscriber = OTSubscriber(stream: stream, delegate: self)
        
        session.subscribe(subscriber!, error: &error)
    }
    
    fileprivate func cleanupSubscriber() {
        subscriber?.view?.removeFromSuperview()
        subscriber = nil
    }
    
    fileprivate func cleanupPublisher() {
        publisher.view?.removeFromSuperview()
    }
    
    fileprivate func processError(_ error: OTError?) {
        if let err = error {
            DispatchQueue.main.async {
                let controller = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    
   

}

// MARK: - OTSession delegate callbacks
extension ViewController: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        print("Session connected")
        doPublish()
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        print("Session disconnected")
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        
        
        
        
        let alert = UIAlertController(title: "Connect", message: "Do You want to join \(temp1)" , preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes",
                                      style: UIAlertAction.Style.destructive,
                                      handler: {(_: UIAlertAction!) in
                                        print("Session streamCreated: \(stream.streamId)")
                                        if self.subscriber == nil {
                                            self.userCount += 1
                                            self.doSubscribe(stream)
                                        }
                                        if self.userCount == 2 {
                                            print("Sorry, You only supports up to 2 subscribers")
                                            return
                                        }
        }))
        alert.addAction(UIAlertAction(title: "Nope", style: UIAlertAction.Style.default, handler: { _ in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
       
        
    }

    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("Session streamDestroyed: \(stream.streamId)")
        if let subStream = subscriber?.stream, subStream.streamId == stream.streamId {
            cleanupSubscriber()
        }
        self.session.disconnect()
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "MainViewController") as!
        MainViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("session Failed to connect: \(error.localizedDescription)")
    }
    
}

// MARK: - OTPublisher delegate callbacks
extension ViewController: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        print("Publishing")
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        cleanupPublisher()
        if let subStream = subscriber?.stream, subStream.streamId == stream.streamId {
            cleanupSubscriber()
        }
    }
    
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("Publisher failed: \(error.localizedDescription)")
    }
}

// MARK: - OTSubscriber delegate callbacks
extension ViewController: OTSubscriberDelegate {
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        if let subsView = subscriber?.view {
            //view test
            subsView.frame = CGRect(x: 20, y: 30, width: Int(40 * UIScreen.main.bounds.width/100), height: Int(45 * UIScreen.main.bounds.width/100))
            view.addSubview(subsView)
        }
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber failed: \(error.localizedDescription)")
    }
    
    
    
    
}
