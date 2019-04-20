//
//  AboutViewControll.swift
//  Easyprint
//
//  Created by app on 2018/7/10.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AboutViewControll: UIViewController {
    
    @IBOutlet weak var currentVersion: UILabel!
    @IBOutlet weak var newVersion: UILabel!
    @IBOutlet weak var upDate: UITextView!
    @IBOutlet weak var imgNew: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
        checkVersion()
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
    //查询版本号
    func checkVersion(){
        let url = Url.basePath + "/v1/app/info"
        Alamofire.request(url).responseJSON{
            (response) in
            let code = response.response?.statusCode
            if code == 200{
                let value = response.result.value as Any
                let json = JSON(value)
            
                let newVersion = json["ios"]["newest_version"].stringValue
                self.newVersion.text = newVersion
                let updateInfo = json["ios"]["update_info"].stringValue
                let updateList = json["ios"]["update_list"].arrayValue
                if newVersion == self.currentVersion.text{
                    return
                }
                self.imgNew.isHidden = false
                var allString = ""
                if updateList.count == 0{
                    self.upDate.text = updateInfo
                    return
                }
                for i in 0...updateList.count-1{
                    allString = allString + "\(i+1)" + ". " + updateList[i].stringValue + "\n"
                }
                allString = updateInfo + "\n" + allString
                self.upDate.text = allString
            } else{
                if code != nil{
                    ResponseError().error(target: self, code: code!)
                }
            }
        }
    }
}
