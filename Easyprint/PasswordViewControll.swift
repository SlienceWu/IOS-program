//
//  PasswordViewControll.swift
//  Easyprint
//
//  Created by app on 2018/7/11.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PasswordViewControll: UIViewController ,UITextFieldDelegate {
    
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var newRePassword: UITextField!
    @IBOutlet weak var changePassword: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        currentPassword.delegate = self
        newPassword.delegate = self
        newRePassword.delegate = self
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
        // Do any additional setup after loading the view, typically from a nib.
        changePassword.addTarget(self, action: #selector(setPassword), for: .touchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //设置新密码
    @objc func setPassword(){
        if PersonInfo().state() == "logout"{
            self.present(Alert().singleAlert(message: "Please log in."), animated: true, completion: nil)
            return
        }
        if newRePassword.text != newPassword.text{
            self.present(Alert().singleAlert(message: "The two password don't match."), animated: true, completion: nil)
            return
        }
        if (newPassword.text?.count)! < 7{
            self.present(Alert().singleAlert(message: "Invalid Password."), animated: true, completion: nil)
            return
        }
        let encryStr = PersonInfo().emailAes()
        let url = Url.baseUsers + encryStr
        let obj = ["old_password": currentPassword.text?.md5(), "new_password": newPassword.text?.md5()]
        let params = ["action": "update", "target": "user_password", "object": obj, "token": PersonInfo().token()] as [String : Any]
        PersonInfo.shadowView.initWithIndicatorWithView(view: self.view, withText: "please wait.")
        PersonInfo.shadowView.startTheView()
        AlamofireCustom.alamofireManager.request(url, method: .patch, parameters: params, encoding: JSONEncoding.default).response{
            (response) in
            PersonInfo.shadowView.stopAndRemoveFromSuperView()
            let code = response.response?.statusCode
            if code == 200{
                //print("Change success!")
                self.present(Alert().textAlert(message: "Change success!"), animated: true, completion: nil)
                PersonInfo.Var.isChangePassword = true
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                    self.logout()
                })
            } else if code == 400{
                self.present(Alert().singleAlert(message: "Params are wrong!"), animated: true, completion: nil)
            } else {
                if code != nil {
                    ResponseError().error(target: self, code: code!)
                } else{
                    let nsCode = (response.error! as NSError).code
                    ResponseError().errorNScode(target: self, code: nsCode)
                }
                self.present(Alert().singleAlert(message: "Original password error!"), animated: true, completion: nil)
            }
        }
    }
    //退出登录
    @objc func logout(){
        let emailAes = PersonInfo().emailAes()
        let token = PersonInfo().token()
        let params = ["action": "logout", "target": "user", "token": token]
        let url = Url.baseUserLogin + emailAes
        
        Alamofire.request(url, method: .delete, parameters: params).response{
            (response) in
            let code = response.response?.statusCode
            if code == 200{
                //print("logout request success")
            }
            let userParams = ["email": PersonInfo().email(), "name": "", "address": "", "avatar": "", "token": "", "token_expire": "", "state": ""]
            UserData().setData(key: "user", value: userParams as AnyObject)
            PersonInfo.Var.isChangePassword = false
            let loginView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginView")
            self.presentedViewController?.dismiss(animated: false, completion: nil)
            self.navigationController!.pushViewController(loginView, animated: true)
            //self.performSegue(withIdentifier: "passwordToLogin", sender: self)
        }
    }
    //返回键控制
    @objc func tapBack(){
        currentPassword.resignFirstResponder()
        newPassword.resignFirstResponder()
        newRePassword.resignFirstResponder()
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
            currentPassword.resignFirstResponder()
            newPassword.resignFirstResponder()
            newRePassword.resignFirstResponder()
        }
        sender.cancelsTouchesInView = false
    }
}
