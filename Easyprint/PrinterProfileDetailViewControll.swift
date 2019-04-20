//
//  PrinterProfileDetailViewControll.swift
//  Easyprint
//
//  Created by app on 2018/7/24.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PrinterProfileDetailViewControll: UIViewController,UITextFieldDelegate {
    var profileId: String?
    
    @IBOutlet weak var labelName: UITextField!
    @IBOutlet weak var bedShapeImg: UIImageView!
    @IBOutlet weak var chooseShape: UIView!
    @IBOutlet weak var shapeName: UILabel!
    @IBOutlet weak var xView: UITextField!
    @IBOutlet weak var yView: UITextField!
    @IBOutlet weak var zView: UITextField!
    @IBOutlet weak var heatedBed: UIImageView!
    @IBOutlet weak var btnView: UIButton!
    
    @IBOutlet weak var circularView: UIView!
    @IBOutlet weak var radiusView: UITextField!
    @IBOutlet weak var heightView: UITextField!
    @IBOutlet weak var shapeView: UIView!
    @IBOutlet weak var shapeBtn1: UIButton!
    @IBOutlet weak var shapeBtn2: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //键盘协议（完成按键隐藏键盘）
        labelName.delegate = self
        xView.delegate = self
        yView.delegate = self
        zView.delegate = self
        radiusView.delegate = self
        heightView.delegate = self
        //导航返回及名称
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
        self.navigationItem.title = "Printer profile"
        //显示下拉
        let tap = UITapGestureRecognizer(target: self, action: #selector(showShapeView))
        chooseShape.addGestureRecognizer(tap)
        //选择shape
        shapeBtn1.addTarget(self, action: #selector(rectangleShow), for: .touchUpInside)
        shapeBtn2.addTarget(self, action: #selector(circularShow), for: .touchUpInside)
        //选择热床
        let tapBed = UITapGestureRecognizer(target: self, action: #selector(changeBed(sender:)))
        heatedBed.addGestureRecognizer(tapBed)
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
    @objc func showShapeView(){
        if shapeView.isHidden{
            shapeView.isHidden = false
        }else{
            shapeView.isHidden = true
        }
    }
    @objc func rectangleShow(){
        shapeView.isHidden = true
        shapeName.text = shapeBtn1.currentTitle
        circularView.isHidden = true
        bedShapeImg.image = UIImage(named: "icon_bed_shape")
    }
    @objc func circularShow(){
        shapeView.isHidden = true
        shapeName.text = shapeBtn2.currentTitle
        circularView.isHidden = false
        bedShapeImg.image = UIImage(named: "icon_shape_circle")
    }
    @objc func changeBed(sender: UITapGestureRecognizer){
        let view = sender.view
        let tag = view?.tag
        if tag == 0{
            heatedBed.tag = 1
            heatedBed.image = UIImage(named: "icon_enable")
        } else{
            heatedBed.tag = 0
            heatedBed.image = UIImage(named: "icon_unable")
        }
    }
    //查询材料参数
    func getProfileDetail(){
        let encryStr = PersonInfo().emailAes()
        let token = PersonInfo().token()
        let encryStrId = AES_ECB().encypted(need: self.profileId!)
        let url = Url.baseUsers + encryStr + "/printer_profiles/" + encryStrId + "?token=" + token
        Alamofire.request(url).responseJSON{
            (response) in            
            let code = response.response?.statusCode
            if code == 200{
                let value = response.result.value as Any
                let list = JSON(value)
                self.labelName.text = list["name"].stringValue
                if list["heatbed_exist"].stringValue == "1"{
                    self.heatedBed.tag = 1
                    self.heatedBed.image = UIImage(named: "icon_enable")
                } else {
                    self.heatedBed.tag = 0
                    self.heatedBed.image = UIImage(named: "icon_unable")
                }
                if list["shape"].stringValue == "0"{
                    self.shapeName.text = "Rectangle"
                    self.xView.text = list["width"].stringValue
                    self.yView.text = list["depth"].stringValue
                    self.zView.text = list["height"].stringValue
                } else {
                    self.shapeName.text = "Circular"
                    self.bedShapeImg.image = UIImage(named: "icon_shape_circle")
                    self.circularView.isHidden = false
                    self.heightView.text = list["height"].stringValue
                    self.radiusView.text = list["radius"].stringValue
                }
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
    //添加材料参数
    @objc func addProfile(){
        if PersonInfo().state() == "logout"{
            self.present(Alert().singleAlert(message: "Please log in."), animated: true, completion: nil)
            return
        }
        let encryStr = PersonInfo().emailAes()
        let url = Url.baseUsers + encryStr
        let width = Int(xView.text!)
        let depth = Int(yView.text!)
        let height = Int(zView.text!)
        let name = labelName.text
        let radius = Int(radiusView.text!)
        let cirHeight = Int(heightView.text!)
        var shape = 0
        var obj:[String: Any]
        if name == ""{
            self.present(Alert().singleAlert(message: "Name null."), animated: true, completion: nil)
            return
        }
        if shapeName.text == "Circular"{
            shape = 1
            if radius == nil || cirHeight == nil{
                self.present(Alert().singleAlert(message: "Params are not in the valid range."), animated: true, completion: nil)
                return
            }
            if radius! < 0 || cirHeight! < 0 {
                self.present(Alert().singleAlert(message: "Params are not in the valid range."), animated: true, completion: nil)
                return
            }
            obj = ["name": name as Any, "radius": radius as Any, "height": cirHeight as Any, "shape": shape as Any, "heatbed_exist": self.heatedBed.tag]
        }else{
            if width == nil || depth == nil || height == nil{
                self.present(Alert().singleAlert(message: "Params are not in the valid range."), animated: true, completion: nil)
                return
            }
            if width! < 0 || depth! < 0 || height! < 0 {
                self.present(Alert().singleAlert(message: "Params are not in the valid range."), animated: true, completion: nil)
                return
            }
            obj = ["name": name as Any, "width": width as Any, "depth": depth as Any, "height": height as Any, "shape": shape as Any, "heatbed_exist": self.heatedBed.tag]
        }
        let params = ["action": "add", "target": "user_pprofile", "object": obj, "token": PersonInfo().token()] as [String : Any]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response{
            (response) in
            let code = response.response?.statusCode
            if code == 201{
                self.present(Alert().singleAlert(message: "Add Success."), animated: true, completion: nil)
            } else{
                if code != nil {
                    ResponseError().error(target: self, code: code!)
                } else{
                    let nsCode = (response.error! as NSError).code
                    ResponseError().errorNScode(target: self, code: nsCode)
                }
            }
        }
    }
    //修改材料参数
    @objc func changeProfile(){
        if PersonInfo().state() == "logout"{
            self.present(Alert().singleAlert(message: "Please log in."), animated: true, completion: nil)
            return
        }
        let encryStr = PersonInfo().emailAes()
        let encryStrId = AES_ECB().encypted(need: self.profileId!)
        let url = Url.baseUsers + encryStr + "/printer_profiles/" + encryStrId
        let width = Int(xView.text!)
        let depth = Int(yView.text!)
        let height = Int(zView.text!)
        let name = labelName.text
        let radius = Int(radiusView.text!)
        let cirHeight = Int(heightView.text!)
        var shape = 0
        var obj:[String: Any]
        if name == ""{
            self.present(Alert().singleAlert(message: "Name null."), animated: true, completion: nil)
            return
        }
        if shapeName.text == "Circular"{
            shape = 1
            if radius == nil || cirHeight == nil{
                self.present(Alert().singleAlert(message: "Params are not in the valid range."), animated: true, completion: nil)
                return
            }
            if radius! < 0 || cirHeight! < 0 {
                self.present(Alert().singleAlert(message: "Params are not in the valid range."), animated: true, completion: nil)
                return
            }
            obj = ["name": name as Any, "radius": radius as Any, "height": cirHeight as Any, "shape": shape as Any, "heatbed_exist": self.heatedBed.tag]
        }else{
            if width == nil || depth == nil || height == nil{
                self.present(Alert().singleAlert(message: "Params are not in the valid range."), animated: true, completion: nil)
                return
            }
            if width! < 0 || depth! < 0 || height! < 0 {
                self.present(Alert().singleAlert(message: "Params are not in the valid range."), animated: true, completion: nil)
                return
            }
            obj = ["name": name as Any, "width": width as Any, "depth": depth as Any, "height": height as Any, "shape": shape as Any, "heatbed_exist": self.heatedBed.tag]
        }
        let params = ["action": "add", "target": "user_pprofile", "object": obj, "token": PersonInfo().token()] as [String : Any]
        Alamofire.request(url, method: .patch, parameters: params, encoding: JSONEncoding.default).response{
            (response) in
            let code = response.response?.statusCode
            if code == 200{
                self.present(Alert().singleAlert(message: "Change Success."), animated: true, completion: nil)
            } else{
                if code != nil {
                    ResponseError().error(target: self, code: code!)
                } else{
                    let nsCode = (response.error! as NSError).code
                    ResponseError().errorNScode(target: self, code: nsCode)
                }
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
            labelName.resignFirstResponder()
            radiusView.resignFirstResponder()
            heightView.resignFirstResponder()
            xView.resignFirstResponder()
            yView.resignFirstResponder()
            zView.resignFirstResponder()
        }
        sender.cancelsTouchesInView = false
    }
    
    //限制只能输入3位数字
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == labelName{
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
