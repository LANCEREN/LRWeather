//
//  WeatherViewController.swift
//  Weather
//
//  Created by 高鑫 on 2017/10/23.
//  Copyright © 2017年 高鑫. All rights reserved.
//

import UIKit
import SnapKit
import Hero
import CoreLocation
import MJRefresh

class WeatherViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {

    let locationManager:CLLocationManager = CLLocationManager()//位置管理器
    var cityInfo: String = ""//需要显示的城市信息
    var futureWeatherArray : [String] = [] //存放未来一周天气信息的数组
    var futureWeatherDictionary: Dictionary<String, [String]> = [:]  //存放未来一周天气信息的字典
    let todayDate = Date() //当前日期
    let formatter = DateFormatter() //格式转换变量
    var isNight : Bool? //白天or夜间
    var currLocation : CLLocation!//当前位置
    
    let header = MJRefreshNormalHeader() //刷新控件的基类
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var weatherInfoScrollView: UIScrollView!
    @IBAction func menuBtn(_ sender: UIButton) {
        //跳转列表
        let view = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let cityView = view.instantiateViewController(withIdentifier: "cityView")
        cityView.hero.modalAnimationType = .selectBy(presenting: .pageOut(direction: .up), dismissing: .pageIn(direction: .down))
        /*cityView.heroModalAnimationType = .selectBy(presenting: .pageOut(direction: .up), dismissing: .pageIn(direction: .down))*/
        self.present(cityView, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5000
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        //self.isHeroEnabled = true
        self.hero.isEnabled = true
        timeDayNight()
        if #available(iOS 11.0, *) {
            self.view.backgroundColor = isNight! ? UIColor(named: "w_nightblue") : UIColor(named: "w_lightblue")
        } else {
            // Fallback on earlier versions
        } //背景颜色
        bottomView.backgroundColor = self.view.backgroundColor
        self.weatherInfoScrollView.delegate = self
        header.setRefreshingTarget(self, refreshingAction: #selector(refresh))
        self.weatherInfoScrollView.mj_header = header //状态刷新栏
        header.stateLabel.textColor = UIColor.white
        header.stateLabel.isHidden = false
        header.lastUpdatedTimeLabel.textColor = UIColor.white
        header.lastUpdatedTimeLabel.isHidden = false
        
        setUI()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.cityInfo != "" {
            cityInfo = appDelegate.cityInfo
            self.getWeatherData()
            self.getFutureWeatherData()
            self.getLifeData()
            self.getPMData()
        }
        
        let notificationName = Notification.Name(rawValue: "cityNotification")
        NotificationCenter.default.addObserver(self, selector: #selector(dismissNotification(notification:)), name: notificationName, object: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func dismissNotification(notification: Notification){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.cityInfo != "" {
            cityInfo = appDelegate.cityInfo
            print("\(cityInfo)")
        } else {
            cityInfo = appDelegate.locationCityID
        }
        self.getWeatherData()
        self.getFutureWeatherData()
        self.getLifeData()
        self.getPMData()
    }
    
    @objc func refresh() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.cityInfo != "" {
            cityInfo = appDelegate.cityInfo
        }
        self.getWeatherData()
        self.getFutureWeatherData()
        self.getLifeData()
        self.getPMData()
        self.weatherInfoScrollView.mj_header.endRefreshing()
        let title = self.view.viewWithTag(101) as! UILabel
        UIView.animate(withDuration: 0.3) {
            title.alpha = 1
        }
    }
    
    ///判断是否为夜间 （18：00 ~ 6：00）
    func timeDayNight() {
        let todayStr = "\(todayDate)"
        //字符串切割，获得日期
        let index = todayStr.index(todayStr.startIndex, offsetBy: 10)
        let todayStrResult = todayStr[...index]
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let earlierDate = formatter.date(from: todayStrResult+" 18:00")! as NSDate
        //当前天数+1
        let calculatedDate = Calendar.current.date(byAdding: .day, value: 1, to: todayDate)
        let tomorrowStr = String(describing: calculatedDate!)
        let tomorrowIndex = tomorrowStr.index(tomorrowStr.startIndex, offsetBy: 10)
        let tomorrowStrResult = tomorrowStr[...tomorrowIndex]
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let laterDate = formatter.date(from: tomorrowStrResult+" 06:00")! as NSDate
        let early = earlierDate.laterDate(todayDate)
        let late = laterDate.earlierDate(todayDate)
        
        if early == late {
            isNight = true
        } else {
            isNight = false
        }
        
    }
    
