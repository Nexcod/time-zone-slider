//
//  AddCityView.swift
//  time-zone-slider
//
//  Full-screen "Add a city" overlay: search field and the catalog of
//  cities not yet on the board.
//

import SwiftUI

struct AddCityView: View {
    @Binding var model: TimeZoneModel
    @Binding var adding: Bool
    @State private var query = ""
    @FocusState private var searchFocused: Bool

    private var results: [City] { model.searchResults(query: query) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Add a city")
                    .font(Theme.heading(24))
                Spacer()
                Button {
                    adding = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Theme.neutral800)
                        .frame(width: 34, height: 34)
                        .background(Theme.neutral100, in: Circle())
                        .overlay(Circle().strokeBorder(Theme.divider, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")
            }
            .padding(.top, 8)
            .padding(.bottom, 12)

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.neutral600)
                TextField("Search city", text: $query)
                    .font(.system(size: 14))
                    .focused($searchFocused)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Theme.neutral100, in: Capsule())
            .overlay(Capsule().strokeBorder(Theme.divider, lineWidth: 1))
            .padding(.bottom, 14)

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(results) { city in
                        resultRow(city)
                    }
                    if results.isEmpty {
                        Text("No cities found")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.neutral600)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 30)
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.bg.ignoresSafeArea())
        .onAppear { searchFocused = true }
    }

    private func resultRow(_ city: City) -> some View {
        Button {
            model.add(city)
            adding = false
        } label: {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(city.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.text)
                    Text(city.country)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.neutral600)
                }
                Spacer()
                Text(model.gmtLabel(city))
                    .badge(background: Theme.neutral200, foreground: Theme.neutral700)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Theme.neutral100, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
