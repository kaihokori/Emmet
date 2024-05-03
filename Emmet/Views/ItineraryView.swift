import SwiftUI
import CoreData
import MapKit

struct ItineraryView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(
        entity: Event.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Event.date, ascending: true)],
        predicate: NSPredicate(format: "isMarkedForDeletion == NO"),
        animation: .default
    ) var events: FetchedResults<Event>
    var groupedEvents: [Date: [Event]] {
        Dictionary(grouping: events, by: { event in
            if let date = event.date, let timeZoneIdentifier = event.timezone {
                let localDate = EventDateHelper.convertToLocalTime(date: date, timeZoneIdentifier: timeZoneIdentifier)
                return Calendar.current.startOfDay(for: localDate)
            }
            return Calendar.current.startOfDay(for: Date())
        })
    }
    @EnvironmentObject var locationManager: LocationManager
    
    @State private var isAddingEvent = false
    @State private var isFirstAppear = true
    
    var dateOfFirstUpcomingEvent: Date? {
        let upcomingEvent = events.first(where: { $0.date ?? Date() >= Date() })
        return upcomingEvent != nil ? Calendar.current.startOfDay(for: upcomingEvent!.date!) : nil
    }
    
    var body: some View {
        NavigationView {
            ScrollViewReader { scrollViewProxy in
                VStack(spacing: 10) {
                    HStack {
                        Text("Itinerary")
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(.primary)
                        Spacer()
                        Button(action: {
                            isAddingEvent = true
                        }) {
                            Image(systemName: "plus")
                                .foregroundStyle(Color.accentColor)
                                .imageScale(.large)
                        }
                    }
                    .padding(.top)
                    .padding(.horizontal)

                    ScrollView {
                        if events.isEmpty {
                            Text("Add a new event with the \(Image(systemName: "plus")) icon")
                        } else {
                            ForEach(groupedEvents.keys.sorted(), id: \.self) { date in
                                VStack(alignment: .leading) {
                                    let isFirstDate = date == groupedEvents.keys.sorted().first
                                    
                                    if groupedEvents.count > 1 {
                                        Text(EventDateHelper.formatDateLarge(date))
                                            .font(.system(size: 22))
                                            .offset(x: 30)
                                            .background(alignment: .leading) {
                                                if !isFirstDate {
                                                    Rectangle()
                                                        .frame(width: 1)
                                                        .offset(x: 9, y: -40)
                                                        .padding(.bottom, -95)
                                                }
                                            }
                                            .id(date)
                                    } else {
                                        Text(EventDateHelper.formatDateLarge(date))
                                            .font(.system(size: 22))
                                            .offset(x: 30)
                                            .id(date)
                                    }
                                    
                                    
                                    ForEach(groupedEvents[date] ?? [], id: \.self) { event in
                                        HStack {
                                            Circle()
                                                .fill(EventHelper.eventColor(eventType: event.type ?? ""))
                                                .frame(width: 10, height: 10)
                                                .padding(5)
                                                .background(Color.white.shadow(.drop(color: Color.black.opacity(0.2), radius: 3)), in: .circle)
                                            NavigationLink(destination: EventDetailView(eventInfo: event, locationManager: locationManager)) {
                                                EventRowView(eventInfo: event)
                                            }
                                        }
                                        .background(alignment: .leading) {
                                            if events.count > 1 {
                                                if events.first?.id == event.id {
                                                    Rectangle()
                                                        .frame(width: 1)
                                                        .offset(x: 9, y: 40)
                                                        .padding(.bottom, 0)
                                                } else if events.last?.id != event.id {
                                                    Rectangle()
                                                        .frame(width: 1)
                                                        .offset(x: 9, y: 0)
                                                        .padding(.bottom, -10)
                                                } else {
                                                    Rectangle()
                                                        .frame(width: 1)
                                                        .offset(x: 9, y: -35)
                                                        .padding(.bottom, 0)
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                }
                .onAppear {
                    if isFirstAppear {
                        if let upcomingDate = dateOfFirstUpcomingEvent {
                            scrollViewProxy.scrollTo(upcomingDate, anchor: .top)
                        }
                        isFirstAppear = false
                    }
                }
            }
        }
        .sheet(isPresented: $isAddingEvent) {
            EventAddView(locationManager: locationManager).environment(\.managedObjectContext, self.moc)
                .presentationDetents([.height(560)])
                .presentationCornerRadius(30)
                .presentationBackground(Color.white)
                .presentationDragIndicator(.visible)
        }
    }
}
