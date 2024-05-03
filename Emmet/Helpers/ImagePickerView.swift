import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var images: Data
    @Binding var show: Bool
    
    func makeCoordinator() -> Coordinator {
        return ImagePickerView.Coordinator(img1: self)
    }
    
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var img0 : ImagePickerView
        init(img1 : ImagePickerView) {
            img0 = img1
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.img0.show.toggle()
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            let image = info[.originalImage] as? UIImage
            
            let data = image?.jpegData(compressionQuality: 1.0)
            
            self.img0.images = data!
            self.img0.show.toggle()
        }
    }
}
