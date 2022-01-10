//
//  ViewControllerSettings.swift
//  Clima
//
//  Created by Macbook on 02.01.22.
//

import UIKit
import CoreLocation

//MARK: - WeatherManagerDelegate
protocol WeatherManagerDelegate {
    func didUpdateWeather(weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
    func showAlert()
}

//MARK: - Struct WeatherManager
struct WeatherManager {
    
    //MARK: - var / let
    let weatherURL = "https://api.openweathermap.org/data/2.5/onecall?exclude=alerts,minutely&appid=4922baab80f9593f292d4f39ce306359&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    //MARK: - Function
    func fetchWeather(location: CLLocation) {
        let urlString = "\(weatherURL)&lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)"
        getAddressFrom(location: location) { place, error in
            guard let place = place?[0], error == nil else { return }
            if let locality = place.locality {
                performRequest(with: urlString, city: locality)
            }
        }
    }
    
    func fetchWeather(city: String) {
        getCoordinateFrom(address: city) { coordinate, error in
            guard let coordinate = coordinate, error == nil else { delegate?.showAlert()
                return }
            let lat = coordinate.latitude
            let lon = coordinate.longitude
            let urlString = "\(weatherURL)&lat=\(lat)&lon=\(lon)"
            performRequest(with: urlString, city: city)
        }
    }
    
    func performRequest(with urlString: String, city: String) {
        //1. Create a URL
        if let url = URL(string: urlString) {
            
            //2. Creathe a URLSession
            let session = URLSession(configuration: .default)
            
            //3. Give the session a task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    //if userDefaults.isEmpty { didFailWithError } else {
                    //userDefaults.getValue(weatherModel)
                    //delegate.didUpdateWeather
                    //}
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if var weather = self.parseJSON(safeData) {
                        weather.city = city
                        self.delegate?.didUpdateWeather(weatherManager: self, weather: weather)
                    }
                }
            }
            //4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let currentID = decodedData.current.weather[0].id
            let currentTemp = decodedData.current.temp
            let currentSunrise = getDayForDate(Date(timeIntervalSince1970: Double(decodedData.current.sunrise)))
            print(currentSunrise)
            let currentSunset = getDayForDate(Date(timeIntervalSince1970: Double(decodedData.current.sunset)))
            print(currentSunset)
            let currentWindSpeed = decodedData.current.wind_speed
            let hourly = decodedData.hourly.map{ WeatherModelHourly(temp: $0.temp, time: $0.dt, conditionID: $0.weather[0].id) }
            let daily = decodedData.daily.map{ WeatherModelDaily(time: $0.dt, minTemp: $0.temp.min, maxTemp: $0.temp.max, conditionID: $0.weather[0].id) }
            let weather = WeatherModel(conditionID: currentID, temperature: currentTemp, sunrise: currentSunrise, sunset: currentSunset, windSpeed: currentWindSpeed, hourly: hourly, daily: daily)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func getDayForDate(_ date: Date?) -> String {
        guard let inputDate = date else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: inputDate)
    }
}

//MARK: - CompletionHandler
func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
    CLGeocoder().geocodeAddressString(address) {
        completion($0?.first?.location?.coordinate, $1)
    }
}

func getAddressFrom(location: CLLocation, completion: @escaping([CLPlacemark]?, Error?) -> ()) {
    CLGeocoder().reverseGeocodeLocation(location) { place, error in
        completion(place, error)
    }
}


