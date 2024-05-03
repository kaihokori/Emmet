import CoreLocation

class TimezoneHelper {
    static func timeZone(for location: CLLocation, completion: @escaping (TimeZone?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            completion(placemarks?.first?.timeZone)
        }
    }
}
