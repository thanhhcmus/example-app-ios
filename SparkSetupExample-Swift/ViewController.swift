//
//  ViewController.swift
//  SparkSetupExample-Swift
//
//  Created by Ido on 4/7/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SparkSetupMainControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Function will be called when setup finishes
    func sparkSetupViewController(controller: SparkSetupMainController!, didFinishWithResult result: SparkSetupMainControllerResult, device: SparkDevice!) {
        
        switch result
        {
            case .Success:
                print("Setup completed successfully")
            case .Failure:
                print("Setup failed")
            case .UserCancel :
                print("User cancelled setup")
            case .LoggedIn :
                print("User is logged in")
            default:
                print("Uknown setup error")
            
        }
        
        if device != nil
        {
            device.getVariable("test", completion: { (value, err) -> Void in

            })
        }
    }
    
    
    func customizeSetup()
    {
        // Do customization for Spark Setup wizard UI
        let c = SparkSetupCustomization.sharedInstance()
        c.brandImage = UIImage(named: "brand-logo-head")
        c.brandName = "Acme"
        c.brandImageBackgroundColor = UIColor(red: 0.88, green: 0.96, blue: 0.96, alpha: 0.9)
//        c.appName = "Acme Setup"
//        c.deviceImage = UIImage(named: "anvil")
        c.deviceName = "Connected Anvil"
        c.instructionalVideoFilename = "rr.mp4"

        c.normalTextFontName = "Skater Girls Rock"
        c.boldTextFontName = "CheriLiney"
        c.fontSizeOffset = 1;
    }
    
    @IBAction func startButtonTapped(sender: UIButton)
    {
        // Comment out this line to revert to default "Unbranded" Spark Setup app
//        self.customizeSetup()
        
        

        // lines required for invoking the Spark Setup wizard
        if let vc = SparkSetupMainController()
        {
            
            // check organization setup mode
            let c = SparkSetupCustomization.sharedInstance()
            c.allowSkipAuthentication = true
            
            vc.delegate = self
            vc.modalPresentationStyle = .FormSheet  // use that for iPad
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    func example()
    {
        // logging in
        if SparkCloud.sharedInstance().loggedInUsername == nil
        {
            SparkCloud.sharedInstance().loginWithUser("ido@spark.io", password: "test123") { (error:NSError?) -> Void in
                if let _=error
                {
                    print("Wrong credentials or no internet connectivity, please try again")
                }
                else
                {
                    print("Logged in")
                }
            }
        }
        
        // get specific device by name:
        var myPhoton : SparkDevice? = nil
        SparkCloud.sharedInstance().getDevices { (sparkDevices:[AnyObject]?, error:NSError?) -> Void in
            if let _=error
            {
                print("Check your internet connectivity")
            }
            else
            {
                if let devices = sparkDevices as? [SparkDevice]
                {
                    for device in devices
                    {
                        if device.name == "turtle_gerbil"
                        {
                            myPhoton = device
                        }
                        
                    }
                    if (myPhoton != nil)
                    {
                        print("subscribing to events...");
                        myPhoton!.subscribeToEventsWithPrefix("test", handler: { (event: SparkEvent?, error:NSError?) -> Void in
                            print(event!.event);
                        });
                        
                    }
                }
            }
        }
        
        
        // reading a variable
        myPhoton!.getVariable("temprature", completion: { (result:AnyObject?, error:NSError?) -> Void in
            if let _=error
            {
                print("Failed reading temprature from device")
            }
            else
            {
                if let res = result as? Float
                {
                    print("Room temprature is \(res) degrees")
                }
            }
        })
        
        
        // calling a function
        let funcArgs = ["D7",1]
        myPhoton!.callFunction("digitalwrite", withArguments: funcArgs) { (resultCode : NSNumber?, error : NSError?) -> Void in
            if (error == nil) {
                print("LED on D7 successfully turned on")
            }
        }
        
        // get device variables and functions
        let myDeviceVariables : Dictionary? = myPhoton!.variables as Dictionary<String,String>
        print("MyDevice first Variable is called \(myDeviceVariables!.keys.first) and is from type \(myDeviceVariables?.values.first)")

        let myDeviceFunction = myPhoton!.functions
        print("MyDevice first function is called \(myDeviceFunction.first)")

        // get a device instance by ID
        var myOtherDevice : SparkDevice? = nil
        SparkCloud.sharedInstance().getDevice("53fa73265066544b16208184", completion: { (device:SparkDevice?, error:NSError?) -> Void in
            if let d = device {
                myOtherDevice = d
            }
        })

        // rename a device
        myPhoton!.name = "myNewDeviceName"
            // or:
        myPhoton!.rename("myNewDeviceName", completion: { (error:NSError?) -> Void in
            if (error == nil) {
                print("Device successfully renamed")
            }
            
        })

        // logout
        SparkCloud.sharedInstance().logout()
        

    }

    
    
}

