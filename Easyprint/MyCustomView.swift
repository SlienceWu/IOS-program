//
//  MyScrollView.swift
//  Easyprint
//
//  Created by app on 2018/6/29.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import SwiftyJSON

//轮播图
class ZYF_MyScrollView: UIScrollView, UIScrollViewDelegate{
    let width = UIScreen.main.bounds.size.width
    
    func creatMyScrollView(imageName: [String], height: CGFloat){
        
        //动态布局
        for i in 0...(imageName.count - 1){
            let imageView = UIImageView()
            //设置轮播图片
            imageView.frame = CGRect(x:CGFloat(i) * width, y: 0, width: width, height: height)
            let url = URL(string: imageName[i])
            if imageName[i] == "icon_error"{
                imageView.image = UIImage(named: imageName[i])
            } else{
                imageView.kf.setImage(with: url)
            }
            //轮播图控制
            imageView.isUserInteractionEnabled = true
            let tapImage = UITapGestureRecognizer(target: self, action: #selector(ZYF_MyScrollView.tapGestureRecognizer(sender:)))
            imageView.tag = Int(height)
            imageView.addGestureRecognizer(tapImage)
            
            self.addSubview(imageView)
        }

        //设置轮播图容量
        self.contentSize = CGSize(width: CGFloat(imageName.count) * width, height: height)
        self.frame = CGRect(x: 0, y: 0, width: width, height: height)
        //设置吸附属性
        self.bounces = false
        //设置书页效果
        self.isPagingEnabled = true
        //单独创建最后一张图片和第一张一样
        let imageView = UIImageView()
        imageView.frame = CGRect(x: CGFloat(imageName.count) * width, y: 0, width: width, height: height)
        //imageView.image = UIImage(named: imageName[0])
        if imageName[0] == "icon_error"{
            imageView.image = UIImage(named: imageName[0])
            self.addSubview(imageView)
        } else{
            let url = URL(string: imageName[0])
            imageView.kf.setImage(with: url)
            self.addSubview(imageView)
        }
    }
    //轮播图点击事件
    @objc func tapGestureRecognizer(sender: UITapGestureRecognizer){
        let view = sender.view
        let tag = view?.tag
        if tag == 200{
            let urlStr = "http://www.geeetech.com/"
            let url = URL(string: urlStr)
            
            if #available(iOS 10, *){
                UIApplication.shared.open(url!, options: [:], completionHandler: {(success) in})
            } else {
                UIApplication.shared.openURL(url!)
            }
        }
    }
}

//could页面
class couldScrollView: UIScrollView, UIScrollViewDelegate {
    
    //屏幕宽度
    let width = UIScreen.main.bounds.size.width
    //轮播图
    let src = ZYF_MyScrollView()
    let page = UIPageControl()
    //轮播图列表
    var imageNameList:[String]?
    //图片高度
    var viewChildHeight = CGFloat()
    //创建view的高度
    var creatViewHeight = CGFloat()
    
