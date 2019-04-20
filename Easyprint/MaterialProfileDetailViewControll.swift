//
//  MaterialProfileDetailViewControll.swift
//  Easyprint
//
//  Created by app on 2018/7/24.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class MaterialProfileDetailViewControll: UIViewController,UITextFieldDelegate {
    var profileId: String?
    
    @IBOutlet weak var materialName: UITextField!
    @IBOutlet weak var filamentSize: UILabel!
    @IBOutlet weak var chooseSize: UIView!
    @IBOutlet weak var extruderTempView: UITextField!
    @IBOutlet weak var bedTempView: UITextField!
    @IBOutlet weak var btnView: UIButton!
    
    @IBOutlet weak var sizeView: UIView!
    @IBOutlet weak var sizeBtn1: UIButton!
    @IBOutlet weak var sizeBtn2: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        materialName.delegate = self
        extruderTempView.delegate = self
        bedTempView.delegate = self
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
        self.navigationItem.title = "Material profile"
        let tap = UITapGestureRecognizer(target: self, action: #selector(showSize))
        chooseSize.addGestureRecognizer(tap)
        sizeBtn1.addTarget(self, action: #selector(changeFilament1), for: .touchUpInside)
        sizeBtn2.addTarget(self, action: #selector(changeFilament2), for: .touchUpInside)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        if profileId != "add" && profileId != nil{
            getProfileDetail()
            btnView.setTitle("change", for: .normal)
            btnView.addTarget(self, action: #selector(changeProfile), for: .touchUpInside)
        } else {
            btnView.setTitle("add", for: .normal)
            btnView.addTarget(self, action: #selector(addProfile), for: .touchUpInside)
        }
    }
    //选择框
    @objc func showSize(){
        if sizeView.isHidden{
            sizeView.isHidden = false
        } else{
            sizeView.isHidden = true
        }
    }
    @objc func changeFilament1(){
        sizeView.isHidden = true
        filamentSize.text = sizeBtn1.currentTitle
    }
    @objc func changeFilament2(){
        sizeView.isHidden = true
        filamentSize.text = sizeBtn2.currentTitle
    }
    //添加材料
    @objc func addProfile(){
        if PersonInfo().state() == "logout"{
            self.present(Alert().singleAlert(message: "Please log in."), animated: true, completion: nil)
            return
        }
        
        let encryStr = PersonInfo().emailAes()
        let url = Url.baseUsers + encryStr
        let extruderTemp = Int(self.extruderTempView.text!)
        let bedTemp = Int(self.bedTempView.text!)
        var diameter:Any
        if filamentSize.text == "3"{
            diameter = Int(filamentSize.text!) as Any
        }else{
            diameter = Double(filamentSize.text!) as Any
        }
        
        let name = self.materialName.text! as String
        if name == ""{
            self.present(Alert().singleAlert(message: "Name null."), animated: true, completion: nil)
            return
        }
        if extruderTemp == nil || bedTemp == nil{
            self.present(Alert().singleAlert(message: "Params are not in the valid range."), animated: true, completion: nil)
            return
        }
        if extruderTemp! < 0 || extruderTemp! > 250 || bedTemp! < 0 || bedTemp! > 250 {
            self.present(Alert().singleAlert(message: "Params are not in the valid range."), animated: true, completion: nil)
            return
        }
        let obj = ["name": name, "diameter": diameter, "extruder_temp": extruderTemp as Any, "bed_temp": bedTemp as Any] as [String : Any]
        let params = ["action": "add", "target": "user_mprofile", "object": obj, "token": PersonInfo().token()] as [String : Any]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response{
            (response) in
            let code = response.response?.statusCode
            if code == 201{
                self.present(Alert().singleAlert(message: "Add success."), animated: true, completion: nil)
            } else {
                if code != nil {
                    ResponseError().error(target: self, code: code!)
                } else{
                    let nsCode = (response.error! as NSError).code
                    ResponseError().errorNScode(target: self, code: nsCode)
                }
            }
        }
    }
    //修改参数
    @objc func changeProfile(){
        if PersonInfo().state() == "logout"{
            self.present(Alert().singleAlert(message: "Please log in."), animated: true, completion: nil)
            return
        }
        
        let encryStr = PersonInfo().emailAes()
        let encryStrId = AES_ECB().encypted(need: self.profileId!)
        let url = Url.baseUsers + encryStr + "/material_profiles/" + encryStrId
        let extruderTemp = Int(self.extruderTempView.text!)
        let bedTemp = Int(self.bedTempView.text!)
        var diameter:Any
        if filamentSize.text == "3"{
            diameter = Int(filamentSize.text!) as Any
        }else{
            diameter = Double(filamentSize.text!) as Any
        }
        
        let name = self.materialName.text
        if name == ""{
            self.present(Alert().singleAlert(message: "Name null."), animated: true, completion: nil)
            return
        }
        if extruderTemp == nil || bedTemp == nil{
            self.present(Alert().singleAlert(message: "Params are not in the valid range."), animated: true, completion: nil)
            return
        }
        if extruderTemp! < 0 || extruderTemp! > 250 || bedTemp! < 0 || bedTemp! > 250 {
            self.present(Alert().singleAlert(message: "Params are not in the valid range."), animated: true, completion: nil)
            return
        }
        let obj = ["name": name as Any, "diameter": diameter, "extruder_temp": extruderTemp as Any, "bed_temp": bedTemp as Any] as [String : Any]
        let params = ["action": "update", "target": "user_mprofile", "object": obj, "token": PersonInfo().token()] as [String : Any]
        Alamofire.request(url, method: .patch, parameters: params, encoding: JSONEncoding.default).response{
            (response) in
            let code = response.response?.statusCode
            if code == 200{
                self.present(Alert().singleAlert(message: "Change success."), animated: true, completion: nil)
            } else {
                if code != nil {
                    ResponseError().error(target: self, code: code!)
                } else{
                    let nsCode = (response.error! as NSError).code
                    ResponseError().errorNScode(target: self, code: nsCode)
                }
            }
        }

    }
    //获取材料详情
    func getProfileDetail(){
        let encryStr = PersonInfo().emailAes()
        let token = PersonInfo().token()
        let encryStrId = AES_ECB().encypted(need: self.profileId!)
        let url = Url.baseUsers + encryStr + "/material_profiles/" + encryStrId + "?token=" + token
        Alamofire.request(url).responseJSON{
            (response) in
            let code = response.response?.statusCode
            if code == 200{
                let list = JSON(response.result.value as Any)
                self.extruderTempView.text = list["extruder_temp"].stringValue
                self.bedTempView.text = list["bed_temp"].stringValue
                self.materialName.text = list["name"].stringValue
                self.filamentSize.text = list["diameter"].stringValue
            } else {
                if code != nil{
                    ResponseError().error(target: self, code: code!)
                    return
                }
            }
            if response.result.isFailure{
                let code = (response.result.error! as NSError).code
                ResponseError().errorNScode(target: self, code: code)
            }
        }
    }
    //返回键控制
    @objc func tapBack(){
        self.navigationController?.popViewController(animated: true)
        //dismiss(animated: true, completion: nil)
    }
    //输入键盘控制消失
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @objc func handleTap(sender: UITapGestureRecognizer){
        if sender.state == .ended{
            materialName.resignFirstResponder()
            extruderTempView.resignFirstResponder()
            bedTempView.resignFirstResponder()
        }
        sender.cancelsTouchesInView = false
    }
    //限制只能输入3位数字
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == materialName{
            let proposeLength = (textField.text?.lengthOfBytes(using: String.Encoding.utf8))! - range.length + string.lengthOfBytes(using: String.Encoding.utf8)
            if proposeLength > 24 { return false}
            return true
        }
        let length = string.lengthOfBytes(using: String.Encoding.utf8)
        for loopIndex in 0..<length{
            let char = ( string as NSString).character(at: loopIndex)
            if char < 48 { return false}
            if char > 57 { return false}
        }
        let proposeLength = (textField.text?.lengthOfBytes(using: String.Encoding.utf8))! - range.length + string.lengthOfBytes(using: String.Encoding.utf8)
        if proposeLength > 3 { return false}
        return true
    }
}
