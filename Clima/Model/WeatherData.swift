//
//  ViewControllerSettings.swift
//  Clima
//
//  Created by Macbook on 02.01.22.
//

struct WeatherData: Codable {
    let lat: Double
    let lon: Double
    let current: WeatherDataItem
    let hourly: [HourlyWeatherData]
    let daily: [DailyWeatherItem]
}

struct DailyWeatherItem: Codable {
    let dt: Int64
    let sunrise: Int64
    let sunset: Int64
    let temp: DailyTemp
    let weather: [WeatherDescription]
}

struct DailyTemp: Codable {
    let day: Double
    let min: Double
    let max: Double
    let night: Double
    let eve: Double
    let morn: Double
}

struct HourlyWeatherData: Codable {
    let dt: Int64
    let temp: Double
    let feels_like: Double
    let pressure: Int
    let humidity: Int
    let wind_speed: Double
    let weather: [WeatherDescription]
}


struct WeatherDataItem: Codable {
    let dt: Int64
    let sunrise: Int64
    let sunset: Int64
    let temp: Double
    let feels_like: Double
    let pressure: Int
    let humidity: Int
    let wind_speed: Double
    let weather: [WeatherDescription]
}

struct WeatherDescription: Codable {
    let id: Int
    let main: String
    let description: String
}
