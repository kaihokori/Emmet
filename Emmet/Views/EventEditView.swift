import SwiftUI
import CoreLocation

struct EventEditView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    @ObservedObject var locationManager: LocationManager
    
    @State private var eventInfo: Event
    let old: Event
    
    @State private var editedName: String
    @State private var editedDate: Date
    @State private var editedType: String
    @State private var editedLocationName: String
    @State private var editedLocationSubThoroughfare: String
    @State private var editedLocationThoroughfare: String
    @State private var editedLocationLocality: String
    @State private var editedLocationAdministrativeArea: String
    @State private var editedLocationPostcode: String
    @State private var editedLocationCountry: String
    @State private var editedLocationLatitude: Double
    @State private var editedLocationLongitude: Double
    @State private var editedImage: Data
    @State private var editedFileName: String
    @State private var editedFileType: String
    @State private var editedFileData: Data?
    @State private var editedNotes: String
    @State private var editedIsMarkedForDeletion: Bool
    
    @State private var isSelectingLocation: Bool = false
    @State private var isSelectingImage: Bool = false
    @State private var isSelectingFile: Bool = false
    
    init(eventInfo: Event, locationManager: LocationManager) {
        self._eventInfo = State(initialValue: eventInfo)
        self.old = eventInfo
        self._locationManager = ObservedObject(initialValue: locationManager)
        
        _editedName = State(initialValue: eventInfo.name ?? "")
        _editedDate = State(initialValue: eventInfo.date ?? Date())
        _editedType = State(initialValue: eventInfo.type ?? "Other")
        _editedLocationName = State(initialValue: eventInfo.locationName ?? "")
        _editedLocationSubThoroughfare = State(initialValue: eventInfo.locationSubThoroughfare ?? "")
        _editedLocationThoroughfare = State(initialValue: eventInfo.locationThoroughfare ?? "")
        _editedLocationAdministrativeArea = State(initialValue: eventInfo.locationAdministrativeArea ?? "")
        _editedLocationLocality = State(initialValue: eventInfo.locationLocality ?? "")
        _editedLocationPostcode = State(initialValue: eventInfo.locationPostcode ?? "")
        _editedLocationCountry = State(initialValue: eventInfo.locationCountry ?? "")
        _editedLocationLatitude = State(initialValue: eventInfo.locationLatitude )
        _editedLocationLongitude = State(initialValue: eventInfo.locationLongitude )
        _editedNotes = State(initialValue: eventInfo.notes ?? "")
        _editedImage = State(initialValue: eventInfo.image ?? Data())
        _editedFileName = State(initialValue: eventInfo.fileName ?? "")
        _editedFileType = State(initialValue: eventInfo.fileType ?? "")
        _editedFileData = State(initialValue: eventInfo.fileData)
        _editedIsMarkedForDeletion = State(initialValue: eventInfo.isMarkedForDeletion)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Spacer()
                    .frame(height: 20)
                
                VStack(alignment: .leading) {
                    Text("Name")
                        .font(.caption)
                        .foregroundStyle(Color.gray)
                    TextField("", text: $editedName)
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
                        DatePicker("", selection: $editedDate)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Type")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                        let types: [String] = ["Activity", "Food", "Stay", "Travel", "Other"]
                        
                        Picker("", selection: $editedType) {
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
                            Text(editedLocationName)
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
                        
                        if editedImage != (UIImage(named: "Placeholder.png")?.pngData() ?? Data()) {
                            Button {
                                editedImage = UIImage(named: "Placeholder.png")?.pngData() ?? Data()
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
                        
                        if editedFileName == "" {
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
                                editedFileName = ""
                                editedFileType = ""
                                editedFileData = nil
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
                        TextEditor(text: $editedNotes)
                            .frame(height: 60)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 15)
                            .background(Color.white.shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: .rect(cornerRadius: 10))
                        Spacer()
                    }
                }
                .padding(.bottom)
                
                Button(action: {
                    old.isMarkedForDeletion = true
                    try? moc.save()
                    
                    let newEvent = Event(context: moc)
                    newEvent.id = UUID()
                    newEvent.name = editedName
                    newEvent.type = editedType
                    newEvent.date = editedDate
                    let location = CLLocation(latitude: editedLocationLatitude, longitude: editedLocationLongitude)

                    TimezoneHelper.timeZone(for: location) { timeZone in
                        newEvent.timezone = timeZone?.identifier ?? TimeZone.current.identifier

                        newEvent.locationName = editedLocationName
                        newEvent.locationSubThoroughfare = editedLocationSubThoroughfare
                        newEvent.locationThoroughfare = editedLocationThoroughfare
                        newEvent.locationLocality = editedLocationLocality
                        newEvent.locationAdministrativeArea = editedLocationAdministrativeArea
                        newEvent.locationPostcode = editedLocationPostcode
                        newEvent.locationCountry = editedLocationCountry
                        newEvent.locationLatitude = editedLocationLatitude
                        newEvent.locationLongitude = editedLocationLongitude
                        newEvent.notes = editedNotes
                        newEvent.image = editedImage
                        newEvent.fileName = editedFileName
                        newEvent.fileType = editedFileType
                        newEvent.fileData = editedFileData
                        newEvent.isMarkedForDeletion = editedIsMarkedForDeletion

                        DispatchQueue.main.async {
                            try? moc.save()
                            dismiss()
                        }
                    }
                }, label: {
                    Text("Update Event")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .textScale(.secondary)
                        .foregroundStyle(EventHelper.eventAltColor(eventType: editedType))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                        .background(EventHelper.eventColor(eventType: editedType), in: .rect(cornerRadius: 10))
                })
                .disabled(editedName.isEmpty || editedType.isEmpty || editedLocationLatitude == 0 || editedLocationLongitude == 0 || editedDate <= Date.distantPast)
                .opacity(editedName.isEmpty || editedType.isEmpty || editedLocationLatitude == 0 || editedLocationLongitude == 0 || editedDate <= Date.distantPast ? 0.5 : 1)
            }
            .padding()
        }
        .sheet(isPresented: $isSelectingLocation, content: {
            MapSearchView { selectedPlace in
                editedLocationName = selectedPlace.name ?? ""
                editedLocationSubThoroughfare = selectedPlace.subThoroughfare ?? ""
                editedLocationThoroughfare = selectedPlace.thoroughfare ?? ""
                editedLocationLocality = selectedPlace.locality ?? ""
                editedLocationAdministrativeArea = selectedPlace.administrativeArea ?? ""
                editedLocationPostcode = selectedPlace.postalCode ?? ""
                editedLocationCountry = selectedPlace.country ?? ""
                if let location = selectedPlace.location {
                    editedLocationLatitude = location.coordinate.latitude
                    editedLocationLongitude = location.coordinate.longitude
                }

                isSelectingLocation = false
            }
            .environmentObject(locationManager)
            .presentationDetents([.height(540)])
            .presentationCornerRadius(30)
            .presentationBackground(Color.white)
            .interactiveDismissDisabled()
        })
        .sheet(isPresented: $isSelectingImage, content: {
            ImagePickerView(images: $editedImage, show: $isSelectingImage)
                .edgesIgnoringSafeArea(.top)
                .edgesIgnoringSafeArea(.bottom)
        })
        .fileImporter(isPresented: $isSelectingFile, allowedContentTypes: [.data]) { result in
            switch result {
            case .success(let url):
                let importResult = BinaryDocument.importFile(from: url)

                editedFileData = importResult.data
                editedFileName = importResult.fileName ?? ""
                editedFileType = importResult.fileType ?? ""
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
