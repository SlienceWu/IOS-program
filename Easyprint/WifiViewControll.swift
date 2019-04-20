//
//  WifiViewControll.swift
//  Easyprint
//
//  Created by app on 2018/7/16.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import UIKit

class WifiViewControll: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //返回键控制
    @objc func tapBack(){
        self.navigationController?.popViewController(animated: true)
        //dismiss(animated: true, completion: nil)
    }
}
