//
//  File.swift
//  flickr
//
//  Created by Amanda Baret on 2022/11/24.
//

import Foundation
import SwiftUI

struct LoadingView<Content>: View where Content: View {

    @Binding var isShowing: Bool
    var content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {

                self.content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 3 : 0)

                VStack {
                    ProgressView()
                }
                .frame(width: geometry.size.width,
                       height: geometry.size.height)
                .background(Color.white)
                .foregroundColor(Color.primary)
                .cornerRadius(14)
                .opacity(self.isShowing ? 1 : 0)

            }
        }
    }

}

