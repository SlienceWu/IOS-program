//
//  ModelListViewControll.swift
//  Easyprint
//
//  Created by app on 2018/7/31.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class ModelListViewControll: UIViewController, UIScrollViewDelegate {
    //传值参数
    var categoryID: String?
    var number = "19"
    //图片是否加载成功
    var isloadImg = false
    
    //@IBOutlet weak var searchBtn: UIButton!
    //@IBOutlet weak var keywordView: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    var creatViewHeight = CGFloat()
    let width = UIScreen.main.bounds.size.width
    let height = UIScreen.main.bounds.size.height
    let imgHeight = CGFloat(120)
    let viewChildHeight = CGFloat(120)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
        self.navigationItem.title = "ModelList"
        if PersonInfo.Var.modelID.count < 9{
            PersonInfo.Var.modelID = ["19", "20", "21", "22", "23", "24", "25", "26", "27"]
        }
        number = PersonInfo.Var.modelID[Int(categoryID!)!]
        getImgList(number: PersonInfo.Var.modelID[Int(categoryID!)!])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func getImgList(number: String){
        //图片请求
        AlamofireCustom.alamofireManager.request(Url.basePath+"/v1/modelbase/categories/" + number + "/pages/1", method: .get).responseJSON{
            (response)in
            let code = response.response?.statusCode
            if code == 200{
                if let json = response.result.value{
                    let list = json as![Any]
                    var newList = [String]()
                    PersonInfo.Var.modelImgID.removeAll()
                    PersonInfo.Var.modelImgName.removeAll()
                    for i in 0...(list.count-1){
                        let listDetail = list[i] as! [String: AnyObject]
                        let modelThumb = listDetail["model_thumb"] as! String
                        let modelName = listDetail["model_name"] as! String
                        let modelId = listDetail["model_id"] as! String
                        newList.append(modelThumb)
                        PersonInfo.Var.modelImgID.append(modelId)
                        PersonInfo.Var.modelImgName.append(modelName)
                    }
                    if newList.count < 60{
                        self.present(Alert().singleAlert(message: "No picture."), animated: true, completion: nil)
                        return
                    }
                    for i in 1...20{
                        //第一列
                        let viewA = UIView()
                        viewA.frame = CGRect(x: 0, y: CGFloat(i-1) * self.imgHeight, width: self.width/3, height: self.imgHeight)
                        let imageViewA = UIImageView()
                        imageViewA.frame = CGRect(x: self.width/6 - 40, y: 8, width: 80, height: 80)
                        let urlA = URL(string: Url.baseImgPath + newList[(i-1)*3])
                        imageViewA.kf.setImage(with: urlA)
                        viewA.addSubview(imageViewA)
                        let labelA = UILabel()
                        labelA.frame = CGRect(x: 0, y: 88, width: self.width/3, height: 32)
                        labelA.textAlignment = NSTextAlignment.center
                        labelA.font = UIFont.systemFont(ofSize: 12)
                        labelA.text = PersonInfo.Var.modelImgName[(i-1)*3]
                        viewA.addSubview(labelA)
                        //点击事件
                        viewA.isUserInteractionEnabled = true
                        let tapImageA = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureRecognizer(sender:)))
                        viewA.tag = i*3 - 3
                        viewA.addGestureRecognizer(tapImageA)
                        self.scrollView.addSubview(viewA)
                        //第二列
                        let viewB = UIView()
                        viewB.frame = CGRect(x: self.width * 1/3, y: CGFloat(i-1) * self.imgHeight, width: self.width/3, height: self.imgHeight)
                        let imageViewB = UIImageView()
                        imageViewB.frame = CGRect(x: self.width/6 - 40, y: 8, width: 80, height: 80)
                        let urlB = URL(string: Url.baseImgPath + newList[i*3-2])
                        imageViewB.kf.setImage(with: urlB)
                        let labelB = UILabel()
                        labelB.frame = CGRect(x: 0, y: 88, width: self.width/3, height: 32)
                        labelB.textAlignment = NSTextAlignment.center
                        labelB.font = UIFont.systemFont(ofSize: 12)
                        labelB.text = PersonInfo.Var.modelImgName[i*3-2]
                        viewB.addSubview(imageViewB)
                        viewB.addSubview(labelB)
                        //点击事件
                        viewB.isUserInteractionEnabled = true
                        let tapImageB = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureRecognizer(sender:)))
                        viewB.tag = i*3 - 2
                        viewB.addGestureRecognizer(tapImageB)
                        self.scrollView.addSubview(viewB)
                        //第三列
                        let viewC = UIView()
                        viewC.frame = CGRect(x: self.width * 2/3, y: CGFloat(i-1) * self.imgHeight, width: self.width/3, height: self.imgHeight)
                        let imageViewC = UIImageView()
                        imageViewC.frame = CGRect(x: self.width/6 - 40, y: 8, width: 80, height: 80)
                        let urlC = URL(string: Url.baseImgPath + newList[i*3-1])
                        imageViewC.kf.setImage(with: urlC)
                        let labelC = UILabel()
                        labelC.frame = CGRect(x: 0, y: 88, width: self.width/3, height: 32)
                        labelC.textAlignment = NSTextAlignment.center
                        labelC.font = UIFont.systemFont(ofSize: 12)
                        labelC.text = PersonInfo.Var.modelImgName[i*3-1]
                        viewC.addSubview(imageViewC)
                        viewC.addSubview(labelC)
                        //点击事件
                        viewC.isUserInteractionEnabled = true
                        let tapImageC = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureRecognizer(sender:)))
                        viewC.tag = i*3 - 1
                        viewC.addGestureRecognizer(tapImageC)
                        self.scrollView.addSubview(viewC)
                    }
                    //self.addSubview(self.viewList)
                    //设置容量
                    self.scrollView.contentSize = CGSize(width: self.width, height: self.imgHeight * 20)
                    //self.scrollView.frame = CGRect(x: 0, y: 52, width: self.width, height: self.height - 52)
                    //设置吸附属性
                    self.scrollView.bounces = true
                    self.scrollView.delegate = self
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
    var selfOffset = CGFloat()
    var pageNum = 1
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            selfOffset = self.scrollView.contentOffset.y
            let contentSize = self.scrollView.contentSize.height - self.scrollView.bounds.size.height - 900
            if !isloadImg{
                if contentSize < selfOffset {
                    isloadImg = true
                    pageNum = pageNum + 1
                    loadImg(int: pageNum)
                }
            }
        }
    }
    //图片加载
    func loadImg(int: Int){
        let url = Url.basePath+"/v1/modelbase/categories/" + self.number + "/pages/" + String(int)
        Alamofire.request(url, method: .get).responseJSON{
            (response)in
            
            let code = response.response?.statusCode
            if code == 200{
                if let json = response.result.value{
                    self.isloadImg = false
                    let list = json as![Any]
                    var newList = [String]()
                    for i in 0...(list.count-1){
                        let listDetail = list[i] as! [String: AnyObject]
                        let modelThumb = listDetail["model_thumb"] as! String
                        let modelName = listDetail["model_name"] as! String
                        let modelId = listDetail["model_id"] as! String
                        newList.append(modelThumb)
                        PersonInfo.Var.modelImgID.append(modelId)
                        PersonInfo.Var.modelImgName.append(modelName)
                    }
                    if newList.count < 60{
                        self.present(Alert().singleAlert(message: "No more."), animated: true, completion: nil)
                        return
                    }
                    for i in (1+20*(int-1))...(20 * int){
                        let a = i - 20*(int-1)
                        //第一列
                        let viewA = UIView()
                        viewA.frame = CGRect(x: 0, y: CGFloat(i-1) * self.imgHeight, width: self.width/3, height: self.imgHeight)
                        let imageViewA = UIImageView()
                        imageViewA.frame = CGRect(x: self.width/6 - 40, y: 8, width: 80, height: 80)
                        let urlA = URL(string: Url.baseImgPath + newList[a*3-3])
                        imageViewA.kf.setImage(with: urlA)
                        let labelA = UILabel()
                        labelA.frame = CGRect(x: 0, y: 88, width: self.width/3, height: 32)
                        labelA.textAlignment = NSTextAlignment.center
                        labelA.font = UIFont.systemFont(ofSize: 12)
                        labelA.text = PersonInfo.Var.modelImgName[(a-1)*3 + (int - 1)*60]
                        viewA.addSubview(imageViewA)
                        viewA.addSubview(labelA)
                        //点击事件
                        viewA.isUserInteractionEnabled = true
                        let tapImageA = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureRecognizer(sender:)))
                        viewA.tag = (a-1)*3 + (int - 1)*60
                        viewA.addGestureRecognizer(tapImageA)
                        
                        self.scrollView.addSubview(viewA)
                        //第二列
                        let viewB = UIView()
                        viewB.frame = CGRect(x: self.width * 1/3, y: CGFloat(i-1) * self.imgHeight, width: self.width/3, height: self.imgHeight)
                        let imageViewB = UIImageView()
                        imageViewB.frame = CGRect(x: self.width/6 - 40, y: 8, width: 80, height: 80)
                        let urlB = URL(string: Url.baseImgPath + newList[a*3-2])
                        imageViewB.kf.setImage(with: urlB)
                        let labelB = UILabel()
                        labelB.frame = CGRect(x: 0, y: 88, width: self.width/3, height: 32)
                        labelB.textAlignment = NSTextAlignment.center
                        labelB.font = UIFont.systemFont(ofSize: 12)
                        labelB.text = PersonInfo.Var.modelImgName[a*3 - 2 + (int - 1)*60]
                        viewB.addSubview(imageViewB)
                        viewB.addSubview(labelB)
                        //点击事件
                        viewB.isUserInteractionEnabled = true
                        let tapImageB = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureRecognizer(sender:)))
                        viewB.tag = a*3 - 2 + (int - 1)*60
                        viewB.addGestureRecognizer(tapImageB)
                        self.scrollView.addSubview(viewB)
                        //第三列
                        let viewC = UIView()
                        viewC.frame = CGRect(x: self.width * 2/3, y: CGFloat(i-1) * self.imgHeight, width: self.width/3, height: self.imgHeight)
                        let imageViewC = UIImageView()
                        imageViewC.frame = CGRect(x: self.width/6 - 40, y: 8, width: 80, height: 80)
                        let urlC = URL(string: Url.baseImgPath + newList[a*3-1])
                        imageViewC.kf.setImage(with: urlC)
                        let labelC = UILabel()
                        labelC.frame = CGRect(x: 0, y: 88, width: self.width/3, height: 32)
                        labelC.textAlignment = NSTextAlignment.center
                        labelC.font = UIFont.systemFont(ofSize: 12)
                        labelC.text = PersonInfo.Var.modelImgName[a*3 - 1 + (int - 1)*60]
                        viewC.addSubview(imageViewC)
                        viewC.addSubview(labelC)
                        //点击事件
                        viewC.isUserInteractionEnabled = true
                        let tapImageC = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureRecognizer(sender:)))
                        viewC.tag = a*3 - 1 + (int - 1)*60
                        viewC.addGestureRecognizer(tapImageC)
                        self.scrollView.addSubview(viewC)
                    }
                    self.scrollView.contentSize = CGSize(width: self.self.width, height: self.viewChildHeight * 20 * CGFloat(int))
                }
            }else{
                if code != nil{
                    ResponseError().error(target: self, code: code!)
                    return
                }
            }
            if response.result.isFailure{
                let code = (response.result.error! as NSError).code
                ResponseError().errorNScode(target: self, code: code)
                return
            }
        }
    }
    //查找
//    @objc func searchModel(){
//        let keyword = self.keywordView.text
//        let url = Url.bannerPath + "/v1/modelbase/categories/" + self.categoryID! + "?keyword=" + keyword!
//        Alamofire.request(url).responseJSON{ (response) in
//            if response.result.isFailure{
//                let code = (response.result.error as! NSError).code
//                if code == nil{
//                    return
//                }
//                ResponseError().errorNScode(target: self, code: code)
//                return
//            }
//            let code = response.response?.statusCode
//            if code == 200{
//
//            }
//        }
//    }
    @objc func tapBack(){
        self.navigationController?.popViewController(animated: true)
    }
    //跳转到详情页
    @objc func tapGestureRecognizer(sender: UITapGestureRecognizer){
        //#if DEBUG
        let view = sender.view
        let tag = view?.tag
        print("===== test model =====")
        print(PersonInfo.Var.modelImgID[tag!],PersonInfo.Var.modelImgName[tag!])
        self.performSegue(withIdentifier: "modelDetail", sender: PersonInfo.Var.modelImgID[tag!])
        //#else
        //#endif
    }
    //跳转传值
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! ModelDetailControll
        controller.modelId = sender as? String
    }
}
