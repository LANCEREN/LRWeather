//
//  MainTableViewController.swift
//
// Copyright (c) Ramotion Inc. (http://ramotion.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//  LRWeather
//
//  Created by lance ren on 2018/8/27.
//  Copyright © 2018年 lanceren. All rights reserved.

import FoldingCell
import UIKit
import Hero
import CoreData
import CoreLocation

class MainTableViewController: UITableViewController {
    
    var currLocation: CLLocation!//当前位置(经纬度)
    let locationManager:CLLocationManager = CLLocationManager()//位置管理器
    var fc: NSFetchedResultsController<CityInfo>! //coredata库的城市列表
    var cityInfos: [CityInfo] = [] //收藏的城市信息（暂存）
    var locationcity: String = ""//当前位置城市用作label显示
    var locationcityid: String = ""//当前城市ID方便URL
    var cityInfo: String = ""//需要显示的城市信息
    var cityInfoid: String = ""//需要现实的城市信息id
    
    var CellNumber: Dictionary<Int,Int>?//两种cell的数量字典
    
    enum Const {
        static let closeCellHeight: CGFloat = 179
        static let openCellHeight: CGFloat = 488
        static var rowsCount = 10
    }
    var cellHeights: [CGFloat] = []//展开和折叠cell的高度
    var LocalCellHeight: CGFloat = 0//localcell的高度防止错误识别
    
    override func viewDidLoad() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5000
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        fetchAllCityInfos()
        
        self.hero.isEnabled = true
        
        super.viewDidLoad()
        setup()
        
        let notificationName = Notification.Name(rawValue: "cityNotification")
        NotificationCenter.default.addObserver(self, selector: #selector(dismissNotification(notification:)), name: notificationName, object: nil)
    }
    
    private func setup() {
        loadingview()
        self.tableView.isScrollEnabled = false
        cellHeights = Array(repeating: Const.closeCellHeight, count: Const.rowsCount)
        tableView.estimatedRowHeight = Const.closeCellHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        tableView.separatorStyle = .none//分割线消失
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(self, action: #selector(refreshHandler), for: .valueChanged)
        }
    }
    
    @objc func dismissNotification(notification: Notification){
        fetchAllCityInfos()
        tableView.reloadData()
    }
    
    
    @objc func refreshHandler() {
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: { [weak self] in
            if #available(iOS 10.0, *) {
                self?.tableView.refreshControl?.endRefreshing()
            }
            self?.tableView.reloadData()
        })
    }

    @IBAction func buttonjump(_ sender: Any) {
        
        let btn : UIButton = sender as! UIButton
        let cp : CGPoint = btn.convert(btn.bounds.origin, to: self.tableView)
        let indexpath = self.tableView.indexPathForRow(at: cp)
        if indexpath?.row == 0 {
            self.cityInfo = locationcity
            self.cityInfoid = locationcityid
        } else {
            self.cityInfo = cityInfos[indexpath!.row].city!
            self.cityInfoid = cityInfos[indexpath!.row].id!
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.cityInfo = self.cityInfo
        appDelegate.cityInfoID = self.cityInfoid
        
        let view = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let cityView = view.instantiateViewController(withIdentifier: "WeatherView")
        cityView.hero.modalAnimationType = .selectBy(presenting: .pageOut(direction: .left), dismissing: .pageIn(direction: .right))
        print("tap to WeatherViewController")
        self.present(cityView, animated: true, completion: nil)
    }
    
    @IBAction func AddJump(_ sender: Any) {
        let view = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let cityView = view.instantiateViewController(withIdentifier: "AddListView")
        cityView.hero.modalAnimationType = .selectBy(presenting: .fade, dismissing: .fade)
        print("tap to AddListViewController")
        self.present(cityView, animated: true, completion: nil)
    }
    
}

