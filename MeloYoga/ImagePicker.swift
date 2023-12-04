//
//  ImagePicker.swift
//  MeloYoga
//

import Foundation
import SwiftUI

struct ImagePicker:UIViewControllerRepresentable{

    @Environment(\.dismiss) private var dismiss
    @Binding var image:UIImage?
    var selectedSource:UIImagePickerController.SourceType
    
    func makeUIViewController(context:Context) -> UIImagePickerController{
        let picker=UIImagePickerController()
        picker.sourceType = selectedSource
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController:UIImagePickerController, context:Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent:self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(parent: ImagePicker) {
            self.parent = parent
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                if let uiImage = info[.originalImage] as? UIImage {
                    parent.image = uiImage
                }
            parent.dismiss()
        }
    }

    
}

