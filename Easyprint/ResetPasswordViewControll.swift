//
//  ResetPasswordViewControll.swift
//  Easyprint
//
//  Created by app on 2018/7/26.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class ResetPasswordViewControll: UIViewController, UITextFieldDelegate {
    var resetEmail:String?
    
    @IBOutlet weak var passwordView: UITextField!
    @IBOutlet weak var passwordReView: UITextField!
    @IBOutlet weak var resetBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        passwordView.delegate = self
        passwordReView.delegate = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
        self.navigationItem.title = "Reset Password"
        resetBtn.addTarget(self, action: #selector(resetPassword), for: .touchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func resetPassword(){
        let password = passwordView.text
        let passwords = passwordReView.text
        let regPassword = "^[A-Z0-9a-z!@#$%^&*()_+\\[\\]{}:;,]{7,24}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regPassword)
        let isPasswordValid = predicate.evaluate(with: password)
        if password != passwords{
            self.present(Alert().singleAlert(message: "The two password do not match."), animated: true, completion: nil)
            return
        }
        if !isPasswordValid{
            self.present(Alert().singleAlert(message: "Invalid Password."), animated: true, completion: nil)
            return
        }
        let url = Url.baseUsers
        let obj = ["email": self.resetEmail, "password": password?.md5()]
        let params = ["action": "verify", "target": "user_password", "object": obj] as [String : Any]
        PersonInfo.shadowView.initWithIndicatorWithView(view: self.view, withText: "please wait.")
        PersonInfo.shadowView.startTheView()
        Alamofire.request(url, method: .patch, parameters: params, encoding: JSONEncoding.default).response{
            (response) in
            PersonInfo.shadowView.stopAndRemoveFromSuperView()
            let code = response.response?.statusCode
            if code == 200{
                self.present(Alert().textAlert(message: "Reset password success."), animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                    let loginView = self.navigationController?.viewControllers[1]
                    self.navigationController?.popToViewController(loginView!, animated: true)
                })
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
            passwordView.resignFirstResponder()
            passwordReView.resignFirstResponder()
        }
        sender.cancelsTouchesInView = false
    }
}
