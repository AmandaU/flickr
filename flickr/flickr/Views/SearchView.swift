//
//  SearchView.swift
//  flickr
//
//  Created by Amanda Baret on 2022/11/24.
//

import SwiftUI

public struct SearchBarView: View {
    @Binding var text: String
    
    public init(_ text: Binding<String>) {
        self._text = text
    }
    
    public var body: some View {
        HStack {
            Image(systemName: "search")
                .frame(width: 20, height: 20)
                .foregroundColor(.black.opacity(0.5))
            
            TextField("Search", text: $text)
                .frame(maxWidth: .infinity)
                .disableAutocorrection(true)
            
            if text.count > 0 {
                Button {
                    self.text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .frame(width: 17, height: 17)
                        .foregroundColor(.black)
                        .opacity(0.35)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.12))
        )
    }
}
