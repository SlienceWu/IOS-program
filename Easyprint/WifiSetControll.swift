//
//  WifiSetControll.swift
//  Easyprint
//
//  Created by app on 2018/7/16.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import UIKit
import Alamofire

class WifiSetControll: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var wlanName: UITextField!
    @IBOutlet weak var wlanPassword: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    override func viewDidLoad() {
        wlanName.delegate = self
        wlanPassword.delegate = self
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
        self.navigationItem.title = "Wifi"
        nextBtn.addTarget(self, action: #selector(configWifi), for: UIControlEvents.touchUpInside)
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
    //输入键盘控制消失
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @objc func handleTap(sender: UITapGestureRecognizer){
        if sender.state == .ended{
            wlanName.resignFirstResponder()
            wlanPassword.resignFirstResponder()
        }
        sender.cancelsTouchesInView = false
    }
    //配置Wi-Fi
    @objc func configWifi(){
        let wlan = wlanName.text
        let password = wlanPassword.text
        let url = "http://192.168.4.1:80"
        let data = "/ssid:" + wlan! + ";password:" + password! + ";server:" + Url.baseWifi + ";"
        let need = url + data
        //let FilterReplace = need.replacingOccurrences(of: " ", with: "%20")
        //print(FilterReplace)
        if need.contains(" "){
            self.present(Alert().singleAlert(message: "No space when entering the letters."), animated: true, completion: nil)
            return
        }
        PersonInfo.shadowView.initWithIndicatorWithView(view: self.view, withText: "please wait.")
        PersonInfo.shadowView.startTheView()
        AlamofireCustom.alamofireManager.request(need, method: .get).response{
            (response) in
            PersonInfo.shadowView.stopAndRemoveFromSuperView()
            let need = String(data: response.data!, encoding: .utf8)
            if need == "config ok"{
                self.present(Alert().textAlert(message: "Wifi config is completed."), animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                    self.navigationController!.popToRootViewController(animated: true)
                })
            } else {
                let alert = UIAlertController(title: "", message: "Wifi config is fail", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "ok", style: .default, handler: nil)
                alert.addAction(cancel)
                self.present(Alert().singleAlert(message: "Wifi config is fail"), animated: true, completion: nil)
            }
        }
    }
}
