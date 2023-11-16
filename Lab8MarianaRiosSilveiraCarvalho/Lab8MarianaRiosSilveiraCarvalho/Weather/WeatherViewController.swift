//
//  ViewController.swift
//  Lab8MarianaRiosSilveiraCarvalho
//
//  Created by Mariana Rios Silveira Carvalho on 2023-11-11.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    // MARK: - UI Components
    @IBOutlet weak var icon: UIImageView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    // MARK: - Private Variables
    private let locationManager: CLLocationManager
    private let viewModel: WeatherViewModelProtocol

    // MARK: - Initializer
    required init?(coder: NSCoder) {
        self.locationManager = CLLocationManager()
        self.viewModel = WeatherViewModel()
        super.init(coder: coder)
    }

    // MARK: - UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    // MARK: - Private Functions
    private func setup() {
        self.setupViewModel()
        self.setupUIComponents()
        self.checkLocationServices()
    }

    private func setupViewModel() {
        self.viewModel.delegate = self
    }

    private func setupUIComponents() {
        self.cityLabel.text = ""
        self.weatherLabel.text = ""
        self.humidityLabel.text = ""
        self.windSpeedLabel.text = ""
        self.temperatureLabel.text = ""
    }

    private func setupLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
}

// MARK: - Private Extension Functions Related to Permissions
private extension WeatherViewController {
    func checkLocationServices() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.setupLocationManager()
            } else {
                self.showAuthorizationStatusAlertError()
            }
        }
    }

    func checkLocationManagerAuthorizationStatus() {
        let authorizationStatus: CLAuthorizationStatus

        if #available(iOS 14, *) {
            authorizationStatus = self.locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }

        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            self.locationManager.startUpdatingLocation()
        case .denied:
            self.showAuthorizationStatusAlertError()
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }

    func showAuthorizationStatusAlertError() {
        let alert = UIAlertController(
            title: "Weather needs to access your location while using the app",
            message: "To use this app, you will need to allow Weather to access your location.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }))

        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - CLLocationManager Delegate
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.checkLocationManagerAuthorizationStatus()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.icon.image = UIImage()
        self.activityIndicator.startAnimating()
        self.viewModel.didUpdateLocation(location.coordinate.latitude, location.coordinate.longitude)
    }
}

// MARK: - WeatherViewModel Delegate
extension WeatherViewController: WeatherViewModelDelegate {
    func showError() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Error",
                message: "Something went wrong.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
            self.present(alert, animated: true, completion: nil)

            self.icon.image = UIImage(systemName: "x.square")
            self.activityIndicator.stopAnimating()
        }
    }

    func updateView(city: String, description: String, icon: URL, temperature: String, humidity: String, windSpeed: String) {
        self.icon.load(from: icon) {
            self.activityIndicator.stopAnimating()
        }

        DispatchQueue.main.async {
            self.cityLabel.text = city
            self.weatherLabel.text = description
            self.humidityLabel.text = humidity
            self.windSpeedLabel.text = windSpeed
            self.temperatureLabel.text = temperature
        }

    }
}
