//
//  MainTableViewControllerEx.swift
//  LRWeather
//
//  Created by lance ren on 2018/8/27.
//  Copyright © 2018年 lanceren. All rights reserved.
//

import Foundation
import UIKit
import Hero
import FoldingCell
import CoreData
import CoreLocation

// MARK: - TableView

extension MainTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
        //return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.CellNumber![section]!
        //return self.CellNumber![1]!+1
    }
    
    override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as DemoCell = cell else {
            return
        }
        cell.backgroundColor = .clear
        switch indexPath.section {
        case 0:
            if LocalCellHeight == Const.closeCellHeight {
                cell.unfold(false, animated: false, completion: nil)
            } else {
                cell.unfold(true, animated: false, completion: nil)
            }
        case 1:
            if cellHeights[indexPath.row] == Const.closeCellHeight {
                cell.unfold(false, animated: false, completion: nil)
            } else {
                cell.unfold(true, animated: false, completion: nil)
            }
        default:
            print("indexPath.section error，willDisplay超出范围")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoldingCell", for: indexPath) as! DemoCell
        let durations: [TimeInterval] = [0.26, 0.2, 0.2]
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations
        // 定义阴影颜色
        cell.Detail.layer.shadowColor = UIColor.gray.cgColor
        // 阴影的模糊半径
        cell.Detail.layer.shadowRadius = 2.4
        // 阴影的偏移量
        cell.Detail.layer.shadowOffset = CGSize(width: 0, height: 1)
        // 阴影的透明度，默认为0，不设置则不会显示阴影****
        cell.Detail.layer.shadowOpacity = 0.7
        
        switch indexPath.section {
        case 0:
            cell.LocationImage1.image = #imageLiteral(resourceName: "location")
            cell.LocationImage2.image = #imageLiteral(resourceName: "location")
            cell.CellCityInfo = locationcity
        case 1:
            cell.LocationImage1.image = .none
            cell.LocationImage2.image = .none
            if cityInfos.count != 0{
                cell.CellCityInfo = cityInfos[indexPath.row].city!
            }
        default:
            print("indexPath.section error，cellforRow超出范围")
        }
        return cell
    }
    
    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var cellheight: CGFloat = Const.closeCellHeight
        switch indexPath.section {
        case 0:
            cellheight = LocalCellHeight
        case 1:
            cellheight = cellHeights[indexPath.row]
        default:
            print("indexPath.section error，heightForRow超出范围")
        }
        return cellheight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        if cell.isAnimating() {
            return
        }
        var duration = 0.0
        switch indexPath.section {
        case 0:
            let cellIsCollapsed = LocalCellHeight == Const.closeCellHeight
            if cellIsCollapsed {
                LocalCellHeight = Const.openCellHeight
                cell.unfold(true, animated: true, completion: nil)
                duration = 0.5
            } else {
                LocalCellHeight = Const.closeCellHeight
                cell.unfold(false, animated: true, completion: nil)
                duration = 0.8
            }

        case 1:
            let cellIsCollapsed = cellHeights[indexPath.row] == Const.closeCellHeight
            if cellIsCollapsed {
                cellHeights[indexPath.row] = Const.openCellHeight
                cell.unfold(true, animated: true, completion: nil)
                duration = 0.5
            } else {
                cellHeights[indexPath.row] = Const.closeCellHeight
                cell.unfold(false, animated: true, completion: nil)
                duration = 0.8
            }

        default:
            print("indexPath.section error，didSelectRow超出范围")
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
    }
    
//    //FIXME:滑动删除莫名BUG
//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let ActionDel: UIContextualAction
//
//        if indexPath.section == 1{
//
//            let actionDel = UIContextualAction(style: .destructive, title: "删除") { (action, view, finished) in
//
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            let context = appDelegate.persistentContainer.viewContext
//            //删除数据源
//            context.delete(self.fc.object(at: indexPath))
//            appDelegate.saveContext()
//
//            //print(self.fc.fetchedObjects![indexPath.row])
//            finished(true)
//            }
//            actionDel.backgroundColor = UIColor(named: "w_red")
//            ActionDel = actionDel
//        }
//        else{
//            let actionDel = UIContextualAction(style: .destructive, title: "收藏") { (action, view, finished) in
//
//                let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                let context = appDelegate.persistentContainer.viewContext
//                //判断并添加数据源
//
//                appDelegate.saveContext()
//
//                //print(self.fc.fetchedObjects![indexPath.row])
//                finished(true)
//                }
//            actionDel.backgroundColor = UIColor(named: "w_blue")
//            ActionDel = actionDel
//
//        }
//        return UISwipeActionsConfiguration(actions: [ActionDel])
//    }
//
//    //tableView变化的相关方法 配合滑动删除手势
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        self.tableView.beginUpdates()
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        self.tableView.endUpdates()
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .delete:
//            tableView.deleteRows(at: [indexPath!], with: .automatic)
//        case .insert:
//            tableView.insertRows(at: [newIndexPath!], with: .automatic)
//        case .update:
//            tableView.reloadRows(at: [indexPath!], with: .automatic)
//        default:
//            tableView.reloadData()
//        }
//
//        if let object = controller.fetchedObjects {
//            cityInfos = object as! [CityInfo]
//        }
//    }
    

}

