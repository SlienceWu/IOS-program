//
//  AppDelegate.swift
//  Easyprint
//
//  Created by app on 2018/5/11.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import UIKit
import ZLaunchAd
import Alamofire
import SwiftyJSON
import Reachability

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let reachability = Reachability(hostname: "www.apple.com")!
    var count = 0
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if UserDefaults.standard.bool(forKey: "firstLauch") == false {
            UserDefaults.standard.set(true, forKey: "firstLauch")
            let userParams = ["email": "", "name": "", "address": "", "avatar": "", "token": "", "token_expire": "", "state": ""]
            UserData().setData(key: "user", value: userParams as AnyObject)
        }
        //网络检测
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
        //广告页
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
//        let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RootView")
        //#if DEBUG
        let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RootView")
        //#else
        //let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainNavigation")
        //#endif
        window?.rootViewController = homeVC
        window?.makeKeyAndVisible()

        showAd()
        creatTimer()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .wifi:
            PersonInfo.isConnectToServer = 1
            print("Reachable via WiFi")
        case .cellular:
            PersonInfo.isConnectToServer = 1
            print("Reachable via Cellular")
        case .none:
            PersonInfo.isConnectToServer = 0
            PersonInfo().initTemp()
            print("Network not reachable")
        }
    }
}
extension AppDelegate{
    func showAd(){
        let adView = ZLaunchAd.create()
        let buttonConfig = ZLaunchSkipButtonConfig()
        buttonConfig.skipBtnType = ZLaunchSkipButtonType(rawValue: 0)!
        let imageResource = ZLaunchAdImageResourceConfigure()
        imageResource.animationType = ZLaunchAnimationType(rawValue: 0)!
        
        imageResource.imageDuration = 6
        imageResource.imageFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        request { (imgUrl) in
            
            imageResource.imageNameOrImageURL = imgUrl
            adView.setImageResource(imageResource, action: {
                let urlStr = "http://www.giantarm.com/featured_product/d200-3dprinter.html"
                let url = URL(string: urlStr)
                
                if #available(iOS 10, *){
                    UIApplication.shared.open(url!, options: [:], completionHandler: {(success) in})
                } else {
                    UIApplication.shared.openURL(url!)
                }
            })
        }
    }
}
extension AppDelegate{
    //创建定时器
    func creatTimer(){
        let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerManager), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .commonModes)
    }
    //创建定时器管理者
    @objc func timerManager(){
        let url = Url.basePath + "/v1/app/heartbeat"
        AlamofireCustom.alamofireManager.request(url).response{
            response in
            let code = response.response?.statusCode
            if code == 200{
                self.count = 0
                PersonInfo.isConnectToServer = 1
            }else{
                self.count = self.count + 1
                if self.count > 5{
                    PersonInfo.isConnectToServer = 2
                    PersonInfo().initTemp()
                }
            }
        }
    }
    func request(_ completion: @escaping (String) ->() ) -> Void{
        
        let url = Url.basePath + "/v1/app/ad"
        Alamofire.request(url).responseJSON{
            (response) in
            let list = JSON(response.result.value as Any)
            let imgUrl = list[0]["image_path"].stringValue
            completion(imgUrl)
        }
    }
}
