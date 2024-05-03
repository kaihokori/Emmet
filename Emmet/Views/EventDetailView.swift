import SwiftUI
import MapKit
import UIKit

struct EventDetailView: View {
    let eventInfo: Event
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var locationManager: LocationManager
    
    @State private var isEditingEvent = false
    @State private var isDeletingEvent = false
    @State private var isExporting = false
    @State private var isShowingPDF = false
    
    var body: some View {
        ScrollView {
            VStack {
                let region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: (eventInfo.image != nil && !eventInfo.image!.isEmpty) ? (eventInfo.locationLatitude - 0.0028) : eventInfo.locationLatitude,
                        longitude: eventInfo.locationLongitude
                    ),
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                )
                ZStack {
                    Map(initialPosition: .region(region), interactionModes: []) {
                        Annotation(eventInfo.name ?? "", coordinate: CLLocationCoordinate2D(latitude: eventInfo.locationLatitude, longitude: eventInfo.locationLongitude)) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(EventHelper.eventColor(eventType: eventInfo.type ?? ""))
                                    .frame(width: 35, height: 35)
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 35, height: 35)
                                Image(systemName: EventHelper.eventIcon(eventType: eventInfo.type ?? ""))
                                    .foregroundStyle(EventHelper.eventAltColor(eventType: eventInfo.type ?? ""))
                                    .frame(width: 40, height: 40)
                                    .font(.system(size: 20))
                            }
                        }
                    }
                    .frame(height: 300)
                    HStack {
                        Spacer()
                        VStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.systemGroupedBackground))
                                    .frame(width: 40, height: 40)
                                    .shadow(radius: 4)
                                Button(action: {
                                    let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: eventInfo.locationLatitude, longitude: eventInfo.locationLongitude)))
                                    destination.name = eventInfo.name ?? "Destination"
                                    let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                                    destination.openInMaps(launchOptions: launchOptions)
                                }) {
                                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                        .foregroundStyle(Color.accentColor)
                                        .frame(width: 40, height: 40)
                                        .font(.system(size: 20))
                                }
                                .frame(width: 40, height: 40)
                            }
                            .padding(.top, 10)
                            .padding(.trailing, 10)
                            Spacer()
                        }
                    }
                }
                
                if let imageData = eventInfo.image,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .overlay{
                            Circle().stroke(Color.white, lineWidth: 4)
                        }
                        .shadow(radius: 7)
                        .offset(y: -130)
                        .padding(.bottom, -130)
                }
            }
            
            VStack(alignment: .leading) {
                Text(eventInfo.name ?? "")
                    .font(.title)
                    .foregroundStyle(.primary)
                    .bold()

                HStack {
                    Text(eventInfo.locationName ?? "")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if let locality = eventInfo.locationLocality, !locality.isEmpty {
                        if let postcode = eventInfo.locationPostcode, !postcode.isEmpty {
                            (Text(locality) + Text(" ") + Text(postcode))
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        } else {
                            Text(locality)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    } else if let postcode = eventInfo.locationPostcode, !postcode.isEmpty {
                        Text(postcode)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()
                
                HStack {
                    VStack(alignment: .leading) {
                        HStack(spacing: 0) {
                            Text("Date")
                                .font(.headline)
                                .bold()
                            Text("(\(eventInfo.timezone ?? ""))")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .padding(.leading, 5)
                        }
                        Text(EventDateHelper.formatDateMedium(eventInfo.date ?? Date()))
                            .font(.body)
                    }
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("Type")
                            .font(.headline)
                            .bold()
                        Text(eventInfo.type ?? "No Type")
                            .font(.body)
                    }
                }
                .padding(.bottom)
                
                VStack(alignment: .leading) {
                    Text("Address")
                        .font(.headline)
                        .bold()
                    Text(AddressHelper.formattedAddress(subThoroughfare: eventInfo.locationSubThoroughfare, thoroughfare: eventInfo.locationThoroughfare, locality: eventInfo.locationLocality, administrativeArea: eventInfo.locationAdministrativeArea, postalCode: eventInfo.locationPostcode, country: eventInfo.locationCountry))
                        .font(.body)
                }
                .padding(.bottom)

                if let notes = eventInfo.notes, !notes.isEmpty {
                    Text("Notes")
                        .font(.headline)
                        .bold()
                    Text(notes)
                        .font(.body)
                        .padding(.bottom)
                }
                
                if let fileName = eventInfo.fileName, !fileName.isEmpty, fileName != "" {
                    Button {
                        if eventInfo.fileType == "pdf" {
                            isShowingPDF = true
                        } else {
                            isExporting = true
                        }
                    } label: {
                        if eventInfo.fileType == "pdf" {
                            Label("View File", systemImage: "doc.viewfinder.fill")
                                .foregroundStyle(Color.accentColor)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .frame(height: 30)
                        } else {
                            Label("Download File", systemImage: "square.and.arrow.down")
                                .foregroundStyle(Color.accentColor)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .frame(height: 30)
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(Color.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fileExporter(isPresented: $isExporting,
                                  document: BinaryDocument(data: eventInfo.fileData ?? Data()),
                                  contentType: .data,
                                  defaultFilename: eventInfo.fileName ?? "document") { result in
                        if case .failure(let error) = result {
                            print(error.localizedDescription)
                        }
                    }
                    .padding(.bottom)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .toolbar {
            Menu {
                Button {
                    isEditingEvent = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                Button(role: .destructive) {
                    isDeletingEvent = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "gear")
            }
        }
        .sheet(isPresented: $isEditingEvent) {
            EventEditView(eventInfo: eventInfo, locationManager: locationManager)
                .environment(\.managedObjectContext, self.moc)
                .presentationDetents([.height(560)])
                .presentationCornerRadius(30)
                .presentationBackground(Color.white)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isShowingPDF) {
            if let pdfData = eventInfo.fileData, let fileName = eventInfo.fileName {
                DocumentView(data: pdfData, fileName: fileName)
            } else {
                Text("Failed to load PDF")
            }
        }
        .alert(isPresented: $isDeletingEvent) {
            Alert(
                title: Text("Confirm Deletion"),
                message: Text("Are you sure you want to delete this event?"),
                primaryButton: .destructive(Text("Delete")) {
                    eventInfo.isMarkedForDeletion = true
                    try? moc.save()
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
    }
}
