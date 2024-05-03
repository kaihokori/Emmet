import SwiftUI
import PDFKit

struct DocumentView: View {
    let data: Data
    let fileName: String
    @Environment(\.presentationMode) var presentationMode
    @State private var isExporting = false

    var body: some View {
        VStack {
            HStack {
                Button("Dismiss") {
                    presentationMode.wrappedValue.dismiss()
                }
                Spacer()
                Button("Download") {
                    isExporting = true
                }
            }
            .padding(.top)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)

            PDFKitRepresentedView(data: data)
                .edgesIgnoringSafeArea(.all)
        }
        .fileExporter(
            isPresented: $isExporting,
            document: BinaryDocument(data: data),
            contentType: .pdf,
            defaultFilename: fileName) { result in
                if case .failure(let error) = result {
                    print("Export failed: \(error.localizedDescription)")
                }
        }
    }
}

struct PDFKitRepresentedView: UIViewRepresentable {
    let data: Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: data)
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        //
    }
}
