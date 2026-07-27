//
//  CityCardView.swift
//  time-zone-slider
//
//  One city card: name, offset badges, big local time, and the vertical
//  24-hour dial with a draggable knob that sets the shared moment.
//

import SwiftUI

struct CityCardView: View {
    @Binding var model: TimeZoneModel
    let index: Int
    let city: City
    let editing: Bool

    private var isHome: Bool { index == 0 }
    private var local: Double { model.localFraction(city) }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if editing {
                editControls
                    .frame(maxWidth: .infinity)
            }

            HStack(spacing: 5) {
                if isHome {
                    Image(systemName: "house")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Theme.accent600)
                }
                Text(city.name)
                    .font(Theme.heading(19))
                    .lineLimit(1)
            }
            .frame(minHeight: 24)

            HStack(spacing: 5) {
                Text(model.gmtLabel(city))
                    .badge(background: Theme.neutral200, foreground: Theme.neutral700)
                if isHome {
                    Text("Home")
                        .badge(background: Theme.accent200, foreground: Theme.accent800)
                }
                if let rel = model.relBadge(at: index) {
                    Text(rel)
                        .badge(background: Theme.accent2_200, foreground: Theme.accent2_800)
                }
            }
            .frame(minHeight: 22)

            HStack(alignment: .firstTextBaseline, spacing: 7) {
                Text(model.timeLabel(city))
                    .font(Theme.heading(29))
                if let day = model.dayBadge(city) {
                    Text(day)
                        .font(.system(size: 10.5, weight: .bold))
                        .foregroundStyle(Theme.accent700)
                }
            }
            .frame(minHeight: 36)

            dial
                .padding(.top, 2)
        }
        .padding(EdgeInsets(top: 12, leading: 12, bottom: 14, trailing: 12))
        .background(Theme.neutral100, in: RoundedRectangle(cornerRadius: Theme.radiusLg))
        .shadow(color: Theme.neutral900.opacity(0.14), radius: 1, y: 1)
    }

    private var editControls: some View {
        HStack(spacing: 8) {
            editButton(icon: "chevron.left", label: "Move left") {
                model.moveLeft(at: index)
            }
            Button {
                model.delete(at: index)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Theme.accent800)
                    .frame(width: 28, height: 28)
                    .background(Theme.accent200, in: Circle())
            }
            .accessibilityLabel("Remove city")
            editButton(icon: "chevron.right", label: "Move right") {
                model.moveRight(at: index)
            }
        }
        .buttonStyle(.plain)
    }

    private func editButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Theme.neutral800)
                .frame(width: 28, height: 28)
                .background(Theme.neutral200, in: Circle())
                .overlay(Circle().strokeBorder(Theme.divider, lineWidth: 1))
        }
        .accessibilityLabel(label)
    }

    private var dial: some View {
        GeometryReader { geo in
            let height = geo.size.height
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    ForEach(model.hourLabels) { hour in
                        Text(hour.label)
                            .font(.system(size: 10, weight: hour.bold ? .bold : .regular))
                            .foregroundStyle(hour.bold ? Theme.neutral800 : Theme.neutral600)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .background(Theme.neutral200)
                .clipShape(RoundedRectangle(cornerRadius: 20))

                knob
                    .offset(y: (local + 0.5) / 24 * height - 14)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        model.pick(cityIndex: index, fraction: value.location.y / height)
                    }
            )
        }
        .frame(maxHeight: .infinity)
    }

    private var knob: some View {
        Text(model.timeLabel(city))
            .font(Theme.heading(13))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 28)
            .background(Theme.accent500, in: Capsule())
            .overlay(Capsule().strokeBorder(Theme.neutral100, lineWidth: 2))
            .shadow(color: Theme.neutral900.opacity(0.16), radius: 5, y: 3)
            .padding(.horizontal, -6)
            .allowsHitTesting(false)
    }
}
