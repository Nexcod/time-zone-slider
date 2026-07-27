//
//  TimeZonesView.swift
//  time-zone-slider
//
//  Main screen of the Timezone Converter design: header, horizontal strip
//  of city cards with draggable hour dials, and the add-city overlay.
//

import SwiftUI

struct TimeZonesView: View {
    @State private var model = TimeZoneModel()
    @State private var editing = false
    @State private var adding = false

    private var todayLine: String {
        let day = Date.now.formatted(
            .dateTime.weekday(.abbreviated).month(.abbreviated).day()
                .locale(Locale(identifier: "en_US"))
        )
        return "\(day) · drag a dial to convert"
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                    .padding(.bottom, 2)

                Text(todayLine)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.neutral600)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 8)

                cardsStrip
            }

            if adding {
                AddCityView(model: $model, adding: $adding)
                    .zIndex(30)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .foregroundStyle(Theme.text)
        .animation(.easeOut(duration: 0.2), value: adding)
        .animation(.easeOut(duration: 0.15), value: editing)
    }

    private var header: some View {
        HStack {
            Text("Time Zones")
                .font(Theme.heading(27))

            Spacer()

            HStack(spacing: 8) {
                Button("Now") {
                    model.resetToNow()
                }
                .font(Theme.heading(13))
                .foregroundStyle(Theme.text)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(Theme.neutral100, in: Capsule())
                .overlay(Capsule().strokeBorder(Theme.divider, lineWidth: 1))

                Button(editing ? "Done" : "Edit") {
                    editing.toggle()
                }
                .font(Theme.heading(13))
                .foregroundStyle(Theme.text)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(Theme.neutral100, in: Capsule())
                .overlay(Capsule().strokeBorder(Theme.divider, lineWidth: 1))

                Button {
                    adding = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Theme.accent500, in: Circle())
                        .shadow(color: Theme.neutral900.opacity(0.14), radius: 1, y: 1)
                }
                .accessibilityLabel("Add city")
            }
        }
        .buttonStyle(.plain)
    }

    private var cardsStrip: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(model.cities.enumerated()), id: \.element.id) { index, city in
                        CityCardView(model: $model, index: index, city: city, editing: editing)
                            .frame(width: 177)
                    }
                    addCard
                }
                .frame(height: geo.size.height - 44)
                .padding(.horizontal, 18)
                .padding(.top, 4)
                .padding(.bottom, 40)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
        }
    }

    private var addCard: some View {
        Button {
            adding = true
        } label: {
            VStack(spacing: 10) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .frame(width: 44, height: 44)
                    .background(Theme.accent200, in: Circle())
                Text("Add city")
                    .font(Theme.heading(14))
            }
            .foregroundStyle(Theme.accent700)
            .frame(width: 120)
            .frame(maxHeight: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusLg)
                    .strokeBorder(Theme.accent300, style: StrokeStyle(lineWidth: 2, dash: [7, 7]))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TimeZonesView()
}
