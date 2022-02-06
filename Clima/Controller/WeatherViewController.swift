//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
class WeatherViewController: UIViewController{

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
   
    var weatherManager = WeatherManager()
    var locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
    
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // we need to take permisson for use location data from the user
       // locationManager.requestLocation() // this code line get location data after the get permission of usage data. When using this method, the associated delegate must implement the locationManager(_:didUpdateLocations:) and locationManager(_:didFailWithError:) methods. Failure to do so is a programmer error. so we will implement in the extension of location.
        
        
        weatherManager.delegate = self
        searchTextField.delegate = self // we have given notify to viewcontroller when every time did something related with textfield through use feature of delegate.
    }
    @IBAction func getLocationPressed(_ sender: UIButton) {
        locationManager.requestLocation() // we triggered  location manager.
    }
}
//MARK: - TEXTFIELD
extension WeatherViewController : UITextFieldDelegate {
    
    @IBAction func searchPressed(_ sender: UIButton ) {
        searchTextField.endEditing(true) //to close keyboard when our process done.
        print(searchTextField.text!)
       
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { //this method that  is  ask delegate one question that when in textfield keyboard return button is tapped and then what will happen.
            searchTextField.endEditing(true) //we have special statement at here. here have a connection with textFieldDidEndEditing which is delegate function. when this code line worked and then textFieldDidEndEditing will be triggered and will work code lines that are insede of textFieldDidEndEditing method that is deletegate method.
        print(textField.text!)
        return true //we have allowed to return button to do process through this code line.
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let city = searchTextField.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            //through the addingPercentEncoding , we can convert characters which they are turkish character or space so that this perform correctly every time.
        {
            weatherManager.fetchWeather(CityName: city)
            
        }
        
        
        textField.text = "" // i        ere as textField here because i assigned as @IBOutlet weak var searchTextField: UITextField! so  UITextField will tell me  which textfield i tapped.
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != ""{
            return true
        }
        else {
            textField.placeholder = "Tpye something to search"
            return false // if i write here true , the keyboard will be close. i want to keep open the keyboard until the write anything
        }
    }
}
//MARK: - WEATHER
extension WeatherViewController : WeatherManagerDelegate {
    
    func didFailWithEror(error: Error) {
        print(error)
    }
    
  
    //we add an paramater into  below method that is didUpdateWeather. this is apple syntax style. we indicated delegate where it is used.
    func didUpdateWeather(_ weatherManager : WeatherManager ,weather: WeatherModel) {
        //print(weather.temperature)
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
}

//MARK: - LOCATION

extension WeatherViewController : CLLocationManagerDelegate {
    
   //we have to use above two method to use CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        if let location = locations.last {
            locationManager.stopUpdatingLocation() //we stopped the location manager because already we have datas now.
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude : lat , longitude : lon)
        }
        
        }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
     print(error)
    }
    
    
}
