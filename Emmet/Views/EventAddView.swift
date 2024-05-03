import SwiftUI
import CoreLocation

struct EventAddView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @ObservedObject var locationManager: LocationManager
    
    @State private var name: String = ""
    @State private var type: String = "Activity"
    @State private var date: Date = Date()
    @State private var locationName: String = ""
    @State private var locationSubThoroughfare: String = ""
    @State private var locationThoroughfare: String = ""
    @State private var locationLocality: String = ""
    @State private var locationAdministrativeArea: String = ""
    @State private var locationPostcode: String = ""
    @State private var locationCountry: String = ""
    @State private var locationLatitude: Double = 0.0
    @State private var locationLongitude: Double = 0.0
    @State private var notes: String = ""
    @State private var image: Data = UIImage(named: "Placeholder.png")?.pngData() ?? Data()
    @State private var fileName: String = ""
    @State private var fileType: String = ""
    @State private var fileData: Data?
    @State private var isMarkedForDeletion: Bool = false
    
    @State private var isSelectingLocation: Bool = false
    @State private var isSelectingImage: Bool = false
    @State private var isSelectingFile: Bool = false
    
    @FocusState private var isLocationTextFieldFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Spacer()
                    .frame(height: 20)
                
                VStack(alignment: .leading) {
                    Text("Name")
                        .font(.caption)
                        .foregroundStyle(Color.gray)
                    TextField("", text: $name)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 15)
                        .background(Color.white.shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: .rect(cornerRadius: 10))
                }
                .padding(.bottom)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Date")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                        DatePicker("", selection: $date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Type")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                        let types: [String] = ["Activity", "Food", "Stay", "Travel", "Other"]
                        
                        Picker("", selection: $type) {
                            ForEach(types, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.bottom)
                
                VStack(alignment: .leading) {
                    Text("Location")
                        .font(.caption)
                        .foregroundStyle(Color.gray)
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.shadow(.drop(color: .black.opacity(0.25), radius: 2)))
                            
                            .onTapGesture {
                                isSelectingLocation = true
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                        HStack {
                            Text(locationName)
                                .font(.system(size: 18))
                                .padding(.leading, 15)
                            Spacer()
                        }
                    }
                }
                .padding(.bottom)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Image")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                        
                        if image != (UIImage(named: "Placeholder.png")?.pngData() ?? Data()) {
                            Button {
                                image = UIImage(named: "Placeholder.png")?.pngData() ?? Data()
                            } label: {
                                Label("Clear Image", systemImage: "camera.fill")
                                    .foregroundStyle(Color.black)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .frame(height: 30)
                            }
                            .buttonStyle(.bordered)
                            .tint(Color.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Button {
                                isSelectingImage = true
                            } label: {
                                Label("Add an Image", systemImage: "camera.fill")
                                    .foregroundStyle(Color.black)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .frame(height: 30)
                            }
                            .buttonStyle(.bordered)
                            .tint(Color.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("File")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                        
                        if fileName == "" {
                            Button {
                                isSelectingFile = true
                            } label: {
                                Label("Add a File", systemImage: "folder.fill")
                                    .foregroundStyle(Color.black)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .frame(height: 30)
                            }
                            .buttonStyle(.bordered)
                            .tint(Color.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Button {
                                fileName = ""
                                fileType = ""
                                fileData = nil
                            } label: {
                                Label("Clear File", systemImage: "folder.fill")
                                    .foregroundStyle(Color.black)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .frame(height: 30)
                            }
                            .buttonStyle(.bordered)
                            .tint(Color.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.bottom)
                
                VStack(alignment: .leading) {
                    Text("Notes")
                        .font(.caption)
                        .foregroundStyle(Color.gray)
                    VStack(alignment: .leading) {
                        TextEditor(text: $notes)
                            .frame(height: 50)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 10)
                            .background(Color.white.shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: .rect(cornerRadius: 10))
                        Spacer()
                    }
                }
                .padding(.bottom)
                
                Button(action: {
                    let newEvent = Event(context: moc)
                    newEvent.id = UUID()
                    newEvent.name = name
                    newEvent.type = type
                    newEvent.date = date
                    let location = CLLocation(latitude: locationLatitude, longitude: locationLongitude)

                    TimezoneHelper.timeZone(for: location) { timeZone in
                        newEvent.timezone = timeZone?.identifier ?? TimeZone.current.identifier

                        newEvent.locationName = locationName
                        newEvent.locationSubThoroughfare = locationSubThoroughfare
                        newEvent.locationThoroughfare = locationThoroughfare
                        newEvent.locationLocality = locationLocality
                        newEvent.locationAdministrativeArea = locationAdministrativeArea
                        newEvent.locationPostcode = locationPostcode
                        newEvent.locationCountry = locationCountry
                        newEvent.locationLatitude = locationLatitude
                        newEvent.locationLongitude = locationLongitude
                        newEvent.notes = notes
                        newEvent.image = image
                        newEvent.fileName = fileName
                        newEvent.fileType = fileType
                        newEvent.fileData = fileData
                        newEvent.isMarkedForDeletion = isMarkedForDeletion

                        DispatchQueue.main.async {
                            try? moc.save()
                            dismiss()
                        }
                    }
                }, label: {
                    Text("Create Event")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .textScale(.secondary)
                        .foregroundStyle(EventHelper.eventAltColor(eventType: type))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                        .background(EventHelper.eventColor(eventType: type), in: .rect(cornerRadius: 10))
                })
                .disabled(name.isEmpty || type.isEmpty || locationLatitude == 0 || locationLongitude == 0 || date <= Date.distantPast)
                .opacity(name.isEmpty || type.isEmpty || locationLatitude == 0 || locationLongitude == 0 || date <= Date.distantPast ? 0.5 : 1)
            }
            .padding()
        }
        .sheet(isPresented: $isSelectingLocation, content: {
            MapSearchView { selectedPlace in
                locationName = selectedPlace.name ?? ""
                locationSubThoroughfare = selectedPlace.subThoroughfare ?? ""
                locationThoroughfare = selectedPlace.thoroughfare ?? ""
                locationLocality = selectedPlace.locality ?? ""
                locationAdministrativeArea = selectedPlace.administrativeArea ?? ""
                locationPostcode = selectedPlace.postalCode ?? ""
                locationCountry = selectedPlace.country ?? ""
                if let location = selectedPlace.location {
                    locationLatitude = location.coordinate.latitude
                    locationLongitude = location.coordinate.longitude
                }

                isSelectingLocation = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isLocationTextFieldFocused = false
                }
            }
            .environmentObject(locationManager)
            .presentationDetents([.height(540)])
            .presentationCornerRadius(30)
            .presentationBackground(Color.white)
            .interactiveDismissDisabled()
        })
        .sheet(isPresented: $isSelectingImage, content: {
            ImagePickerView(images: $image, show: $isSelectingImage)
                .edgesIgnoringSafeArea(.top)
                .edgesIgnoringSafeArea(.bottom)
        })
        .fileImporter(isPresented: $isSelectingFile, allowedContentTypes: [.data]) { result in
            switch result {
            case .success(let url):
                let importResult = BinaryDocument.importFile(from: url)

                fileData = importResult.data
                fileName = importResult.fileName ?? ""
                fileType = importResult.fileType ?? ""
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
