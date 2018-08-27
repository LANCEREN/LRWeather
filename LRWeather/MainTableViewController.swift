//
//  MainTableViewController.swift
//
// Copyright (c) 21/12/15. Ramotion Inc. (http://ramotion.com)
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

import FoldingCell
import UIKit
import Hero
import CoreData
import CoreLocation

class MainTableViewController: UITableViewController {
    
    var currLocation : CLLocation!//当前位置(经纬度)
    let locationManager:CLLocationManager = CLLocationManager()//位置管理器
    var fc : NSFetchedResultsController<CityInfo>! //coredata库的城市列表
    var cityInfos : [CityInfo] = [] //收藏的城市信息（暂存）
    var locationcity : String = ""//当前位置城市
    var cityInfo: String = ""//需要显示的城市信息
    
    var CellNumber : Dictionary<Int,Int>?//两种cell的数量字典
    
    enum Const {
        static let closeCellHeight: CGFloat = 179
        static let openCellHeight: CGFloat = 488
        static let rowsCount = 10
    }
    var cellHeights: [CGFloat] = []
    
    override func viewDidLoad() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5000
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        self.CellNumber = [0:1,1:cityInfos.count]
        self.hero.isEnabled = true
        
        super.viewDidLoad()
        fetchAllCityInfos()
        setup()
        
    }

    @IBAction func buttonjump(_ sender: Any) {
        let view = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let cityView = view.instantiateViewController(withIdentifier: "WeatherView")
        cityView.hero.modalAnimationType = .selectBy(presenting: .pageOut(direction: .left), dismissing: .pageIn(direction: .right))
        self.present(cityView, animated: true, completion: nil)
        print("tap to WeatherViewController")
    }
    
    private func setup() {
        loadingview()
        cellHeights = Array(repeating: Const.closeCellHeight, count: Const.rowsCount)
        tableView.estimatedRowHeight = Const.closeCellHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        tableView.separatorStyle = .none
        if #available(iOS 10.0, *) {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(self, action: #selector(refreshHandler), for: .valueChanged)
        }
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
}

