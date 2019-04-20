//
//  Reachability.swift
//  Easyprint
//
//  Created by app on 2018/8/9.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import Reachability

var reach: Reachability?

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    
    return true
}

func reachabilityChanged(notification: NSNotification) {
    if self.reach!.isReachableViaWiFi() || self.reach!.isReachableViaWWAN() {
        print("Service avalaible!!!")
    } else {
        print("No service avalaible!!!")
    }
}