//MARK: - coredata protocol实现
extension MainTableViewController: NSFetchedResultsControllerDelegate {
    ///使用fetch取回保存在CoreData中的数据
    func fetchAllCityInfos() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request : NSFetchRequest<CityInfo> = CityInfo.fetchRequest()
        //设置取回后的排序方式
        let sortDescriptors = NSSortDescriptor(key: "order", ascending: true)
        request.sortDescriptors = [sortDescriptors]
        
        fc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fc.delegate = self
        
        do {
            
            try fc.performFetch()
            if let object = fc.fetchedObjects {
                cityInfos = object
                print ("取回成功,现在收藏了\(cityInfos.count)个城市")
            }
            
        } catch {
            print ("取回失败")
        }
        BasicDataSet()
        //tableView.reloadData()
    }
}

//MARK:重点定位当前城市

extension MainTableViewController: CLLocationManagerDelegate {
    //实现delegate方法
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.cityInfo == "" {
            self.currLocation = locations.last
            let geoCoder: CLGeocoder = CLGeocoder()
            //反编译将经纬度转化为城市
            geoCoder.reverseGeocodeLocation(locations.last!) { (marks, error) in
                if error == nil {
                    let mark: CLPlacemark = marks![0]
                    //获得城市名 为方便后续操作将“市”字删除
                    let city = mark.locality?.replacingOccurrences(of: "市", with: "")
                    self.getCityData(nowCity: city!)
                } else {
                    print("\(error!)")
                }
                if marks?.count == 0 {
                    return
                        print("marks.count == 0 ,error")
                }
            }
        }
    }
    ///获取全部城市名称信息
    func getCityData(nowCity: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //全部城市名称的json地址
        let path = "http://api.k780.com/?app=weather.city&appkey=35717&sign=089478792dfe3d89fcbf6f5333eda713&format=json"
        let url = NSURL(string: path)
        let request = URLRequest(url: url! as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    let json = try JSON(data: data!)
                    let count: Int = json["result"].count
                    let jsonDic = json["result"].dictionary!
                    let sortedKeysAndValues = jsonDic.sorted(by: { (d1, d2) -> Bool in
                        return d1 < d2 ? true : false
                    })
                    for i in 0..<count {
                        //遍历 将定位得到的城市名分别于列表中的城市进行对比 如果相同则获得该城市的信息 完成定位功能
                        let city = sortedKeysAndValues[i].value["citynm"].string!
                        let id = sortedKeysAndValues[i].value["weaid"].string!
                        if city == nowCity {
                            if appDelegate.cityInfo == "" {
                                //将当前定位到的城市名存储到appDelegate中进行传值
                                appDelegate.locationCity = city
                                appDelegate.locationCityID = id
                                self.locationcity = appDelegate.locationCity
                                self.locationcityid = appDelegate.locationCityID
                                print("当前城市为\(self.locationcity)")
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        if appDelegate.cityInfo == "" {
                            self.loadingAction()
                        }
                    }
                } catch {
                    print("Error creating the database")
                }
            } else {
                print(error!)
            }
        }
        task.resume()
    }
    ///加载预览界面动画
    //FIXME:用锁住tableview来盖住
    func loadingAction() {
        //正在加载的预览界面动画 在定位成功后隐藏 此动作为隐藏
        let loadingView = self.view.viewWithTag(121)
        UIView.animate(withDuration: 0.2, animations: {
            loadingView?.alpha = 0
        }) { (_) in
            loadingView?.isHidden = true
            self.tableView.isScrollEnabled = true
            self.tableView.reloadData()
        }
    }
}

//MARK:LoadingView加载数据页面
extension MainTableViewController {
    
    func loadingview(){
        //定位预加载view
        let loadingView = UIView(frame: self.view.frame)
        loadingView.tag = 121
        loadingView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.cityInfo != "" {
            loadingView.isHidden = true
        } else {
            loadingView.isHidden = false
        }
        self.view.addSubview(loadingView)
        let loadingLabel = UILabel(frame: CGRect(x: 0, y: 200, width: weatherSize.screen_w, height: 100))
        loadingLabel.text = "正在定位当前所在城市..."
        loadingLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        loadingLabel.textColor = UIColor.white
        loadingLabel.textAlignment = .center
        loadingView.addSubview(loadingLabel)
    }
}

//MARK: - 初始化数据
extension MainTableViewController {
    func BasicDataSet(){
        self.CellNumber = [0:1,1:cityInfos.count]
        Const.rowsCount = cityInfos.count
    }
}