    var targetController = UIViewController()
    //创建couldview
    func creatCouldScrollView(imageNames: [String], width: CGFloat, height: CGFloat, target: UIViewController){
        //获取模型库id
//        let url = Url.basePath + "/v1/modelbase/categories"
//        AlamofireCustom.alamofireManager.request(url, method: .get).responseJSON{(response) in
//            if response.result.isFailure{
//                creatView()
//                return
//            }
//            let code = response.response?.statusCode
//            if code == 200{
//                PersonInfo.Var.modelID.removeAll()
//                PersonInfo.Var.modelName.removeAll()
//                let json = JSON(response.result.value)
//                for i in 0...(json.count - 1){
//                    print("========= count ========", PersonInfo.Var.modelName.count)
//                    if PersonInfo.Var.modelID.count > 0{
//                        var isExist = true
//                        for j in 0...(PersonInfo.Var.modelID.count - 1){
//                            //print(PersonInfo.Var.modelID[j], json[i]["category_id"].stringValue)
//                            if PersonInfo.Var.modelID[j] == json[i]["category_id"].stringValue{
//                                isExist = true
//                                break
//                            } else{
//                                isExist = false
//                            }
//                        }
//                        if isExist{
//                            return
//                        }
//                        print(json[i]["category_name"].stringValue)
//                        PersonInfo.Var.modelID.append(json[i]["category_id"].stringValue)
//                        PersonInfo.Var.modelName.append(json[i]["category_name"].stringValue)
//                    } else{
//                        print(i,json[i]["category_id"].stringValue, json[i]["category_name"].stringValue)
//                        PersonInfo.Var.modelID.append(json[i]["category_id"].stringValue)
//                        PersonInfo.Var.modelName.append(json[i]["category_name"].stringValue)
//                    }
//                }
//                creatView()
//            }
//        }
//        self.targetController = target
//        self.creatViewHeight = height
//
//        self.addSubview(view)
        //获取轮播图
//        self.imageNameList = imageNames
//        self.src.creatMyScrollView(imageName: imageNames, height: 200)
//        self.src.delegate = self
        //轮播图容器
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 200))
//        view.addSubview(self.src)
//        self.page.frame = CGRect(x: width/2-50, y: 160, width: 100, height: 30)
//        self.page.numberOfPages = imageNames.count
//        view.insertSubview(self.page, aboveSubview: self.src)
//        self.addSubview(view)
        //self.creatTimer()
        func creatView(){
            imageNameList = imageNames
            
            targetController = target
            creatViewHeight = height
            src.creatMyScrollView(imageName: imageNames, height: 200)
            src.delegate = self
            //轮播图容器
            let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 200))
            view.addSubview(src)
            page.frame = CGRect(x: width/2-50, y: 160, width: 100, height: 30)
            page.numberOfPages = imageNames.count
            view.insertSubview(page, aboveSubview: src)
            self.addSubview(view)
            creatTimer()
            //图片高度
            let imgHeight = CGFloat(120)
            viewChildHeight = imgHeight
            //50000 model image
            let imageUn = UIImageView()
            imageUn.isUserInteractionEnabled = true
            imageUn.frame = CGRect(x: 0, y: 208, width: width, height: 60)
            imageUn.image = UIImage(named: "icon_app_model")
            let tap = UITapGestureRecognizer(target: self, action: #selector(skipToChoose(sender:)))
            imageUn.addGestureRecognizer(tap)
            self.addSubview(imageUn)
            
            let imageModel = UIView()
            imageModel.frame = CGRect(x: 0, y: 276, width: width, height: 350)
            let imageModelList = ["icon_fashion", "icon_3d_print", "icon_gadget", "icon_hobby", "icon_household", "icon_tools", "icon_toys_games", "icon_education", "icon_art"]
            var imageModelName = ["3D Print", "Art", "Education", "Fashion", "Gadget", "Hobby", "Household", "Tools", "Toys&Games"]
            if PersonInfo.Var.modelName.count == imageModelList.count{
                imageModelName = PersonInfo.Var.modelName
            } else{
                imageModelName = ["3D Print", "Art", "Fashion", "Gadget", "Hobby", "Household", "Tools", "Toys&Games", "Education"]
            }
            for i in 0...(imageModelList.count - 1){
                let view = UIView()
                let model = UIImageView()
                let label = UILabel()
                let a = (width/3 - 90)/2
                if i < 3{
                    view.frame = CGRect(x: width/3 * CGFloat(i), y: 4, width: width/3, height: 110)
                } else if i > 5{
                    view.frame = CGRect(x: width/3 * CGFloat(i - 6), y: 240, width: width/3, height: 110)
                } else{
                    view.frame = CGRect(x: width/3 * CGFloat(i - 3), y: 122, width: width/3, height: 110)
                }
                model.frame = CGRect(x: a, y: 0, width: 90, height: 90)
                label.frame = CGRect(x: a, y: 90, width: 90, height: 20)
                
                model.image = UIImage(named: imageModelList[i])
                label.text = imageModelName[i]
                label.font = UIFont.systemFont(ofSize: 14)
                
                label.textAlignment = NSTextAlignment.center
                view.addSubview(model)
                view.addSubview(label)
                view.tag = i
                let tap = UITapGestureRecognizer(target: self, action: #selector(skipToDetail(sender:)))
                view.addGestureRecognizer(tap)
                imageModel.addSubview(view)
            }
            imageModel.backgroundColor = UIColor.white
            self.addSubview(imageModel)
            //设置容量
            self.contentSize = CGSize(width: width, height: 622)  //622
            self.frame = CGRect(x: 0, y: 0, width: width, height: height)
            
            //设置吸附属性
            self.bounces = true
            //滑动协议
            self.delegate = self
            //设置书页效果
            //self.isPagingEnabled = true
        }
        creatView()
        
    }
    @objc func skipToDetail(sender: UITapGestureRecognizer){
        //#if DEBUG
        let view = sender.view
        let tag = view?.tag
        let event = String(tag!)
        targetController.performSegue(withIdentifier: "modelList", sender: event)
        //#else
        //targetController.present(Alert().singleAlert(message: "The cloud gallery is under development."), animated: true, completion: nil)
        //#endif
    }
    @objc func skipToChoose(sender: UITapGestureRecognizer){
//        #if DEBUG
//        let view = sender.view
//        let tag = view?.tag
//        let event = String(tag!)
//        targetController.performSegue(withIdentifier: "chooseFile", sender: event)
//        #else
//        #endif
    }
    //创建轮播图定时器
    func creatTimer(){
        let timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(timerManager), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .commonModes)
    }
    //创建定时器管理者
    @objc func timerManager(){
        src.setContentOffset(CGPoint(x: src.contentOffset.x + width, y: 0), animated: true)
        if src.contentOffset.x == CGFloat(width) * CGFloat((imageNameList?.count)!){
            src.contentOffset = CGPoint(x: 0, y: 0)
        }
    }
    var cnt = 0
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        if scrollView == src{
            let cPage = src.contentOffset.x / width
            page.currentPage = Int(cPage)
            cnt = Int(cPage)
        }
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView){
        if scrollView == src{
            cnt += 1
            page.currentPage = cnt % (imageNameList?.count)!
            cnt = page.currentPage
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == src {
            
        }
    }
}
