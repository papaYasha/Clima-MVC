//
//  ViewControllerSettings.swift
//  Clima
//
//  Created by Macbook on 02.01.22.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var leadingViewMainInfo: UIView!
    
    //MARK: - Variable, constant
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    var weatherModel: WeatherModel?
        
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    //MARK: - Function
    private func config() {
        createDelegate()
        configCoreLocation()
        configCollectionView()
        configTableView()
        configLeadingViewMainInfo()
    }
    
    private func createDelegate() {
        searchTextField.delegate = self
        weatherManager.delegate = self
        locationManager.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func configCoreLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    private func configCollectionView() {
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.layer.borderWidth = 2
        collectionView.layer.borderColor = UIColor.lightGray.cgColor
        collectionView.reloadData()
        
    }
    
    private func configTableView() {
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TableViewCell")
        tableView.layer.borderWidth = 2
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    private func configLeadingViewMainInfo() {
        leadingViewMainInfo.layer.borderWidth = 2
        leadingViewMainInfo.layer.borderColor = UIColor.lightGray.cgColor
        leadingViewMainInfo.layer.shadowColor = UIColor.black.cgColor
        leadingViewMainInfo.layer.shadowOpacity = 0.3
        leadingViewMainInfo.layer.shadowOffset = .zero
        leadingViewMainInfo.layer.shadowRadius = 8
    }
    
    //MARK: - IBAction
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
}

//MARK: - Extension TextFieldDelegate
extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchTextField.text = ""
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if searchTextField.text != "" {
            return true
        } else {
            searchTextField.placeholder = "Type something"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if let city = searchTextField.text {
            weatherManager.fetchWeather(city: city)
        }
        searchTextField.text = ""
    }
}

//MARK: - Extension WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate {
    func showAlert() {
        let alert = UIAlertController(title: "No results found for \"\(searchTextField.text ?? "non-existing city")\"", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            print("You choose OK")
        }))
        self.present(alert, animated: true)
    }
    
    
    func didUpdateWeather(weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.cityLabel.text = weather.city
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.windSpeedLabel.text = String(weather.windSpeed)
            self.sunriseLabel.text = weather.sunrise
            self.sunsetLabel.text = weather.sunset
            self.weatherModel = weather
            self.collectionView.reloadData()
            self.tableView.reloadData()
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
        //userDef.getValue
    }
}

//MARK: - Extension CoreLocation
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            print(lat,lon)
            weatherManager.fetchWeather(location: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

//MARK: - Extension CollectionViewDelegateDataSource
extension WeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherModel?.hourly.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else { return UICollectionViewCell() }
        if let safeWeatherModel = weatherModel {
            cell.config(with: safeWeatherModel.hourly[indexPath.row])
        }
        return cell
    }
}

//MARK: - Extension TableViewDelegateDataSource
extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherModel?.daily.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as? TableViewCell else { return UITableViewCell() }
        if let safeWeatherModel = weatherModel {
            cell.config(with: safeWeatherModel.daily[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}
