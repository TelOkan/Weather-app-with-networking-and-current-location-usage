//
//  WeatherManager.swift
//  Clima
//
//  Created by Okan on 4.02.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation
protocol WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager : WeatherManager ,weather: WeatherModel)
    func didFailWithEror(error : Error)
}
struct WeatherManager {
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=6fe17b07a09c56b25fc94899761c94b3&units=metric"
    
    
    var delegate : WeatherManagerDelegate?
    
    func fetchWeather(latitude : CLLocationDegrees , longitude : CLLocationDegrees) {
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func fetchWeather (CityName : String){
        let urlString = "\(weatherUrl)&q=\(CityName)"
        performRequest(with: urlString)
       
    }
    
    
    func performRequest(with urlString : String) {
       //1. firstly we need to create an Url
        let city = URL(string: urlString)
        if let url = city {
            //2. we need to create an url Session. because we need to something that is have to be behave like browser.
            
            let session = URLSession(configuration: .default)
            
            //3. we need to give one task to session to do something for us.
            //creates a task that retrieves the contents of the specified url , then calls a handler upon completion.
            
          /*1  let task =  session.dataTask(with: url, completionHandler: handle(data: response: error:))
            //4. we have wrote here as resume instead of start because when we initilized task this stuation will be working as asenkron style so maybe we need to wait couse of the different thing such as internet connection speed.
            task.resume()*/
            
            
            
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
               
                    self.delegate?.didFailWithEror(error: error!)
                    return
                }
                
                if let safeData = data {
                    
                  if let weather =  self.parseJson(safeData) //we must to add here self mark cause of the closure rule.
                    {
                      self.delegate?.didUpdateWeather(self,weather: weather) //here self mean is WeatherManager bacause i have written inside of the weathermanager. instead of self i can could WeatherManager that is structer.
                      
                      
                  }
                        
                    
                }
            }
            
            task.resume()
        }
        
        
    }
    
    func parseJson (_ weatherData : Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            var name = decodedData.name
            // 78 and 103 code line between written cause of the provider api. because when i write turkish character city of turkey and then api provider return city name like that is Çankırı Province. I dont want see province addition. So i rid province addition if name include this addition. i implemented two way. one way with split another var is like foreach.
          /*  name = name + " "
            var value : String = ""
            var arrayName : [String] = []
            
            for char in name{
                if (char != Character(" ") ) {
                    value = value + String(char)
                }
                else{
                    arrayName.append(value)
                    value=""
                }
                
            } */
            var arrayName = name.split(separator: " ")
            
            for element in arrayName{
                if (element == "Province"){
                    arrayName.remove(at: arrayName.count-1)
                }
                    
            }
            
            for element in arrayName{
                name = ""
                name = name + element
            }
            
            let weather = WeatherModel(conditionId: Int(id), cityName: name, temperature: temp)
            
            return weather
            
        }
        catch  {
            delegate?.didFailWithEror(error: error) //at the here error came from the try catch statement. we dont need define any error statement.
            return nil
        }
        
        
    }
    
    
   /*2 func handle(data : Data? , response : URLResponse? , error : Error?)  {
        if error != nil {
            print(error!)
            return
        }
        
        if let safeData = data {
            
            let dataSring = String(data: safeData, encoding: .utf8)
            print(dataSring!)
        }
    }

		*/
}
