import SwiftUI
import SafariServices

struct CountryDetailView: View {
    var countryInfo: CountryInfo
    @State private var showEmbassy: Bool = false
    @State private var showSmartTraveller: Bool = false

    var body: some View {
        
        
        ScrollView {
            VStack(alignment: .leading) {
                Section {
                    Text("Advice Level")
                        .font(.title)
                        .foregroundStyle(.primary)
                        .bold()
                    Text("\(countryInfo.adviceLevel)")
                        .foregroundColor(AdviceLevelHelper.adviceLevelAltColor(for: countryInfo.adviceLevel))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(AdviceLevelHelper.adviceLevelColor(for: countryInfo.adviceLevel))
                        .cornerRadius(10)
                        .font(.headline)
                }
                
                Spacer()
                    .frame(height: 40)
                
                if !countryInfo.border[0].isEmpty || !countryInfo.border[1].isEmpty || !countryInfo.border[2].isEmpty {
                    Section {
                        Text("Border")
                            .font(.title)
                            .foregroundStyle(.primary)
                            .bold()
                        if !countryInfo.border[0].isEmpty {
                            SubSection(title: "Visa / Authorisation", icon: "checkmark.seal.fill", items: countryInfo.border[0])
                        }
                        if !countryInfo.border[1].isEmpty {
                            SubSection(title: "Duration", icon: "calendar.badge.clock", items: countryInfo.border[1])
                        }
                        
                        if !countryInfo.border[2].isEmpty {
                            SubSection(title: "Accommodation", icon: "building.2.fill", items: countryInfo.border[2])
                        }
                        
                        if !countryInfo.border[3].isEmpty {
                            SubSection(title: "Areas of Interest", icon: "mappin.and.ellipse", items: countryInfo.border[3])
                        }
                    }
                    Spacer()
                        .frame(height: 40)
                }
                
                Section {
                    Text("Overview")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .foregroundStyle(.primary)
                        .bold()
                    SubSection(title: "Safety", icon: "shield.checkered", items: countryInfo.safety)
                    SubSection(title: "Health", icon: "heart.fill", items: countryInfo.health)
                        .padding(.top)
                    SubSection(title: "Local Laws", icon: "scroll", items: countryInfo.safety)
                        .padding(.top)
                    SubSection(title: "Travel", icon: "airplane.departure", items: countryInfo.travel)
                        .padding(.top)
                }
                
                Spacer()
                    .frame(height: 40)
                
                Section {
                    Text("Resources")
                        .font(.title)
                        .foregroundStyle(.primary)
                        .bold()

                    HStack {
                        Image("embassy")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()
                            .onTapGesture {
                                showEmbassy.toggle()
                            }

                        Image("smarttraveller")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()
                            .onTapGesture {
                                showSmartTraveller.toggle()
                            }
                    }
                    .frame(height: 200)
                }

            }
            .padding()
        }
        .navigationTitle("\(countryInfo.name) \(countryInfo.flag)")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showEmbassy, content: {
            SFSafariViewWrapper(url: URL(string: countryInfo.embassy)!)
        })
        .fullScreenCover(isPresented: $showSmartTraveller, content: {
            SFSafariViewWrapper(url: URL(string: countryInfo.smarttraveller)!)
        })
    }
}

struct SubSection: View {
    var title: String
    var icon: String
    var items: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(Color.accentColor)
                    .imageScale(.large)
                Text(title)
                    .font(.headline)
                    .bold()
            }
            .padding(.top, 5)
            
            ForEach(items, id: \.self) { item in
                Text("• \(item)")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
        }
    }
}

struct SFSafariViewWrapper: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SFSafariViewWrapper>) {
        return
    }
}
