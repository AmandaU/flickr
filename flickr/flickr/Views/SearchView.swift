//
//  SearchView.swift
//  flickr
//
//  Created by Amanda Baret on 2022/11/24.
//

import SwiftUI

// manages the search function
public struct SearchBarView: View {
    @EnvironmentObject var store: ImagesStore
    
    @Binding var text: String
    
    @FocusState private var isFocused: Bool
    
    public init(_ text: Binding<String>) {
        self._text = text
    }
    
    public var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .frame(width: 20, height: 20)
                    .foregroundColor(.black.opacity(0.5))
                
                TextField("Search", text: $text)
                    .frame(maxWidth: .infinity)
                    .disableAutocorrection(true)
                    .onChange(of: text) { searchText in
                        if searchText.isEmpty {
                            store.loadLocal()
                        } else {
                            withAnimation {
                                store.history = []
                            }
                        }
                        self.store.doSearch(searchText)
                    }
                    .focused($isFocused)
                
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
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.12))
            )
            VStack {
                if !store.history.isEmpty {
                    Button {
                        store.clearHistory()
                    } label: {
                        Text("Clear history")
                    }
                    Divider()
                }
               
                ForEach(store.history, id: \.self) { search in
                    Button {
                        self.text = search
                    } label: {
                        Text(search)
                            .foregroundColor(.black)
                    }
                    Divider()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
