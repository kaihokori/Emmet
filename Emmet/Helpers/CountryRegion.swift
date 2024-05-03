import Foundation
import CoreLocation

struct CountryRegion {
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let latitudeDelta: CLLocationDegrees
    let longitudeDelta: CLLocationDegrees
}

let countryRegions: [String: CountryRegion] = [
    "Australia": CountryRegion(latitude: -33.8937, longitude: 151.1966, latitudeDelta: 0.3, longitudeDelta: 0.3),
    "Qatar": CountryRegion(latitude: 25.3548, longitude: 51.1839, latitudeDelta: 1.5, longitudeDelta: 1.5),
    "Austria": CountryRegion(latitude: 47.2162, longitude: 13.3501, latitudeDelta: 9, longitudeDelta: 9),
    "Switzerland": CountryRegion(latitude: 46.9487, longitude: 9.2654, latitudeDelta: 2.5, longitudeDelta: 2.5),
    "United Kingdom": CountryRegion(latitude: 51.5113, longitude: -0.1105, latitudeDelta: 0.4, longitudeDelta: 0.4),
//    "United Kingdom": CountryRegion(latitude: 51.47619297361978, longitude: -0.3353104517841628, latitudeDelta: 1, longitudeDelta: 1),
    "United States": CountryRegion(latitude: 37.8283, longitude: -98.5795, latitudeDelta: 60, longitudeDelta: 60),
    "Canada": CountryRegion(latitude: 49.6, longitude: -123.0, latitudeDelta: 1.1, longitudeDelta: 1.1)
]
