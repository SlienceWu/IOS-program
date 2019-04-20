//
//  ViewController.swift
//  Easyprint
//
//  Created by app on 2018/5/11.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // 主页导航控制器
    var mainNavigationController: UINavigationController!
    
    // 主页面控制器
    var mainViewController: UITabBarController!
    
    // 菜单页控制器
    var menuViewController: MenuViewControll?
    // 菜单页当前状态
    var currentState = MenuState.Collapsed {
        didSet {
            //菜单展开的时候，给主页面边缘添加阴影
            let shouldShowShadow = currentState != .Collapsed
            showShadowForMainViewController(shouldShowShadow: shouldShowShadow)
        }
    }
    // 菜单打开后主页在屏幕右侧露出部分的宽度
    let menuViewExpandedOffset: CGFloat = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //初始化主视图
        mainNavigationController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "mainNavigation")
            as! UINavigationController
        self.addChildViewController(mainNavigationController)
        view.addSubview(mainNavigationController.view)
        //指定Navigation Bar左侧按钮的事件
        mainViewController = mainNavigationController.viewControllers.first
            as! UITabBarController
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_menu_on")?.scaleImage(scaleSize: 0.15), style: .plain, target: self, action: #selector(showMenu))
        leftBar.tintColor = UIColor.white
        let tab = self.childViewControllers[0].childViewControllers[0] as! UITabBarController
        let tabPrint = tab.childViewControllers[0].childViewControllers[0]
        tabPrint.navigationItem.leftBarButtonItem = leftBar
        //mainViewController.viewControllers![0].navigationItem.leftBarButtonItem = leftBar
        //?.action = #selector(showMenu)
        
        //添加拖动手势
        let panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                          action: #selector(handlePanGesture(_:)))
        mainNavigationController.view.addGestureRecognizer(panGestureRecognizer)
        
        //单击收起菜单手势
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
//                                                          action: #selector(handleTapGesture))
//        mainNavigationController.view.addGestureRecognizer(tapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //导航栏左侧按钮事件响应
    @objc func showMenu() {
        //如果菜单是展开的则会收起，否则就展开
        if currentState == .Expanded {
            animateMainView(shouldExpand: false)
        }else {
            addMenuViewController()
            animateMainView(shouldExpand: true)
        }
    }
    
    //拖动手势响应
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        if !PersonInfo.Var.isOpenCH{
            return
        }
        switch(recognizer.state) {
        // 刚刚开始滑动
        case .began:
            // 判断拖动方向
            let dragFromLeftToRight = (recognizer.velocity(in: view).x > 0)
            // 如果刚刚开始滑动的时候还处于主页面，从左向右滑动加入侧面菜单
            if (currentState == .Collapsed && dragFromLeftToRight) {
                currentState = .Expanding
                addMenuViewController()
            }
            
        // 如果是正在滑动，则偏移主视图的坐标实现跟随手指位置移动
        case .changed:
            let positionX = recognizer.view!.frame.origin.x +
                recognizer.translation(in: view).x
            //页面滑到最左侧的话就不许要继续往左移动
            recognizer.view!.frame.origin.x = positionX < 0 ? 0 : positionX
            recognizer.setTranslation(.zero, in: view)
            
        // 如果滑动结束
        case .ended:
            //根据页面滑动是否过半，判断后面是自动展开还是收缩
            let hasMovedhanHalfway = recognizer.view!.center.x > view.bounds.size.width
            animateMainView(shouldExpand: hasMovedhanHalfway)
        default:
            break
        }
    }
    
    //单击手势响应
    @objc func handleTapGesture() {
        //如果菜单是展开的点击主页部分则会收起
        if currentState == .Expanded {
            animateMainView(shouldExpand: false)
        }
    }
    
    // 添加菜单页
    func addMenuViewController() {
        if (menuViewController == nil) {
            menuViewController = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "menuView")
                as? MenuViewControll
            
            // 插入当前视图并置顶
            view.insertSubview(menuViewController!.view, at: 0)
            
            // 建立父子关系
            addChildViewController(menuViewController!)
            menuViewController!.didMove(toParentViewController: self)
        }
    }
    
    //主页自动展开、收起动画
    func animateMainView(shouldExpand: Bool) {
        // 如果是用来展开
        if (shouldExpand) {
            // 更新当前状态
            currentState = .Expanded
            // 动画
            animateMainViewXPosition(targetPosition:
                mainNavigationController.view.frame.width - menuViewExpandedOffset)
            //单击收起菜单手势
            print("add tap",mainNavigationController.view)
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
            mainNavigationController.view.addGestureRecognizer(tapGestureRecognizer)
            
            let tab = self.childViewControllers[0].childViewControllers[0] as! UITabBarController
            let tabPrint = tab.childViewControllers[0].childViewControllers[0]
            tabPrint.navigationItem.leftBarButtonItem?.image = UIImage(named: "icon_menu_off")?.scaleImage(scaleSize: 0.15)
        }
            // 如果是用于隐藏
        else {
            // 动画
            animateMainViewXPosition(targetPosition: 0) { finished in
                // 动画结束之后s更新状态
                self.currentState = .Collapsed
                // 移除左侧视图
                self.menuViewController?.view.removeFromSuperview()
                // 释放内存
                self.menuViewController = nil;
            }
            //轮询并删除手势 否则tabbottom点击失效
            print("delete tap")
            let gestures = mainNavigationController.view.gestureRecognizers
            for gesture in gestures! //get one by one
            {
                mainNavigationController.view.removeGestureRecognizer(gesture) //remove gesture one by one
            }
            //添加拖动手势
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
            mainNavigationController.view.addGestureRecognizer(panGestureRecognizer)
            
            let tab = self.childViewControllers[0].childViewControllers[0] as! UITabBarController
            let tabPrint = tab.childViewControllers[0].childViewControllers[0]
            tabPrint.navigationItem.leftBarButtonItem?.image = UIImage(named: "icon_menu_on")?.scaleImage(scaleSize: 0.15)
            tabPrint.navigationItem.title = PersonInfo.Var.currentMachineName
        }
    }
    
    //主页移动动画（在x轴移动）
    func animateMainViewXPosition(targetPosition: CGFloat,
                                  completion: ((Bool) -> Void)! = nil) {
        //usingSpringWithDamping：1.0表示没有弹簧震动动画
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                        self.mainNavigationController.view.frame.origin.x = targetPosition
        }, completion: completion)
    }
    
    //给主页面边缘添加、取消阴影
    func showShadowForMainViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            //mainNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            //mainNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
    
}
// 菜单状态枚举
enum MenuState {
    case Collapsed  // 未显示(收起)
    case Expanding   // 展开中
    case Expanded   // 展开
}
