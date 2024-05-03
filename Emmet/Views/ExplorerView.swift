import SwiftUI
import CoreLocation
import MapKit

struct ExplorerView: View {
    @EnvironmentObject var locationManager: LocationManager
    @FetchRequest(
        entity: Event.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Event.date, ascending: true)],
        predicate: NSPredicate(format: "isMarkedForDeletion == NO"),
        animation: .default
    ) var events: FetchedResults<Event>
    var isHidingPastEvents = UserDefaults.standard.bool(forKey: "hide_events")
    let isOverridden = UserDefaults.standard.bool(forKey: "emergency_override")
    @State private var isShowingEmergencyOptions = false
    
    let emergencyNumbers = [
        "Australia": "000",
        "Qatar": "999",
        "Austria": "112",
        "Switzerland": "112",
        "United Kingdom": "999",
        "United States": "911",
        "Canada": "911"
    ]

    let qatarInfo = CountryInfo(name: "Qatar",
                                flag: "🇶🇦",
                                adviceLevel: "Exercise normal safety precautions",
                                border: [[], [],[],[]],
                                safety: ["Conflict in other areas of the Middle East and Gulf region could affect Qatar. Demonstrations and protests can occur and may turn violent. Avoid protests and large public gatherings as they can turn violent. Monitor local and international media and follow the advice of local authorities.",
                                         "Several terrorist attacks have happened in the wider Gulf region in recent years. Terrorists may target tourist areas and attractions. More attacks could occur. If there's a security incident, follow the advice of local authorities.",
                                         "Qatar has a low crime rate. Pickpocketing, bag snatching and other petty crimes are rare but can happen. Keep an eye on your belongings, especially in crowded places.",
                                         "Bank and credit card fraud can occur. Always keep your credit card in sight when shopping.",
                                         "Be prepared for extreme weather. From June to September, temperatures can reach over 50˚C. Flash flooding can sometimes happen. Follow the advice of local officials."],
                                health: ["Cases of Middle East Respiratory Syndrome coronavirus have been reported in Qatar. Avoid contact with camels and products contaminated with camel secretions.",
                                         "Qatar can experience periods of high air pollution. Sand and dust storms can also worsen breathing issues. Talk to your doctor before you travel if you have concerns.",
                                         "Get comprehensive travel insurance before you leave. The mandatory medical insurance required by all visitors to Qatar only covers medical treatment in Qatar, not other common issues relating to travel, for example, lost luggage."],
                                localLaws: ["Qatari laws and customs are very different to those in Australia. If you're detained or arrested, ask police or prison officials to inform the Australian Embassy in Doha.",
                                            "Don't use or carry illegal drugs. Penalties for drug offences include long jail terms. Authorities can detain and deport you if you carry medication to treat HIV and hepatitis. This can also happen if you test positive for either illness.",
                                            "Sex outside of marriage is illegal. If you're the victim of a sexual assault, authorities may arrest, detain or prosecute you for adultery. If you're sexually assaulted in Qatar, ask us for consular help and advice on available support services immediately.",
                                            "Qatar has conservative codes of dress and behaviour. Visitors are expected to cover their shoulders and knees when visiting public places, including museums and other government buildings. If you're at tourist attractions, shopping malls and other public places, check the specific dress codes at the venue or online.",
                                            "Avoid commenting on Qatari culture, government policy or services, and commercial enterprises online while in Qatar. This includes reviewing hotel or restaurant experiences on social media. These activities could be considered cybercrime offences in Qatar."],
                                travel: ["From 1 February, all visitors must purchase health insurance for the duration of their stay in Qatar. You can purchase insurance from companies approved by the Qatari Ministry of Public Health at a standard cost of 50 Qatari Riyals per month, either prior to or on arrival in Qatar. Health insurance policies purchased outside Qatar may not meet Qatari entry requirements – please check with Ministry of Public Health if in doubt.",
                                         "You may be asked to show proof of your accommodation for the duration of your stay in Qatar on arrival at Hamad International Airport.",
                                         "If you have an existing Hayya Card that was obtained to enter Qatar during the 2022 FIFA World Cup, you can use it to enter Qatar until 24 January 2024, provided you meet other entry requirements such as proof of accommodation, health insurance and onwards travel. You can no longer apply for a Hayya card to enter Qatar. If you don't have a Hayya card, you'll need a visa to enter. You may be eligible for a visa on arrival. Entry and exit conditions can change at short notice. Contact the nearest embassy or consulate of Qatar for the latest details.",
                                         "Driving in Qatar can be difficult and dangerous. Make sure you understand local laws and practices. It's illegal to use obscene language or hand gestures in traffic. It's also illegal to drive after drinking any amount of alcohol.",
                                         "Many areas of the Gulf are sensitive to security issues and territorial disputes. There's also a risk of piracy. If you're planning sea travel, refer to the International Maritime Bureau's piracy reports."],
                                embassy: "http://www.qatar.embassy.gov.au/",
                                smarttraveller: "https://www.smartraveller.gov.au/destinations/middle-east/qatar?")
    let austriaInfo = CountryInfo(name: "Austria",
                                  flag: "🇦🇹",
                                  adviceLevel: "Exercise normal safety precautions",
                                  border: [[], ["Staying for 10 days", "Leaving on the 29th of December", "Departing from Zurich International Airport"],
                                           ["Unknown (Vienna)", "Hotel Neue Post (Innsbruck)", "Hotel Alberg (St Anton)"],
                                           ["Vienna", "Innsbruck", "St Anton"]],
                                  safety: ["Always be alert to terrorism. Terrorists have targeted European cities, including Vienna. They may target public recreation and entertainment areas, transport hubs and places visited by travellers.",
                                           "Petty crime, such as bag snatching and pickpocketing, is common. Be careful on public transport and in areas popular with tourists. Take care using ATMs.",
                                           "Avalanches, flash floods and mudslides occur in alpine areas. Monitor local weather. Follow the advice of local authorities. Stick to marked slopes and trails when skiing, hiking and mountain climbing."],
                                  health: ["Take care in forests and rural areas where ticks carry encephalitis. Ticks are active from spring to autumn. Check your body for ticks and remove them as soon as possible.",
                                           "Health care standards are high. So are medical costs. Most doctors speak English."],
                                  localLaws: ["Don't use or carry illegal drugs. Penalties include heavy fines and prison sentences for carrying even small amounts of drugs.",
                                              "Always carry your ID.",
                                              "It's illegal to cover your face in public places to hide your identity.",
                                              "Dual nationals may have to complete national service. Check with the embassy or consulate of Austria."],
                                  travel: ["Austria is part of the Schengen area, meaning you can enter without a visa in some cases. In other situations, you'll need to get a visa.",
                                           "Entry and exit conditions can change at short notice. You should contact the nearest embassy or consulate of Austria for the latest details."],
                                  embassy: "https://austria.embassy.gov.au/",
                                  smarttraveller: "https://www.smartraveller.gov.au/destinations/europe/austria?")
    let switzerlandInfo = CountryInfo(name: "Switzerland",
                                      flag: "🇨🇭",
                                      adviceLevel: "Exercise normal safety precautions",
                                      border: [[], [],[],[]],
                                      safety: ["Serious crime levels are low, but petty crime is on the rise. Take care at tourist spots and on transport, including overnight trains. Watch out for thieves who use distraction techniques. Keep your belongings close.",
                                               "Terrorists have targeted European cities, including transport hubs, churches, other houses of worship and places visited by travellers. Always be alert. Take official warnings seriously.",
                                               "Avalanches, flash floods, rock falls, mudslides and sudden weather changes occur in alpine areas. Monitor local weather. Follow the advice of authorities. Stick to marked slopes and trails when skiing."],
                                      health: ["The level of health care in Switzerland is high. All foreigners receive the same level of medical care as Swiss residents.",
                                               "There are no public hospitals in Switzerland. You may need to guarantee payment in advance. Costs can be extremely high. Contact your travel insurance provider for advice."],
                                      localLaws: ["Don't use or carry drugs. Penalties are severe.",
                                                  "If you're convicted of a crime, and you're a foreign national, you may be expelled from Switzerland and unable to return for a long time."],
                                      travel: ["Switzerland is part of the Schengen area with many other European countries.",
                                               "Entry and exit conditions can change at short notice. You should contact the nearest embassy or consulate of Switzerland for the latest details.",
                                               "Visit the Swiss Government's Travelcheck website to check if and under what conditions you can enter Switzerland."],
                                      embassy: "https://geneva.mission.gov.au/gene/contact-us.html",
                                      smarttraveller: "https://www.smartraveller.gov.au/destinations/europe/switzerland?")
    let unitedKingdomInfo = CountryInfo(name: "United Kingdom",
                                        flag: "🇬🇧",
                                        adviceLevel: "Exercise a high degree of caution",
                                        border: [[], ["Staying for 5 days", "Leaving on the 2nd of January", "Departing from Heathrow International Airport"],
                                                 ["DoubleTree by Hilton St. Anne’s Manor (Wokingham)"],
                                                 ["London CBD", "Bracknell"]],
                                        safety: ["On 28 March, the terrorism threat level for Northern Ireland was raised from 'substantial' to 'severe', meaning an attack is highly likely.",
                                                 "International terrorists have staged attacks in the UK. The UK Government's national terrorism threat level is 'substantial', meaning it assesses an attack is likely.",
                                                 "Islamic extremism, extreme right-wing ideology and the status of Northern Ireland contribute to the threat. Always be alert to terrorism. Take official warnings seriously.",
                                                 "Avoid areas where protests are occurring due to the potential for disruption and violence. Monitor the media for information and updates. Follow the instructions of local authorities."],
                                        health: ["Stay up to date with public health guidance and confirm coverage with your insurance provider.",
                                                 "Make sure your vaccinations are up-to-date before you travel, and ensure you have comprehensive travel insurance.",
                                                 "The standard of medical facilities in the UK is good.",
                                                 "We have a reciprocal healthcare agreement with the UK. Some GP and hospital treatments are free if you're in the UK for a short visit. If you stay more than 6 months, you'll pay a surcharge when applying for your visa."],
                                        localLaws: ["Penalties for drug offences are severe. Don't use or carry illegal drugs."],
                                        travel: ["Regular strikes can occur across several industries, including ambulance services, hospitals and public transport. Check National Rail or the Transport for London websites for the latest service updates.",
                                                 "If you're travelling to the UK as a tourist for less than 6 months, you usually don't require a visa. If you plan to visit the UK for more than 6 months or for any purpose other than tourism, you should consult UK Home Office for the most up-to-date information.",
                                                 "Entry and exit conditions can change at short notice. You should contact the nearest high commission or consulate of the United Kingdom for the latest details."],
                                        embassy: "https://uk.highcommission.gov.au/",
                                        smarttraveller: "https://www.smartraveller.gov.au/destinations/europe/united-kingdom")
    let unitedStatesOfAmericaInfo = CountryInfo(name: "United States of America",
                                                flag: "🇺🇸",
                                                adviceLevel: "Exercise normal safety precautions",
                                                border: [["Kyle: 2218077Y0S20630F", "Paul: 1612S75601314Q24"], ["Staying for 24 days", "Leaving on the 25th of January", "Departing from San Francisco International Airport"],
                                                         ["The Tuscany Powered by LuxUrban (New York City)", "Best Western InnSuites Phoenix Hotel & Suites (Phoenix)", "Desert Palms Hotel & Suites (Los Angeles)", "Holiday Inn (San Francisco)", "Harveys Resort & Casino (Lake Tahoe)"],
                                                         ["New York City", "Austin", "Phoenix", "Los Angeles", "San Francisco", "Lake Tahoe"]],
                                                safety: ["Avoid areas where demonstrations and protests are occurring due to the potential for unrest and violence. Monitor media for information and updates. Follow the instructions of local authorities and abide by any curfews in place.",
                                                         "Violent crime is more common than in Australia. Gun crime is also prevalent. If you live in the US, learn and practice active shooter drills.",
                                                         "There is a persistent and heightened threat of terrorist attacks and mass casualty violence in the US. Be alert, particularly in public places and at events.",
                                                         "Severe weather and natural hazards include earthquakes, volcanic eruptions, tsunamis, landslides, avalanches, hurricanes, tornadoes, winter storms, extreme temperatures, wildfires, and floods. Monitor weather conditions and follow the advice and instructions of local authorities."],
                                                health: ["Medical costs in the US are extremely high. You may need to pay up-front for medical assistance. Ensure you have comprehensive travel insurance.",
                                                         "Make sure your vaccinations are up-to-date before you travel.",
                                                         "Insect-borne illnesses are a risk in parts of the US. Tick-borne ailments are also common. Make sure your accommodation is insect-proof. Use insect repellent."],
                                                localLaws: ["Check local drug laws, including those related to the possession and recreational and/or medical use of marijuana. These vary between states. Penalties are severe and can include mandatory minimum sentences.",
                                                            "Some prescription and over-the-counter medications readily available in Australia are illegal in the US. It's also illegal to possess prescription medication without a prescription.",
                                                            "The federal age for buying and drinking alcohol is 21. However, state laws regarding possession and consumption can vary. Check relevant state laws.",
                                                            "Some states have laws restricting access to abortion and other reproductive health care services. Research local laws and consult your doctor before making any decisions about your medical care.",
                                                            "There's no federal law that explicitly protects LGBTQIA+ people from discrimination. Some US states and localities have laws that may affect LGBTQIA+ travellers.",
                                                            "Some states apply the death penalty for serious crimes. The death penalty can also apply to serious federal offences, even if committed in states without capital punishment."],
                                                travel: ["Entry requirements are strict. US authorities have broad powers to decide if you're eligible to enter and may determine that you are inadmissible for any reason under US law. Check US entry, transit and exit requirements.",
                                                         "If you're visiting for less than 90 days, you may be eligible to apply for an Electronic System for Travel Authorization (ESTA) and enter the US under the Visa Waiver Program (VWP). If not, you'll need to get a visa before you travel. Whether you're travelling on a visa or under the VWP, ensure that you understand all relevant terms and conditions before attempting to enter the US.",
                                                         "While COVID-related travel restrictions have been removed, you might still be denied boarding if you show signs of illness. Expect enhanced screening procedures, including for domestic flights within the US.",
                                                         "US authorities actively pursue, detain and deport people who are in the country illegally. Be prepared to show documents proving your legal presence.",
                                                         "Some US states may let you drive on your Australian driver's licence. Others require you to have an International Driving Permit (IDP). Get your IDP before you leave Australia. Road rules vary between localities and states. Learn local traffic rules and driving conditions before you drive."],
                                                embassy: "https://usa.embassy.gov.au/",
                                                smarttraveller: "https://www.smartraveller.gov.au/destinations/americas/united-states-america")
    let canadaInfo = CountryInfo(name: "Canada",
                                 flag: "🇨🇦",
                                 adviceLevel: "Exercise normal safety precautions",
                                 border: [["Kyle: PB4266158 (Exp: 17th August 2028)", "Paul: J526975014 (Exp: 1st June 2028)"], ["Staying for 9 days", "Leaving on the 2nd of February", "Departing from Vancouver International Airport"],
                                          ["Hyatt Regency (Downtown Vancouver)", "Pan Pacific Whistler Mountainside (Whistler Blackcomb)", "Raddison Blu (Vancouver Airport)"],
                                          ["Vancouver Downtown and Whistler Blackcomb"]],
                                 safety: ["Wildfires are still continuing, particularly in Western Canada. Check the latest information at Provincial and Territorial wildfire information.",
                                          "Avoid areas in which demonstrations and protests are occurring. Follow instructions of local authorities.",
                                          "Canada has a similar crime rate to Australia. Crime is more likely to occur in larger cities. Petty crime can occur in tourist areas and on public transport. Look after your belongings. Theft from cars is common in larger cities. Don't leave valuables in your vehicle. Credit card scams and fraud occur. Check your statements often.",
                                          "Bears and other dangerous wildlife live in forested areas. Get local advice before hiking.",
                                          "Canada can experience severe weather. This includes tornadoes and hurricanes in summer, and extreme cold, ice and heavy snowfalls in winter. Monitor the media and official sources for weather alerts."],
                                 health: ["Australia and Canada don't have a reciprocal health care agreement. You won't get free health care unless you're a local resident. Ensure your travel insurance covers medical costs."],
                                 localLaws: ["The legal drinking age varies across the country. Check local laws before buying or drinking alcohol.",
                                             "Using marijuana (cannabis) in Canada is legal, subject to local restrictions. Check local laws on legal age, possession and other restrictions. It's illegal to take marijuana out of the country.",
                                             "Canada recognises dual nationality. Use your Canadian passport to enter and exit. Make sure both your Canadian and Australian passports are valid for your entire trip."],
                                 travel: ["Check the latest entry, transit and exit requirements before travel.",
                                          "Get an electronic travel authorisation (eTA) before you travel to Canada by air. You may not be allowed into the country if you have a criminal record, including a drink driving conviction.",
                                          "Entry and exit conditions can change at short notice. You should contact the nearest high commission or consulate of Canada for the latest details. You may need documents to travel with children or pets or to bring goods into Canada. Check with the Canada Border Services Agency (CBSA).",
                                          "Driving in winter can be dangerous. Use snow tires and drive to conditions. Carry food, water and blankets.",
                                          "Winter sports can be dangerous, even fatal. Some areas experience avalanches. Check that your travel insurance covers your chosen activity. Follow the advice of local officials."],
                                 embassy: "https://canada.highcommission.gov.au/",
                                 smarttraveller: "https://www.smartraveller.gov.au/destinations/americas/canada?")
    
    var countries: [CountryInfo] {
        [qatarInfo, austriaInfo, switzerlandInfo, unitedKingdomInfo, unitedStatesOfAmericaInfo, canadaInfo]
    }
    
    @State public var isShowingMap = false
    @State private var isShowingCallingError = false

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                HStack {
                    Text("Explorer")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.primary)
                    Spacer()

                    if isOverridden {
                        Button(action: {
                            isShowingEmergencyOptions = true
                        }) {
                            Image(systemName: "phone.fill")
                                .foregroundStyle(.red)
                                .imageScale(.large)
                        }
                    } else if let country = locationManager.currentCountry, let number = emergencyNumbers[country] {
                        Button(action: {
                            callEmergencyNumber(number)
                        }) {
                            Image(systemName: "phone.fill")
                                .foregroundStyle(.red)
                                .imageScale(.large)
                        }
                    } else {
                        Button(action: {
                            isShowingCallingError = true
                        }) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                                .imageScale(.large)
                        }
                    }
                }
                .padding(.top)
                .padding(.horizontal)
                
                ScrollView {
                    ForEach(countries, id: \.name) { country in
                        NavigationLink(destination: CountryDetailView(countryInfo: country)) {
                            CountryRowView(countryInfo: country)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                    }
                }
                
                ZStack {
                    Map(position: $locationManager.currentRegion) {
                        ForEach(events, id: \.self) { event in
                            if !isHidingPastEvents || event.date ?? Date() > Date() {
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
                                    }
                                }
                            }
                        }
                    }
                    .mapStyle(.standard(elevation: .realistic))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .disabled(true)
                    
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                isShowingMap = true
                            }) {
                                ZStack {
                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                                        .foregroundStyle(Color.accentColor)
                                        .frame(width: 40, height: 40)
                                        .font(.system(size: 20))
                                }
                                .background(.thickMaterial, in: .rect(cornerRadius: 10))
                            }
                        }
                        .padding(.top, 8)
                        .padding(.trailing, 8)
                        Spacer()
                    }
                }
                .onAppear {
                    locationManager.manager.requestLocation()
                }
                .padding(.horizontal)
                .frame(height: 200)
            }
        }
        .fullScreenCover(isPresented: $isShowingMap) {
            MapView(fetchedEvents: events, isShowingMap: $isShowingMap, position: $locationManager.currentRegion)
                .environmentObject(locationManager)
        }
        .actionSheet(isPresented: $isShowingEmergencyOptions) {
            ActionSheet(
                title: Text("Select an Emergency Number"),
                buttons: emergencyNumberButtons()
            )
        }
        .alert(isPresented: $isShowingCallingError) {
            Alert(
                title: Text("Calling Error"),
                message: Text("Unable to determine your location or make a call. Please close the app and try again."),
                dismissButton: .default(Text("Dismiss"))
            )
        }
    }
    
    private func emergencyNumberButtons() -> [ActionSheet.Button] {
        let orderedCountries = ["Australia", "Qatar", "Austria", "Switzerland", "United Kingdom", "United States", "Canada"]
        
        var buttons = orderedCountries.compactMap { country -> ActionSheet.Button? in
            guard let number = emergencyNumbers[country] else { return nil }
            return ActionSheet.Button.default(Text("\(country) (\(number))")) {
                callEmergencyNumber(number)
            }
        }
        
        buttons.append(.cancel())
        return buttons
    }

    private func callEmergencyNumber(_ number: String) {
        let tel = "tel://"
        let formattedNumber = tel + number
        guard let url = URL(string: formattedNumber), UIApplication.shared.canOpenURL(url) else {
            self.isShowingCallingError = true
            return
        }
        UIApplication.shared.open(url)
    }
}
