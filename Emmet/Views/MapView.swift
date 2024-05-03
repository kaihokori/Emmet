import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var locationManager: LocationManager
    var fetchedEvents: FetchedResults<Event>
    @Binding var isShowingMap: Bool
    @Binding var position: MapCameraPosition
    @State var selectedEvent: Event?
    @State var route: MKRoute?
    @State var isHidingPastEvents: Bool
    
    init(fetchedEvents: FetchedResults<Event>, isShowingMap: Binding<Bool>, position: Binding<MapCameraPosition>) {
        self.fetchedEvents = fetchedEvents
        self._isShowingMap = isShowingMap
        self._position = position
        self._isHidingPastEvents = State(initialValue: UserDefaults.standard.bool(forKey: "hide_events"))
    }
    
    private var travelTime: String? {
        guard let route else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: route.expectedTravelTime)
    }

    var body: some View {
        ZStack {
            Map(position: $position) {
                UserAnnotation()
                ForEach(fetchedEvents, id: \.self) { event in
                    if !isHidingPastEvents || (event.date ?? Date()) > Date() {
                        Annotation(event.name ?? "", coordinate: CLLocationCoordinate2D(latitude: event.locationLatitude, longitude: event.locationLongitude)) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(EventHelper.eventColor(eventType: event.type ?? ""))
                                    .frame(width: 35, height: 35)
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 35, height: 35)
                                Image(systemName: EventHelper.eventIcon(eventType: event.type ?? ""))
                                    .foregroundStyle(EventHelper.eventAltColor(eventType: event.type ?? ""))
                                    .frame(width: 35, height: 35)
                                    .font(.system(size: 20))
                            }
                            .onTapGesture {
                                selectedEvent = event
                            }
                        }
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .mapStyle(.standard(elevation: .realistic))
            
            if let event = selectedEvent {
                VStack {
                    Spacer()
                    VStack(alignment: .leading) {
                        HStack {
                            Text(event.name ?? "")
                                .font(.title)
                                .foregroundStyle(.primary)
                                .bold()
                            Spacer()
                            Button {
                                selectedEvent = nil
                            } label: {
                                Text("Close")
                            }
                            .buttonStyle(.bordered)
                        }

                        HStack {
                            Text(event.locationName ?? "")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                            Spacer()
                            if let locality = event.locationLocality, !locality.isEmpty {
                                if let postcode = event.locationPostcode, !postcode.isEmpty {
                                    (Text(locality) + Text(" ") + Text(postcode))
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text(locality)
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                }
                            } else if let postcode = event.locationPostcode, !postcode.isEmpty {
                                Text(postcode)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Date")
                                    .font(.headline)
                                    .bold()
                                Text(EventDateHelper.formatDateMedium(event.date ?? Date()))
                                    .font(.body)
                            }
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Type")
                                    .font(.headline)
                                    .bold()
                                Text(event.type ?? "No Type")
                                    .font(.body)
                            }
                        }
                        
                        Button {
                            let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: event.locationLatitude, longitude: event.locationLongitude)))
                            destination.name = event.name ?? "Destination"
                            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                            destination.openInMaps(launchOptions: launchOptions)
                        } label: {
                            Label("Directions", systemImage: "car.fill")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .frame(height: 30)
                                .foregroundStyle(Color.accentColor)
                        }
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(.thinMaterial)
                }
            }
            
            VStack {
                HStack {
                    Button(action: {
                        isShowingMap = false
                    }) {
                        ZStack {
                            Image(systemName: "chevron.backward")
                                .foregroundStyle(Color.accentColor)
                                .frame(width: 45, height: 45)
                                .font(.system(size: 20))
                        }
                        .background(.thickMaterial, in: .rect(cornerRadius: 10))
                    }
                    Spacer()
                }
                .padding(.top, 5)
                .padding(.leading, 8)
                Spacer()
            }
        }
        .onAppear {
            locationManager.manager.requestLocation()
            isHidingPastEvents = UserDefaults.standard.bool(forKey: "hide_events")
        }
        .onChange(of: isHidingPastEvents) {
            if isHidingPastEvents {
                if let event = selectedEvent {
                    if event.date ?? Date() < Date() {
                        selectedEvent = nil
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                
                // Australia
                Button {
                    locationManager.moveToCountry("Australia")
                } label: {
                    Text("🇦🇺")
                }
                .buttonStyle(.bordered)
                
                // Austria
                Button {
                    locationManager.moveToCountry("Austria")
                } label: {
                    Text("🇦🇹")
                }
                .buttonStyle(.bordered)
                
                // UK
                Button {
                    locationManager.moveToCountry("United Kingdom")
                } label: {
                    Text("🇬🇧")
                }
                .buttonStyle(.bordered)
                
                // USA
                Button {
                    locationManager.moveToCountry("United States")
                } label: {
                    Text("🇺🇸")
                }
                .buttonStyle(.bordered)
                
                // Canada
                Button {
                    locationManager.moveToCountry("Canada")
                } label: {
                    Text("🇨🇦")
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                if isHidingPastEvents {
                    Button {
                        isHidingPastEvents = false
                    } label: {
                        Image(systemName: "clock")
                            .foregroundStyle(Color.white)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button {
                        isHidingPastEvents = true
                    } label: {
                        Image(systemName: "clock")
                            .foregroundStyle(Color.accentColor)
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
            }
            .frame(height: 70)
            .background(.thinMaterial)
        }
    }
}
