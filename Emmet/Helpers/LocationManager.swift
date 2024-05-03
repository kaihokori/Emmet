import Foundation
import CoreLocation
import MapKit
import Combine
import _MapKit_SwiftUI

class LocationManager: NSObject, ObservableObject, MKMapViewDelegate, CLLocationManagerDelegate {
    @Published var mapView: MKMapView = .init()
    @Published var manager: CLLocationManager = .init()
    @Published var searchText: String = ""
    @Published var fetchedPlaces: [CLPlacemark]?
    @Published var currentCountry: String?
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var currentRegion: MapCameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -33.8937, longitude: 151.1966), span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)))
    
    var cancellable: AnyCancellable?
    
    override init() {
        super.init()
        
        manager.delegate = self
        mapView.delegate = self
        
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.requestLocation()
        
        cancellable = $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { value in
                if value != "" {
                    self.fetchPlaces(value: value)
                } else {
                    self.fetchedPlaces = nil
                }
            })
    }
    
    func fetchPlaces(value: String) {
        Task {
            do {
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = value.lowercased()

                let response = try await MKLocalSearch(request: request).start()

                await MainActor.run(body: {
                    self.fetchedPlaces = response.mapItems.compactMap({ item -> CLPlacemark? in
                        return item.placemark
                    })
                })
            } catch {
                print("Error fetching places: \(error.localizedDescription)")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location.coordinate

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self, let placemark = placemarks?.first, error == nil else { return }

            self.currentCountry = placemark.country
            self.setMapRegionForCountry(country: placemark.country)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways: manager.requestLocation()
        case .authorizedWhenInUse: manager.requestLocation()
        case .denied: handleLocationError()
        case .notDetermined: manager.requestWhenInUseAuthorization()
        default: ()
        }
    }
    
    func handleLocationError() {
        
    }
    
    func setMapRegionForCountry(country: String?) {
        guard let country = country,
              let region = countryRegions[country] else {
            setDefaultMapRegion()
            return
        }
        updateMapRegion(latitude: region.latitude, longitude: region.longitude, latitudeDelta: region.latitudeDelta, longitudeDelta: region.longitudeDelta)
    }

    
    private func updateMapRegion(latitude: CLLocationDegrees, longitude: CLLocationDegrees, latitudeDelta: CLLocationDegrees, longitudeDelta: CLLocationDegrees) {
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
        DispatchQueue.main.async {
            self.currentRegion = .region(region)
        }
    }
    
    private func setDefaultMapRegion() {
        let defaultRegion: MKCoordinateRegion
        if let currentLocation = self.currentLocation {
            defaultRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: currentLocation.latitude, longitude: currentLocation.longitude), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        } else {
            // Use a default location if current location is not available
            defaultRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -25.2744, longitude: 133.7751), span: MKCoordinateSpan(latitudeDelta: 40, longitudeDelta: 50))
        }

        DispatchQueue.main.async {
            self.currentRegion = .region(defaultRegion)
        }
    }
    
    func moveToCountry(_ country: String) {
        guard let regionDetails = countryRegions[country] else {
            setDefaultMapRegion()
            return
        }

        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: regionDetails.latitude, longitude: regionDetails.longitude), span: MKCoordinateSpan(latitudeDelta: regionDetails.latitudeDelta, longitudeDelta: regionDetails.longitudeDelta))

        DispatchQueue.main.async {
            self.currentRegion = .region(region)
        }
    }
}
