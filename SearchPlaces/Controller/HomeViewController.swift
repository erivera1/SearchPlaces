//
//  ViewController.swift
//  SearchPlaces
//
//  Created by Eliric on 10/28/20.
//

import UIKit
import CoreLocation
import MapKit
import CoreData

class HomeViewController: UIViewController {
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var coordinate = CLLocationCoordinate2D()
    var placeManager = PlaceManager()
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        activityIndicator.startAnimating()
        searchTextField.delegate = self
        placeManager.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        self.mapView.delegate = self
        self.mapView.showsScale = true
        self.mapView.showsCompass = true
        self.mapView.showsUserLocation = true
        
    }
}

//MARK: - MKMapViewDelegate

extension HomeViewController:MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is CustomPointAnnotation else { return nil }
        let annotations:CustomPointAnnotation = annotation as! CustomPointAnnotation
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            annotationView!.annotation = annotation
        }
        
        if let annotationView = annotationView {
            annotationView.canShowCallout = true
            if let urlString =  annotations.imageName{
                applyImage(from: URL(string:urlString), to: annotationView)
            }
        }
        return annotationView
    }
    
    private func removeAllAnnotations() {
        let annotations = self.mapView.annotations.filter {
            $0 !== self.mapView.userLocation
        }
        mapView.removeAnnotations(annotations)
    }
    
    private func addAnnotations(placeViewModel:PlaceViewModel){
        let newPin = CustomPointAnnotation()
        let distanceInKM = Float(placeViewModel.distance) / 1000.0
        let distanceString = String(format: "%.2f", distanceInKM)
        newPin.title = placeViewModel.title
        newPin.subtitle = "\(distanceString) km away"
        newPin.coordinate = CLLocationCoordinate2D(latitude: placeViewModel.position[0], longitude: placeViewModel.position[1])
        newPin.imageName = placeViewModel.icon
        DispatchQueue.main.async {
            self.mapView.addAnnotation(newPin)
        }
    }

    private func applyImage(from url: URL?, to mkAnnotationView: MKAnnotationView) {
        DispatchQueue.global(qos: .background).async {
            if let url = url{
                guard let data = try? Data(contentsOf: url),
                      let image = UIImage(data: data)//.cropped()
                    else { return }
                
                DispatchQueue.main.async {
                    let imageView = UIImageView.init(frame: CGRect(origin:CGPoint(x:0.0,y:0.0), size:CGSize(width: 25, height: 40)))
                    imageView.contentMode = .scaleAspectFit
                    imageView.image = image
                    mkAnnotationView.leftCalloutAccessoryView = imageView
                }
            }
        }
    }
}

//MARK: - CLLocationManagerDelegate

extension HomeViewController:CLLocationManagerDelegate{
    
    @IBAction func locationPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            let locationDistance = 10000
            // STOP UPDATEDING LOCATION
            self.locationManager.stopUpdatingLocation()
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            //ZOOM IN TO REGION
            let region = MKCoordinateRegion( center: location.coordinate, latitudinalMeters: CLLocationDistance(exactly: locationDistance)!, longitudinalMeters: CLLocationDistance(exactly: locationDistance)!)
            self.mapView.setRegion(mapView.regionThatFits(region), animated: true)
            coordinate = center
            placeManager.fetchData()
            activityIndicator.stopAnimating()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.presentAlert(message: error.localizedDescription)
    }
}

//MARK: - UITextfieldDelegate

extension HomeViewController: UITextFieldDelegate {
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        //DO VALIDATIONS HERE
        if(textField.text != ""){
            return true
        }else{
            textField.placeholder = "Enter Search"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let placeName = searchTextField.text{
            activityIndicator.startAnimating()
            placeManager.fetchPlace(name: placeName, coordinate: coordinate)
        }
        searchTextField.text = ""
    }
}

//MARK: - PlaceManagerDelegate

extension HomeViewController: PlaceManagerDelegate{
    func didUpdateItems(_ placeManager: PlaceManager, placesViewModel: [PlaceViewModel]) {
        DispatchQueue.main.async{
            self.removeAllAnnotations()
            self.placeManager.deleteFromCoreData()
            if(placesViewModel.count > 0){
                for placeView in placesViewModel{
                    self.placeManager.saveCoreData(placeviewModel: placeView)
                    self.addAnnotations(placeViewModel:placeView)
                }
            }
            self.activityIndicator.stopAnimating()
        }
    }

    func didFailWithError(error:Error){
        DispatchQueue.main.async {
            self.presentAlert(message: error.localizedDescription)
        }
    }
}




