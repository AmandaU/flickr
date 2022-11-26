//
//  FullImageView.swift
//  flickr
//
//  Created by Amanda Baret on 2022/11/26.
//

import Foundation
import UIKit
import SwiftUI
import Combine

@available(iOS 14.0, *)
@available(macCatalyst 14.0, *)
struct FullImageView: View {
    @EnvironmentObject var store: ImagesStore
    @Environment(\.presentationMode) var presentationMode
    @State var photo: Photo
    @State private var showShareSheet = false
    @State var image = UIImage()
    
    var url: URL {
        URL(string: "https://farm\(photo.farm).static.flickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_b.jpg")!
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        
                } placeholder: {
                    Text("")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }
            .background(Color.white.edgesIgnoringSafeArea(.bottom))
            .navigationBarTitle(photo.title, displayMode: .inline)
            .navigationBarItems(leading: backButton, trailing: shareButton)
            .sheet(isPresented: $showShareSheet) {
                    ShareSheetView(activityItems: [image])
            }
            .onAppear {
                store.downloadImage(from: url) { image in
                    self.image = image
                }
            }
        }
    }
    
    var shareButton: some View {
        Button {
            onShareClick()
        } label: {
            Image(systemName: "square.and.arrow.up")
                .foregroundColor(.accentColor)
        }
        .buttonStyle(.plain)
    }
    
    var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            HStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                Spacer()
            }
            .frame(width: 50)
        })
        .contentShape(Rectangle())
    }
    
    private func onShareClick() {
#if targetEnvironment(macCatalyst)
        let data = image.jpegData(compressionQuality: 1)
        let fileManager = FileManager.default // 2
        
        do {
            let fileURL = fileManager.temporaryDirectory.appendingPathComponent("\(photo.title).jpg")
            try data?.write(to: fileURL) // 4
            
            if UIApplication.shared.windows.count > 1, let viewController = UIApplication.shared.windows[UIApplication.shared.windows.count - 1].rootViewController {
                
                if #available(iOS 14, *) {
                    let controller = UIDocumentPickerViewController(forExporting: [fileURL]) // 5
                    viewController.present(controller, animated: true)
                } else {
                    let controller = UIDocumentPickerViewController(url: fileURL, in: .exportToService) // 6
                    viewController.present(controller, animated: true)
                }
                
            } else {
                self.showShareSheet = true
            }
        } catch {
            print("Error creating file")
        }
        
#else
        self.showShareSheet = true
#endif
    }
}

struct ShareSheetView: UIViewControllerRepresentable {
    typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
    
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil
    let callback: Callback? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // nothing to do here
    }
}
