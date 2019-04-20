//
//  BaseNavigationControll.swift
//  Easyprint
//
//  Created by app on 2018/8/7.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import Foundation
import UIKit

class BaseNavigationControll: UINavigationController {
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension BaseNavigationControll: UIGestureRecognizerDelegate{
    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.delegate = self
    }
    //滑动返回
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.viewControllers.count == 1{
            return false
        }
        return true
    }
}
