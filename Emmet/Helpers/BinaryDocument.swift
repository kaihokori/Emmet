import SwiftUI
import UniformTypeIdentifiers

struct BinaryDocument: FileDocument {
    var data: Data

    init(data: Data = Data()) {
        self.data = data
    }

    static var readableContentTypes: [UTType] { [.pdf] }
    static var writableContentTypes: [UTType] { [.pdf] }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: self.data)
    }
    
    static func importFile(from url: URL) -> (data: Data?, fileName: String?, fileType: String?) {
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        do {
            let fileData = try Data(contentsOf: url)
            let fileName = url.lastPathComponent
            let fileType = url.pathExtension
            return (fileData, fileName, fileType)
        } catch {
            print("Error reading file: \(error.localizedDescription)")
            return (nil, nil, nil)
        }
    }
}
