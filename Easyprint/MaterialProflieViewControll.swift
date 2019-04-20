//
//  MaterialProflieViewControll.swift
//  Easyprint
//
//  Created by app on 2018/7/24.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class MaterialProfileViewConroll: UIViewController {
    //传值参数
    var listCount: Int?
    
    @IBOutlet weak var scrollView: UIScrollView!
    let width = UIScreen.main.bounds.size.width
    let height = UIScreen.main.bounds.size.height
    //material列表ID
    var listId = [String]()
    var defaultListView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
        let btn = btnView(height: 16)
        scrollView.addSubview(btn)
        defaultListView = self.defaultProfile(profileList: ["Custom material profile","PLA","ABS"])
        self.view.addSubview(defaultListView)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //页面出现后
    override func viewDidAppear(_ animated: Bool) {

    }
    override func viewWillAppear(_ animated: Bool) {
        listId.removeAll()
        getProfileList()
    }
    //查询材料列表
    func getProfileList(){
        if PersonInfo().state() == "logout"{
            return
        }
        let encryStr = PersonInfo().emailAes()
        let token = PersonInfo().token()
        let url = Url.baseUsers + encryStr + "/material_profiles?token=" + token
        Alamofire.request(url).responseJSON{
            (response) in
            let code = response.response?.statusCode
            if code == 200{
                let list = JSON(response.result.value as Any)
                let viewList = UIView()
                viewList.frame = CGRect(x: 0, y: 0, width: Int(self.width), height: 50 * (list.count))
                if list.count > 0{
                    for i in 0...(list.count - 1){
                        self.listId.append(list[i]["id"].stringValue)
                        let view = UIView()
                        let labelName = UILabel()
                        let border = UIView()
                        view.frame = CGRect(x: 16, y: 50 * i, width: Int(self.width - 32), height: 50)
                        view.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 1)
                        border.frame = CGRect(x: 0, y: 48, width: Int(view.bounds.size.width), height: 2)
                        border.backgroundColor = UIColor.init(red: 238/255, green: 239/255, blue: 240/255, alpha: 1)
                        labelName.frame = CGRect(x: 0, y: 0, width: Int(self.width - 132), height: 50)
                        labelName.text = list[i]["name"].stringValue
                        let changeBtn = self.changeBtn(number: i)
                        let deleteBtn = self.deleteBtn(number: i)
                        
                        view.addSubview(labelName)
                        view.addSubview(changeBtn)
                        view.addSubview(deleteBtn)
                        view.addSubview(border)
                        viewList.addSubview(view)
                    }
                    self.scrollView.subviews.forEach({$0.removeFromSuperview()})
                    self.scrollView.addSubview(viewList)
                    let btn = self.btnView(height: (Int(viewList.bounds.size.height + 10)))
                    self.scrollView.contentSize = CGSize(width: self.view.bounds.size.width, height: CGFloat(self.listId.count * 50 + 80))
                    self.scrollView.addSubview(btn)
                    return
                }
                self.scrollView.subviews.forEach({$0.removeFromSuperview()})
                let btn = self.btnView(height: 16)
                self.scrollView.addSubview(btn)
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
    //删除
    @objc func toDelete(sender: UITapGestureRecognizer){
        let view = sender.view
        let tag = view?.tag
        deleteProfile(id: self.listId[tag!])
    }
    func deleteProfile(id: String){
        let alert = UIAlertController(title: "", message: "Delete this Material profile?", preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(UIAlertAction) in
            let token = PersonInfo().token()
            let encryStr = PersonInfo().emailAes()
            let encryStrId = AES_ECB().encypted(need: id)
            let url = Url.baseUsers + encryStr + "/material_profiles/" + encryStrId
            let params = ["action": "delete", "target": "user_mprofile", "token": token]
            Alamofire.request(url, method: .delete, parameters: params, encoding: JSONEncoding.default).response{
                (response) in
                let code = response.response?.statusCode
                if code == 200{
                    self.listId.removeAll()
                    self.getProfileList()
                    self.present(Alert().singleAlert(message: "Delete Success."), animated: true, completion: nil)
                } else {
                    if code != nil {
                        ResponseError().error(target: self, code: code!)
                    } else{
                        let nsCode = (response.error! as NSError).code
                        ResponseError().errorNScode(target: self, code: nsCode)
                    }
                }
            }
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    //跳转
    @objc func skipToAdd(){
        defaultListView.isHidden = false
    }
    @objc func skipToEdit(sender: UITapGestureRecognizer){
        let view = sender.view
        let tag = view?.tag
        skipToDetail(event: self.listId[tag!])
    }
    func skipToDetail(event: String){
        self.performSegue(withIdentifier: "materialDetail", sender: event)
    }
    //添加材料按键
    func btnView(height: Int) ->UIButton{
        let btn = UIButton()
        btn.frame = CGRect(x: 16, y: height, width: Int(width - 32), height: 50)
        btn.backgroundColor = UIColor.init(red: 28/255, green: 142/255, blue: 1, alpha: 1)
        btn.setTitle("+ New Material Profile", for: .normal)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        btn.isEnabled = true
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.blue, for: .highlighted)
        btn.setTitleColor(UIColor.cyan, for: .selected)
        btn.setTitleColor(UIColor.cyan, for: .disabled)
        btn.setTitleShadowColor(UIColor.cyan, for: .normal)
        btn.setTitleShadowColor(UIColor.green, for: .highlighted)
        btn.setTitleShadowColor(UIColor.brown, for: .selected)
        btn.setTitleShadowColor(UIColor.darkGray, for: .disabled)
        btn.addTarget(self, action: #selector(skipToAdd), for: UIControlEvents.touchUpInside)
        return btn
    }
    //修改材料按键
    func changeBtn(number: Int) ->UIImageView{
        let changeBtn = UIImageView()
        changeBtn.frame = CGRect(x: Int(self.width - 132), y: 0, width: 50, height: 50)
        changeBtn.image = UIImage(named: "icon_edit")
        changeBtn.isUserInteractionEnabled = true
        let tapEdit = UITapGestureRecognizer(target: self, action: #selector(self.skipToEdit(sender:)))
        changeBtn.tag = number
        changeBtn.addGestureRecognizer(tapEdit)
        return changeBtn
    }
    //删除按键
    func deleteBtn(number: Int) ->UIImageView{
        let deleteBtn = UIImageView()
        deleteBtn.frame = CGRect(x: Int(self.width - 92), y: 0, width: 50, height: 50)
        deleteBtn.image = UIImage(named: "icon_delete")
        deleteBtn.isUserInteractionEnabled = true
        let tapDelete = UITapGestureRecognizer(target: self, action: #selector(self.toDelete(sender:)))
        deleteBtn.tag = number
        deleteBtn.addGestureRecognizer(tapDelete)
        return deleteBtn
    }
    //默认选项
    func defaultProfile(profileList: [String]) -> UIView{
        let view = UIView()
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        let scrollView = UIScrollView()
        for i in 0...(profileList.count - 1){
            let label = UILabel()
            label.text = profileList[i]
            label.textAlignment = NSTextAlignment.center
            label.frame = CGRect(x: 0, y: 50 * i, width: Int(width * 2/3), height: 50)
            label.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(chooseProfile(sender:)))
            label.tag = i
            label.addGestureRecognizer(tap)
            scrollView.addSubview(label)
        }
        if profileList.count * 50 < Int(height * 2/3) {
            scrollView.frame = CGRect(x: Int(width * 1/6), y: Int(height/2) - profileList.count * 25, width: Int(width * 2/3), height: profileList.count * 50)
        } else {
            scrollView.frame = CGRect(x: width * 1/6, y: height * 1/6, width: width * 2/3, height: height * 2/3)
        }
        scrollView.contentSize = CGSize(width: width * 2/3, height: CGFloat(profileList.count * 50))
        scrollView.backgroundColor = UIColor.white
        scrollView.layer.cornerRadius = 5
        scrollView.layer.masksToBounds = true
        scrollView.bounces = true
        view.addSubview(scrollView)
        view.isHidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideDefault))
        view.addGestureRecognizer(tap)
        return view
    }
    @objc func hideDefault(){
        defaultListView.isHidden = true
    }
    @objc func chooseProfile(sender: UITapGestureRecognizer){
        let view = sender.view
        let tag = view?.tag
        if tag == 0{
            defaultListView.isHidden = true
            skipToDetail(event: "add")
        }else{
            defaultListView.isHidden = true
            addProfile(type: tag!)
        }
    }
    //添加材料
    @objc func addProfile(type: Int){
        if PersonInfo().state() == "logout"{
            self.present(Alert().singleAlert(message: "Please log in."), animated: true, completion: nil)
            return
        }
        var obj = [String : Any]()
        if type == 1{
            obj = ["name": "PLA", "diameter": 1.75, "extruder_temp": 200, "bed_temp": 70]
        } else{
            obj = ["name": "ABS", "diameter": 1.75, "extruder_temp": 230, "bed_temp": 90]
        }
        let encryStr = PersonInfo().emailAes()
        let url = Url.baseUsers + encryStr
        let params = ["action": "add", "target": "user_mprofile", "object": obj, "token": PersonInfo().token()] as [String : Any]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response{
            (response) in
            let code = response.response?.statusCode
            if code == 201{
                self.present(Alert().singleAlert(message: "Add success."), animated: true, completion: nil)
                self.listId.removeAll()
                self.getProfileList()
            } else {
                if code != nil{
                    ResponseError().error(target: self, code: code!)
                    return
                }
                let nsCode = (response.error! as NSError).code
                ResponseError().errorNScode(target: self, code: nsCode)
            }
        }
    }
    struct profileList {
        static var PLA = ["name": "PLA", "diameter": 1.75, "extruder_temp": 200, "bed_temp": 70] as [String : Any]
        static var ABS = ["name": "ABS", "diameter": 1.75, "extruder_temp": 230, "bed_temp": 90] as [String : Any]
    }
    //返回
    @objc func tapBack(){
        self.navigationController?.popViewController(animated: true)
    }
    //跳转传值
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! MaterialProfileDetailViewControll
        controller.profileId = sender as? String
    }
}
