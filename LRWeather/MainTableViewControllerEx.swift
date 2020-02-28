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
            GetWeatherData(cityid: locationcityid,row: -1)
            cell.UpdateTimeLabel.text = todayWeatherDictionary[0]?[0]
            cell.FeelLabel.text = todayWeatherDictionary[0]?[1]
            cell.FeelLabel2.text = todayWeatherDictionary[0]?[1]
            cell.MaxTemp.text = todayWeatherDictionary[0]?[2]
            cell.MinTemp.text = todayWeatherDictionary[0]?[3]
            cell.tips.text = todayWeatherDictionary[0]?[4]
            cell.Date.text = todayWeatherDictionary[0]?[5]
            cell.AQI.text = todayWeatherDictionary[0]?[6]
            cell.HUmidity.text = todayWeatherDictionary[0]?[7]
            cell.RainPop.text = todayWeatherDictionary[0]?[8]
            cell.DayWeather.text = todayWeatherDictionary[0]?[9]
            cell.NightWeather.text = todayWeatherDictionary[0]?[10]
            cell.DayWindli.text = todayWeatherDictionary[0]?[11]
            cell.NightWindLi.text = todayWeatherDictionary[0]?[12]
            cell.DayWindXiang.text = todayWeatherDictionary[0]?[13]
            cell.NightWindXiang.text = todayWeatherDictionary[0]?[14]
        case 1:
            cell.LocationImage1.image = .none
            cell.LocationImage2.image = .none
            if cityInfos.count != 0{
                cell.CellCityInfo = cityInfos[indexPath.row].city!
                GetWeatherData(cityid: cityInfos[indexPath.row].id!,row: indexPath.row)
                cell.UpdateTimeLabel.text = todayWeatherDictionary[indexPath.row]?[0]
                cell.FeelLabel.text = todayWeatherDictionary[indexPath.row]?[1]
                cell.FeelLabel2.text = todayWeatherDictionary[indexPath.row]?[1]
                cell.MaxTemp.text = todayWeatherDictionary[indexPath.row]?[2]
                cell.MinTemp.text = todayWeatherDictionary[indexPath.row]?[3]
                cell.tips.text = todayWeatherDictionary[indexPath.row]?[4]
                cell.Date.text = todayWeatherDictionary[indexPath.row]?[5]
                cell.AQI.text = todayWeatherDictionary[indexPath.row]?[6]
                cell.HUmidity.text = todayWeatherDictionary[indexPath.row]?[7]
                cell.RainPop.text = todayWeatherDictionary[indexPath.row]?[8]
                cell.DayWeather.text = todayWeatherDictionary[indexPath.row]?[9]
                cell.NightWeather.text = todayWeatherDictionary[indexPath.row]?[10]
                cell.DayWindli.text = todayWeatherDictionary[indexPath.row]?[11]
                cell.NightWindLi.text = todayWeatherDictionary[indexPath.row]?[12]
                cell.DayWindXiang.text = todayWeatherDictionary[indexPath.row]?[13]
                cell.NightWindXiang.text = todayWeatherDictionary[indexPath.row]?[14]
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
//        self.getCityData(nowCity: "西安")
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
                        let id = sortedKeysAndValues[i].value["cityid"].string!
                        if city == nowCity {
                            if appDelegate.cityInfo == "" {
                                //将当前定位到的城市名存储到appDelegate中进行传值
                                appDelegate.locationCity = city
                                appDelegate.locationCityID = id
                                self.locationcity = appDelegate.locationCity
                                self.locationcityid = appDelegate.locationCityID
                                print("当前城市为\(self.locationcity)，Id为\(self.locationcityid)")
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
        //FIXME:width
        loadingView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(weatherSize.screen_w)
            make.height.equalTo(weatherSize.screen_h)
            make.center.equalTo(self.view)
        }
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
        cellHeights = Array(repeating: Const.closeCellHeight, count: Const.rowsCount)
    }
    func GetWeatherData(cityid:String, row:Int){
        
        func WeatherForecast24hours(cityId: String){
            let appcode:String = "278b38b210f447618a576b9f3bb051ae"
            let host:String = "http://aliv18.data.moji.com"
            let path:String = "/whapi/json/alicityweather/forecast24hours"
            let method = "POST"
            let querys = ""
            let url = NSURL(string:host+path+querys)
            let bodys = "cityId=\(cityId)&token=008d2ad9197090c5dddc76f583616606"
            var request = URLRequest(url: url! as URL)
            let bodydata:Data = bodys.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            
            request.httpBody = bodydata
            request.httpMethod = method
            request.addValue("APPCODE \(appcode)", forHTTPHeaderField: "Authorization")
            request.addValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            print(request.allHTTPHeaderFields)
            print(NSString(data: request.httpBody!, encoding: String.Encoding.utf8.rawValue))
            print("当前数据：提供未来24小时逐小时天气预报")
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                if error == nil{
                    do{
                        let json = try JSON(data: data!)
                        self.WeatherCond = json["data"]["hourly"][1]["condition"].string!
                        self.TempCur = json["data"]["hourly"][1]["temp"].string!
                        self.CityName = json["data"]["city"]["name"].string!
                        self.Humidity = json["data"]["hourly"][1]["humidity"].string!
                        self.RainPop = json["data"]["hourly"][1]["pop"].string!
                        self.Rain = json["data"]["hourly"][1]["qpf"].string!
                        self.AirPress = json["data"]["hourly"][1]["pressure"].string!
                    }
                    catch{
                        print("Error creating the database")
                    }
                }
                else {
                    print(error!)
                }
            }
            task.resume()
        }
        
        func CArLimit(cityId: String){
            let appcode:String = "278b38b210f447618a576b9f3bb051ae"
            let host:String = "http://aliv18.data.moji.com"
            let path:String = "/whapi/json/alicityweather/limit"
            let method = "POST"
            let querys = ""
            let url = NSURL(string:host+path+querys)
            let bodys = "cityId=\(cityId)&token=27200005b3475f8b0e26428f9bfb13e9"
            var request = URLRequest(url: url! as URL)
            let bodydata:Data = bodys.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            
            request.httpBody = bodydata
            request.httpMethod = method
            request.addValue("APPCODE \(appcode)", forHTTPHeaderField: "Authorization")
            request.addValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            print("当前数据：提供各地限行数据")
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                if error == nil{
                    do{
                        let json = try JSON(data: data!)
                        print(json)
                        
                    }
                    catch{
                        print("Error creating the database")
                    }
                }
                else {
                    print(error!)
                }
            }
            task.resume()
        }
        
        func WeatherAqiNow(cityId: String){
            let appcode:String = "278b38b210f447618a576b9f3bb051ae"
            let host:String = "http://aliv18.data.moji.com"
            let path:String = "/whapi/json/alicityweather/aqi"
            let method = "POST"
            let querys = ""
            let url = NSURL(string:host+path+querys)
            let bodys = "cityId=\(cityId)&token=8b36edf8e3444047812be3a59d27bab9"
            var request = URLRequest(url: url! as URL)
            let bodydata:Data = bodys.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            
            request.httpBody = bodydata
            request.httpMethod = method
            request.addValue("APPCODE \(appcode)", forHTTPHeaderField: "Authorization")
            request.addValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            print("当前数据：提供空气质量指数及分项数据")
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                if error == nil{
                    do{
                        let json = try JSON(data: data!)
                        self.aqi = json["data"]["aqi"]["value"].string!
                        self.PM2_5 = json["data"]["aqi"]["pm25"].string!
                    }
                    catch{
                        print("Error creating the database")
                    }
                }
                else {
                    print(error!)
                }
            }
            task.resume()
        }
        
        func WeatherAqiForecast5days(cityId: String){
            let appcode:String = "278b38b210f447618a576b9f3bb051ae"
            let host:String = "http://aliv18.data.moji.com"
            let path:String = "/whapi/json/alicityweather/aqiforecast5days"
            let method = "POST"
            let querys = ""
            let url = NSURL(string:host+path+querys)
            let bodys = "cityId=\(cityId)&token=0418c1f4e5e66405d33556418189d2d0"
            var request = URLRequest(url: url! as URL)
            let bodydata:Data = bodys.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            
            request.httpBody = bodydata
            request.httpMethod = method
            request.addValue("APPCODE \(appcode)", forHTTPHeaderField: "Authorization")
            request.addValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            print("当前数据：提供未来5天AQI数据")
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                if error == nil{
                    do{
                        let json = try JSON(data: data!)
                        self.date = json["data"]["aqiForecast"][1]["date"].string!
                    }
                    catch{
                        print("Error creating the database")
                    }
                }
                else {
                    print(error!)
                }
            }
            task.resume()
        }
        
        func WeatherForecast15days(cityId: String){
            let appcode:String = "278b38b210f447618a576b9f3bb051ae"
            let host:String = "http://aliv18.data.moji.com"
            let path:String = "/whapi/json/alicityweather/forecast15days"
            let method = "POST"
            let querys = ""
            let url = NSURL(string:host+path+querys)
            let bodys = "cityId=\(cityId)&token=f9f212e1996e79e0e602b08ea297ffb0"
            var request = URLRequest(url: url! as URL)
            let bodydata:Data = bodys.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            
            request.httpBody = bodydata
            request.httpMethod = method
            request.addValue("APPCODE \(appcode)", forHTTPHeaderField: "Authorization")
            request.addValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            print("当前数据：提供未来15天天气预报")
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                if error == nil{
                    do{
                        let json = try JSON(data: data!)
                        self.TempDay = json["data"]["forecast"][1]["tempDay"].string!
                        self.TempNight = json["data"]["forecast"][1]["tempNight"].string!
                        self.TempAll = self.TempDay+"/"+self.TempNight
                        self.WeatherCondDay = json["data"]["forecast"][1]["conditionDay"].string!
                        self.WeatherCondNight = json["data"]["forecast"][1]["conditionNight"].string!
                        self.WindDirDay = json["data"]["forecast"][1]["windDirDay"].string!
                        self.WindLevelDay = json["data"]["forecast"][1]["windLevelDay"].string!
                        self.WindSpeedDay = json["data"]["forecast"][1]["windSpeedDay"].string!
                        self.WindDirNight = json["data"]["forecast"][1]["windDirNight"].string!
                        self.WindLevelNight = json["data"]["forecast"][1]["windLevelNight"].string!
                        self.WindSpeedNight = json["data"]["forecast"][1]["windSpeedNight"].string!
                        //MoonPhase = json["data"]["forecast"][1]["windSpeedNight"].string!
                        self.MoonRise = json["data"]["forecast"][1]["moonrise"].string!
                        self.MoonSet = json["data"]["forecast"][1]["moonset"].string!
                    }
                    catch{
                        print("Error creating the database")
                    }
                }
                else {
                    print(error!)
                }
            }
            task.resume()
        }
        
        func WeatherCurrentCondition(cityId: String){
            let appcode:String = "278b38b210f447618a576b9f3bb051ae"
            let host:String = "http://aliv18.data.moji.com"
            let path:String = "/whapi/json/alicityweather/condition"
            let method = "POST"
            let querys = ""
            let url = NSURL(string:host+path+querys)
            let bodys = "cityId=\(cityId)&token=50b53ff8dd7d9fa320d3d3ca32cf8ed1"
            var request = URLRequest(url: url! as URL)
            let bodydata:Data = bodys.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            
            request.httpBody = bodydata
            request.httpMethod = method
            request.addValue("APPCODE \(appcode)", forHTTPHeaderField: "Authorization")
            request.addValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            print("当前数据：提供温度、湿度、风向、风速、紫外线、气压、体感温度等实时数据")
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                if error == nil{
                    do{
                        let json = try JSON(data: data!)
                        self.WindDirNow = json["data"]["condition"]["windDir"].string!
                        self.WindLevelNow = json["data"]["condition"]["windLevel"].string!
                        self.WindSpeedNow = json["data"]["condition"]["windSpeed"].string!
                        self.updateTime = json["data"]["condition"]["updatetime"].string!
                        self.tips = json["data"]["condition"]["tips"].string!
                    }
                    catch{
                        print("Error creating the database")
                    }
                }
                else {
                    print(error!)
                }
            }
            task.resume()
        }
        
        func LifeIndex(cityId: String){
            let appcode:String = "278b38b210f447618a576b9f3bb051ae"
            let host:String = "http://aliv18.data.moji.com"
            let path:String = "/whapi/json/alicityweather/index"
            let method = "POST"
            let querys = ""
            let url = NSURL(string:host+path+querys)
            let bodys = "cityId=\(cityId)&token=5944a84ec4a071359cc4f6928b797f91"
            var request = URLRequest(url: url! as URL)
            let bodydata:Data = bodys.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            
            request.httpBody = bodydata
            request.httpMethod = method
            request.addValue("APPCODE \(appcode)", forHTTPHeaderField: "Authorization")
            request.addValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            print("当前数据：提供各项天气生活指数")
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                if error == nil{
                    do{
                        let json = try JSON(data: data!)
                        self.uv = json["data"]["liveIndex"]["\(self.date)"][0]["status"].string!
                        self.uvindex = json["data"]["liveIndex"]["\(self.date)"][0]["level"].string!
                        self.uvtips = json["data"]["liveIndex"]["\(self.date)"][0]["desc"].string!
                        self.ct = json["data"]["liveIndex"]["\(self.date)"][0]["desc"].string!
                        
                    }
                    catch{
                        print("Error creating the database")
                    }
                }
                else {
                    print(error!)
                }
            }
            task.resume()
        }
        
        func WeatherAlert(cityId: String){
            let appcode:String = "278b38b210f447618a576b9f3bb051ae"
            let host:String = "http://aliv18.data.moji.com"
            let path:String = "/whapi/json/alicityweather/alert"
            let method = "POST"
            let querys = ""
            let url = NSURL(string:host+path+querys)
            let bodys = "cityId=\(cityId)&token=7ebe966ee2e04bbd8cdbc0b84f7f3bc7"
            var request = URLRequest(url: url! as URL)
            let bodydata:Data = bodys.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            
            request.httpBody = bodydata
            request.httpMethod = method
            request.addValue("APPCODE \(appcode)", forHTTPHeaderField: "Authorization")
            request.addValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            print("当前数据：提供各地天气预警信息")
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in
                if error == nil{
                    do{
                        let json = try JSON(data: data!)
                        guard let alert = json["data"]["alert"]["content"].string
                            else{
                                self.Alert = "None"
                                return
                        }
                        self.Alert = alert
                    }
                    catch{
                        print("Error creating the database")
                    }
                }
                else {
                    print(error!)
                }
            }
            task.resume()
        }
        if row == -1 {
            self.todayWeatherArrayloc.append(updateTime)
            self.todayWeatherArrayloc.append(TempCur)
            self.todayWeatherArrayloc.append(TempDay)
            self.todayWeatherArrayloc.append(TempNight)
            self.todayWeatherArrayloc.append(tips)
            self.todayWeatherArrayloc.append(date)
            self.todayWeatherArrayloc.append(aqi)
            self.todayWeatherArrayloc.append(Humidity)
            self.todayWeatherArrayloc.append(RainPop)
            self.todayWeatherArrayloc.append(WeatherCondDay + "白天温度：" + TempDay)
            self.todayWeatherArrayloc.append(WeatherCondNight + "夜间温度：" + TempNight)
            self.todayWeatherArrayloc.append(WindLevelDay + "风速：" + WindSpeedDay)
            self.todayWeatherArrayloc.append(WindLevelNight + "风速：" + WindSpeedNight)
            self.todayWeatherArrayloc.append(WindDirDay)
            self.todayWeatherArrayloc.append(WindDirNight)
            self.todayWeatherDictionaryloc[0] = self.todayWeatherArray
            self.todayWeatherArrayloc = []
        }
        else{
            self.todayWeatherArray.append(updateTime)
            self.todayWeatherArray.append(TempCur)
            self.todayWeatherArray.append(TempDay)
            self.todayWeatherArray.append(TempNight)
            self.todayWeatherArray.append(tips)
            self.todayWeatherArray.append(date)
            self.todayWeatherArray.append(aqi)
            self.todayWeatherArray.append(Humidity)
            self.todayWeatherArray.append(RainPop)
            self.todayWeatherArray.append(WeatherCondDay + "白天温度：" + TempDay)
            self.todayWeatherArray.append(WeatherCondNight + "夜间温度：" + TempNight)
            self.todayWeatherArray.append(WindLevelDay + "风速：" + WindSpeedDay)
            self.todayWeatherArray.append(WindLevelNight + "风速：" + WindSpeedNight)
            self.todayWeatherArray.append(WindDirDay)
            self.todayWeatherArray.append(WindDirNight)
            self.todayWeatherDictionary[row] = self.todayWeatherArray
            self.todayWeatherArray = []
            
        }
        
    }
}
