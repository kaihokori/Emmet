import SwiftUI
import CoreLocation

struct MapSearchView: View {
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var isFocused: Bool
    
    var onSelectLocation: (CLPlacemark) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Button {
                locationManager.searchText = ""
                dismiss()
            } label: {
                Text("Dismiss")
            }
            .padding(.top, 20)
            .padding(.bottom, 5)
            .padding(.horizontal)
            
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.gray)
                    TextField("Address", text: $locationManager.searchText)
                        .onAppear(perform: {
                            isFocused = true
                        })
                        .focused($isFocused)
                        .overlay(
                            HStack {
                                Spacer()
                                if !locationManager.searchText.isEmpty {
                                    Button(action: {
                                        locationManager.searchText = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(Color.gray)
                                    }
                                    .padding(.trailing, 8)
                                }
                            }
                        )
                }
                .padding()
                .background(Color(UIColor.systemGroupedBackground))
                .cornerRadius(6)
            }
            .padding(.horizontal)
            
            ScrollView {
                if let places = locationManager.fetchedPlaces, !places.isEmpty {
                    ForEach(places, id: \.self) { place in
                        Button(action: {
                            onSelectLocation(place)
                            locationManager.searchText = ""
                        }) {
                            HStack {
                                Image(systemName: "mappin")
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.accentColor)
                                    .clipShape(Circle())
                                VStack(alignment: .leading) {
                                    Text(place.name ?? "")
                                        .font(.headline)
                                        .foregroundStyle(Color.black)
                                    Text(AddressHelper.truncate(AddressHelper.formattedAddress(for: place), toLength: 43))
                                        .font(.callout)
                                        .foregroundStyle(Color.gray)
                                }
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .padding(.top)
        }
    }
}