    //MARK:未来七天天气代理
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FutureTableViewCell
        cell.backgroundColor = self.view.backgroundColor
        cell.selectionStyle = .none
        //字典降序排序
        let sortedKeysAndValues = self.futureWeatherDictionary.sorted(by: { (d1, d2) -> Bool in
            return d1.0 < d2.0 ? true : false
        })
        
        if futureWeatherDictionary.count == 0 {
            cell.weekLabel.text = "--"
        } else {
            cell.weekLabel.text = sortedKeysAndValues[indexPath.row].value[0]
        }
        
        if futureWeatherDictionary.count == 0 {
            cell.tempLabel.text = "--℃/--℃"
        } else {
            cell.tempLabel.text = sortedKeysAndValues[indexPath.row].value[2]
        }
        
        if indexPath.row == 0 {
            cell.weekLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
            cell.tempLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 17)
        } else {
            cell.weekLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16)
            cell.tempLabel.font = UIFont(name: "HelveticaNeue-Light", size: 17)
        }

        let weaPy = sortedKeysAndValues[indexPath.row].value[1].transformToPinYin()
        let zhuanStr = "zhuan"
        let range = weaPy.range(of: zhuanStr)
        if range == nil {
            let daoStr = "-"
            let daoRange = weaPy.range(of: daoStr)
            if daoRange == nil {
                cell.weaImg.image = UIImage(named: weaPy)
            } else {
                let daoPosition = weaPy.positionOf(sub: zhuanStr)
                let daoIndex = weaPy.index(weaPy.startIndex, offsetBy: daoPosition)
                let daoPositionResult = weaPy[daoIndex...]
                cell.weaImg.image = UIImage(named: "\(daoPositionResult)")
            }
        } else {
            let position = weaPy.positionOf(sub: zhuanStr)
            let index = weaPy.index(weaPy.startIndex, offsetBy: position+5)
            let positionResult = weaPy[index...]
            cell.weaImg.image = UIImage(named: "\(positionResult)")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return futureWeatherDictionary.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //滚动使标题栏渐变 改变城市标题宽度形成左移效果
        let titleView = self.view.viewWithTag(100)
        let title = self.view.viewWithTag(101) as! UILabel
        //设置最小偏移量
        let min : CGFloat = 0
        //设置最大偏移量
        let max : CGFloat = 120
        let maxRe : CGFloat = 50
        //获得当前滚动的偏移量
        let offset = scrollView.contentOffset.y
        if offset >= 0 {
            //（当前-最小）/（最大-最小） 得到的百分比值作为自定义标题栏的透明度
            let alpha = (offset - min) / (max - min)
            titleView?.alpha = alpha
            //计算标题宽度变化
            let width = weatherSize.screen_w - offset * 2
            //增加条件防止宽度过大或过小
            if width <= 150 {
                title.frame.size.width = 150
            } else if width >= weatherSize.screen_w {
                title.frame.size.width = weatherSize.screen_w
            } else {
                title.frame.size.width = width
            }
        } else {
            let widthre =  weatherSize.screen_w + offset * 2
            if widthre <= weatherSize.screen_w {
                title.frame.size.width = weatherSize.screen_w
            }
            let alpha = (min + offset) / (maxRe - min)
            titleView?.alpha = alpha
            let alphaRe = (maxRe + offset) / (maxRe - min)
            title.alpha = alphaRe
        }
    }
    //MARK:获取信息
    ///解析json得到基本天气数据
    func getWeatherData() {
        let path = "http://api.k780.com/?app=weather.today&weaid=\(cityInfo)&appkey=35717&sign=089478792dfe3d89fcbf6f5333eda713&format=json"
        //转data
        let url = NSURL(string: path)
        let request = URLRequest(url: url! as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                //错误处理
                do {
                    //使用swiftyJSON中的 JSON 方法将data转json
                    let json = try JSON(data: data!)
                    //根据json串结构获取信息
                    let name = json["result"]["citynm"].string!
                    let temp = json["result"]["temperature_curr"].string!
                    let tempAll = json["result"]["temperature"].string!
                    let weather = json["result"]["weather_curr"].string!
                    let humidity = json["result"]["humidity"].string!
                    let wind = json["result"]["wind"].string!
                    let winp = json["result"]["winp"].string!
                    //回到主线程更新UI（UI变化必须在主线程中完成）
                    DispatchQueue.main.async {
                        self.updateUI(name: name, temp: temp, tempAll: tempAll, weather: weather, humidity: humidity, wind: wind, winp: winp)
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
    ///获取未来一周的信息
    func getFutureWeatherData() {
        let path = "http://api.k780.com/?app=weather.future&weaid=\(cityInfo)&&appkey=35717&sign=089478792dfe3d89fcbf6f5333eda713&format=json"
        let url = NSURL(string: path)
        let request = URLRequest(url: url! as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    let json: JSON = try JSON(data: data!)
                    let count: Int = json["result"].count
                    //遍历未来几日的天气数据并将数据存放在 键为日期（方便排序），值为存有星期、天气、最高最低温度的数组
                    for i in 0..<count {
                        let days = json["result"][i]["days"].string!
                        let week = json["result"][i]["week"].string!
                        let weather = json["result"][i]["weather"].string!
                        let temperature = json["result"][i]["temperature"].string!
                        self.futureWeatherArray.append(week)
                        self.futureWeatherArray.append(weather)
                        self.futureWeatherArray.append(temperature)
                        self.futureWeatherDictionary[days] = self.futureWeatherArray
                        self.futureWeatherArray = []
                    }
                    DispatchQueue.main.async {
                        self.updateFutureUI()
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
    ///获取生活指南信息：紫外线等
    func getLifeData() {
        let path = "http://api.k780.com/?app=weather.lifeindex&weaid=\(cityInfo)&appkey=35717&sign=089478792dfe3d89fcbf6f5333eda713&format=json"
        let url = NSURL(string: path)
        let request = URLRequest(url: url! as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    self.formatter.dateFormat = "yyyy-MM-dd"
                    let todayDateStr = self.formatter.string(from: self.todayDate)
                    print("获取生活指南信息：紫外线等taday's date is \(todayDateStr)")
                    let json = try JSON(data: data!)
                    //json解析得到的生活信息是未来很多天的数据，我们只需要获取今天的信息
                    //FIXME:由于返回的json值格式有问题导致开包为nil
                    //var a = json["result"][0]["lifeindex_uv_attr"].string!
                    //也可以用json.first.1["lifeindex_uv_attr"]
                    //print("a的值为\(a)")
                    let uv = json["result"][0]["lifeindex_uv_attr"].string!
                    let ct = json["result"][0]["lifeindex_ct_attr"].string!
                    DispatchQueue.main.async {
                        self.updateLifeUI(uv: uv, ct: ct)
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
    ///获取空气质量及相关信息
    func getPMData() {
        let path = "http://api.k780.com/?app=weather.pm25&weaid=\(cityInfo)&appkey=35717&sign=089478792dfe3d89fcbf6f5333eda713&format=json"
        let url = NSURL(string: path)
        let request = URLRequest(url: url! as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    let json = try JSON(data: data!)
                    let aqi = json["result"]["aqi"].string!
                    let aqi_scope = json["result"]["aqi_scope"].string!
                    let aqi_levid = json["result"]["aqi_levid"].string!
                    let aqi_levnm = json["result"]["aqi_levnm"].string!
                    DispatchQueue.main.async {
                        self.updatePMUI(aqi: aqi, aqi_scope: aqi_scope, aqi_levid: aqi_levid, aqi_levnm: aqi_levnm)
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
    //MARK:刷新UI界面
    ///
    /// ## UI界面刷新
    /// - date: 2018/8/9
    /// - parameters:
    ///    - name:城市名称
    ///    - temp:温度
    ///    - tempAll:最高温最低温
    ///    - weather:天气状况
    ///    - humidity:湿度
    ///    - wind:风向
    ///    - winp:风力级数
    /// - returns:void
    /// - copyright:1.0 [LANCEREN](www.lancerenbj.com)
    ///- throws:no throw
    ///
    func updateUI(name: String, temp: String, tempAll: String, weather: String, humidity: String, wind: String, winp: String) {
        let title = self.view.viewWithTag(101) as! UILabel
        let tempLabel = self.view.viewWithTag(102) as! UILabel
        let weatherLable = self.view.viewWithTag(103) as! UILabel
        let weatherImage = self.view.viewWithTag(104) as! UIImageView
        let tempTitleLable = self.view.viewWithTag(105) as! UILabel
        let tempAllTitleLable = self.view.viewWithTag(106) as! UILabel
        let tempAllLabel = self.view.viewWithTag(107) as! UILabel
        let humidityLabel = self.view.viewWithTag(201) as! UILabel
        let windLabel = self.view.viewWithTag(202) as! UILabel

        title.text = name
        tempLabel.text = temp //主标题栏
        tempTitleLable.text = temp //上拉标体栏
        weatherLable.text = weather //标题栏天气
        tempAllLabel.text = tempAll  //主标题栏温度区间
        tempAllTitleLable.text = tempAll  //上拉标题栏温度区间
        humidityLabel.text = "湿度: " + humidity
        windLabel.text = "风向: " + wind + ", 风力: " + winp
        
        let weaPy = weather.transformToPinYin()
        let weaPynight = weaPy + "wan"
        //进入夜间后将以下出现太阳图标的天气图标更换为月亮
        if weaPy == "qing" || weaPy == "duoyun" || weaPy == "zhenyu" || weaPy == "wu" {
            weatherImage.image = isNight! ? UIImage(named: weaPynight) : UIImage(named: weaPy)
        } else {
            weatherImage.image = UIImage(named: weaPy)
        }
    }
    
    ///刷新未来天气的tableView
    func updateFutureUI() {
        (self.view.viewWithTag(200) as! UITableView).reloadData()
        (self.view.viewWithTag(200) as! UITableView).layoutIfNeeded()
    }
    
     ///刷新日常生活指数
     
     ///- Parameters:
     ///   - uv:紫外线
     ///   - ct:穿衣指数
 
    func updateLifeUI(uv: String, ct: String) {
        let uvLabel = self.view.viewWithTag(203) as! UILabel
        let ctLabel = self.view.viewWithTag(204) as! UILabel
        
        uvLabel.text = "紫外线指数: " + uv
        ctLabel.text = "穿衣指数: " + ct
    }
    
/**
     刷新UI界面AQI参数
     - parameters:
        - aqi:空气指数
        - aqi_scope:质量区间
        - aqi_levid:空气数字等级
        - aqi_levnm:空气质量
     - Author: LANCEREN
     
*/
    func updatePMUI(aqi: String, aqi_scope: String, aqi_levid: String, aqi_levnm: String) {
        let aqiLabel = self.view.viewWithTag(206) as! UILabel
        let levnmLabel = self.view.viewWithTag(207) as! UILabel
        
        aqiLabel.text = "PM2.5指数: " + aqi + " (\(aqi_scope))"
        levnmLabel.text = "空气质量: \(aqi_levid)级 \(aqi_levnm)"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension String {
    ///扩展String类 将汉字转化为拼音
    func transformToPinYin()->String {
        let mutableString = NSMutableString(string: self)
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        let string = String(mutableString)
        return string.replacingOccurrences(of: " ", with: "")
    }
    ///获取指定字符串在包含该字符串的字符串中的起始位置
    func positionOf(sub:String)->Int {
        var pos = -1
        if let range = range(of:sub) {
            if !range.isEmpty {
//                print("range is \(range.lowerBound) and \(startIndex)")
                pos = characters.distance(from:startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
}

//重点***定位当前城市
extension WeatherViewController: CLLocationManagerDelegate {
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
                    //print("city \(json["result"])")
                    let jsonDic = json["result"].dictionary!
                    let sortedKeysAndValues = jsonDic.sorted(by: { (d1, d2) -> Bool in
                        return d1 < d2 ? true : false
                    })
                    for i in 0..<count {
                        //遍历 将定位得到的城市名分别于列表中的城市进行对比 如果相同则获得该城市的信息 完成定位功能
                        let city = sortedKeysAndValues[i].value["citynm"].string!
                        let id = sortedKeysAndValues[i].value["weaid"].string!
                        if city == nowCity {
                            self.cityInfo = id
                            if appDelegate.cityInfo == "" {
                                //将当前定位到的城市名存储到appDelegate中进行传值
                                appDelegate.locationCity = city
                                appDelegate.locationCityID = id
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        if appDelegate.cityInfo == "" {
                            self.getWeatherData()
                            self.getFutureWeatherData()
                            self.getLifeData()
                            self.getPMData()
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
    func loadingAction() {
        //正在加载的预览界面动画 在定位成功后隐藏
        let loadingView = self.view.viewWithTag(121)
        UIView.animate(withDuration: 0.2, animations: {
            loadingView?.alpha = 0
        }) { (_) in
            loadingView?.isHidden = true
        }
    }
}

extension WeatherViewController{
    func setUI() {
//——————————————————————————布局
        weatherInfoScrollView.contentSize = CGSize(width: weatherSize.screen_w, height: 850)
        //实时温度
        let tempLabel = UILabel(frame: CGRect(x: 0, y: 70, width: weatherSize.screen_w, height: 100))
        tempLabel.tag = 102
        tempLabel.text = "--℃"
        tempLabel.textAlignment = .center
        tempLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 70)
        tempLabel.textColor = UIColor.white
        weatherInfoScrollView.addSubview(tempLabel)
        //最高最低温度
        let tempAllLabel = UILabel()
        tempAllLabel.tag = 107
        tempAllLabel.frame.size = CGSize(width: weatherSize.screen_w, height: 30)
        tempAllLabel.text = "--℃/--℃"
        tempAllLabel.textAlignment = .center
        tempAllLabel.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        tempAllLabel.textColor = UIColor.white
        weatherInfoScrollView.addSubview(tempAllLabel)
        //snapKit框架 代码进行自动布局
        tempAllLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(tempLabel).offset(30)
            make.centerX.equalTo(weatherInfoScrollView)
        }
        //天气
        let weatherLabel = UILabel()
        weatherLabel.tag = 103
        weatherLabel.frame.size = CGSize(width: weatherSize.screen_w, height: 30)
        weatherLabel.text = "--"
        weatherLabel.textAlignment = .center
        weatherLabel.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        weatherLabel.textColor = UIColor.white
        weatherInfoScrollView.addSubview(weatherLabel)
        weatherLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(tempAllLabel).offset(30)
            make.centerX.equalTo(weatherInfoScrollView)
        }
        //未来一周天气 使用tableView显示
        let futureTableView = UITableView()
        futureTableView.tag = 200
        futureTableView.backgroundColor = self.view.backgroundColor
        futureTableView.delegate = self
        futureTableView.dataSource = self
        futureTableView.rowHeight = 40
        futureTableView.frame = CGRect(x: 0, y: 280, width: weatherSize.screen_w, height: 280)
        futureTableView.isScrollEnabled = false
        futureTableView.tableFooterView = UIView()
        futureTableView.separatorStyle = .none
        futureTableView.register(FutureTableViewCell.self, forCellReuseIdentifier: "cell")
        weatherInfoScrollView.addSubview(futureTableView)
        //分割线
        let lineView = UIView(frame: CGRect(x: 0, y: 570, width: weatherSize.screen_w, height: 0.5))
        if #available(iOS 11.0, *) {
            lineView.backgroundColor = isNight! ? UIColor(named: "w_darkblue") : UIColor(named: "w_blue")
        } else {
            // Fallback on earlier versions
        }
        weatherInfoScrollView.addSubview(lineView)
        let otherInfoView = UIView()
        otherInfoView.backgroundColor = self.view.backgroundColor
        otherInfoView.frame = CGRect(x: 0, y: 580, width: weatherSize.screen_w, height: 240)
        weatherInfoScrollView.addSubview(otherInfoView)
        //紫外线 空气质量等其他信息
        let otherLabel_1 = UILabel()
        otherLabel_1.tag = 201
        let otherLabel_2 = UILabel()
        otherLabel_2.tag = 202
        let otherLabel_3 = UILabel()
        otherLabel_3.tag = 203
        let otherLabel_4 = UILabel()
        otherLabel_4.tag = 204
        let otherLabel_6 = UILabel()
        otherLabel_6.tag = 206
        let otherLabel_7 = UILabel()
        otherLabel_7.tag = 207
        var labelY: CGFloat = 0
        let otherLables : [UILabel] = [otherLabel_1, otherLabel_2, otherLabel_3, otherLabel_4, otherLabel_6, otherLabel_7]
        for i in otherLables {
            i.frame = CGRect(x: 10, y: labelY, width: weatherSize.screen_w - 10, height: 40)
            i.text = ""
            i.font = UIFont(name: "HelveticaNeue-Light", size: 17)
            i.textAlignment = .left
            i.textColor = UIColor.white
            otherInfoView.addSubview(i)
            //设置下一个label时y值+40
            labelY += 40
        }
        
//——————————————————————————————————————————以下为标题栏布局
        //标题栏主体
        let titleView = UIView()
        titleView.tag = 100
        if #available(iOS 11.0, *) {
            titleView.backgroundColor = isNight! ? UIColor(named: "w_darkblue") : UIColor(named: "w_blue")
        } else {
            // Fallback on earlier versions
        }
        titleView.frame = CGRect(x: 0, y: 0, width: weatherSize.screen_w, height: 100)
        titleView.alpha = 0
        //标题 显示城市名
        let title = UILabel()
        title.text = "--"
        title.tag = 101
        title.frame.size = CGSize(width: weatherSize.screen_w, height: 80)
        title.textAlignment = .center
        title.font = UIFont(name: "HelveticaNeue-Light", size: 25)
        title.textColor = UIColor.white
        title.center.x = titleView.center.x
        title.center.y = titleView.center.y + 15
        //天气图标
        let weatherImage = UIImageView()
        weatherImage.tag = 104
        self.view.addSubview(titleView)
        self.view.addSubview(title)
        self.view.addSubview(weatherImage)
        weatherImage.snp.makeConstraints { (make) in
            make.size.equalTo(50)
            make.right.equalTo(self.view).offset(-10)
            make.centerY.equalTo(title)
        }
        //标题栏上的温度
        let tempTitleLable = UILabel()
        tempTitleLable.tag = 105
        tempTitleLable.font = UIFont(name: "HelveticaNeue-Light", size: 25)
        tempTitleLable.textColor = UIColor.white
        tempTitleLable.textAlignment = .right
        titleView.addSubview(tempTitleLable)
        tempTitleLable.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(25)
            make.top.equalTo(weatherImage)
            make.right.equalTo(weatherImage).offset(-70)
        }
        //标题栏上的最高最低温度
        let tempAllTitleLable = UILabel()
        tempAllTitleLable.tag = 106
        tempAllTitleLable.font = UIFont(name: "HelveticaNeue-Thin", size: 15)
        tempAllTitleLable.textColor = UIColor.white
        tempAllTitleLable.textAlignment = .right
        titleView.addSubview(tempAllTitleLable)
        tempAllTitleLable.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(20)
            make.bottom.equalTo(weatherImage)
            make.right.equalTo(weatherImage).offset(-70)
        }
        //定位预加载view
        let loadingView = UIView(frame: self.view.frame)
        loadingView.tag = 121
        loadingView.backgroundColor = self.view.backgroundColor
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
//未来七天天气列表的布局
class FutureTableViewCell: UITableViewCell {
    var weekLabel = UILabel()
    var weaImg = UIImageView()
    var tempLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "cell")
        weekLabel.frame = CGRect(x: 10, y: 0, width: 100, height: 40)
        weekLabel.center.y = self.center.y
        weekLabel.textColor = UIColor.white
        weekLabel.textAlignment = .left
        weekLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        self.addSubview(weekLabel)
        
        weaImg.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        weaImg.center.y = self.center.y
        weaImg.center.x = weatherSize.screen_w / 2
        self.addSubview(weaImg)
        
        tempLabel.frame = CGRect(x: weatherSize.screen_w - 110, y: 0, width: 100, height: 40)
        tempLabel.center.y = self.center.y
        tempLabel.textColor = UIColor.white
        tempLabel.textAlignment = .right
        tempLabel.font = UIFont(name: "HelveticaNeue-Light", size: 17)
        self.addSubview(tempLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
