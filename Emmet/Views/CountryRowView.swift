import SwiftUI

struct CountryRowView: View {
    var countryInfo: CountryInfo

    var body: some View {
        HStack {
            Text(countryInfo.flag)
                .font(.title)
                .padding(.trailing, 10)
            VStack(alignment: .leading) {
                Text(countryInfo.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(countryInfo.adviceLevel)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
        .cornerRadius(10)
    }
}
