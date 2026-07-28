//
//  DialGestureView.swift
//  time-zone-slider
//
//  UIKit gesture layer for the hour dial. A pan recognizer that fails as
//  soon as the touch moves mostly horizontally, so the cards ScrollView
//  always wins left/right swipes, plus a tap that jumps the knob to the
//  touched hour. Reports the touch as a 0...1 vertical fraction.
//

import SwiftUI
import UIKit
import UIKit.UIGestureRecognizerSubclass

struct DialGestureView: UIViewRepresentable {
    var onPick: (Double) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear

        let pan = VerticalPanGestureRecognizer(
            target: context.coordinator, action: #selector(Coordinator.handle(_:)))
        pan.maximumNumberOfTouches = 1
        view.addGestureRecognizer(pan)

        let tap = UITapGestureRecognizer(
            target: context.coordinator, action: #selector(Coordinator.handle(_:)))
        view.addGestureRecognizer(tap)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.onPick = onPick
    }

    func makeCoordinator() -> Coordinator { Coordinator(onPick: onPick) }

    final class Coordinator: NSObject {
        var onPick: (Double) -> Void

        init(onPick: @escaping (Double) -> Void) {
            self.onPick = onPick
        }

        @objc func handle(_ recognizer: UIGestureRecognizer) {
            guard let view = recognizer.view, view.bounds.height > 0 else { return }
            if recognizer is UITapGestureRecognizer {
                guard recognizer.state == .ended else { return }
            } else {
                guard recognizer.state == .began || recognizer.state == .changed else { return }
            }
            let fraction = recognizer.location(in: view).y / view.bounds.height
            onPick(min(max(fraction, 0), 1))
        }
    }
}

/// A pan that only recognizes mostly-vertical drags: as soon as the first
/// few points of movement are dominated by the horizontal axis it fails,
/// handing the touch to the enclosing scroll view's pan.
final class VerticalPanGestureRecognizer: UIPanGestureRecognizer {
    private var startPoint: CGPoint?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        if startPoint == nil {
            startPoint = touches.first?.location(in: view)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        if state == .possible,
           let start = startPoint,
           let point = touches.first?.location(in: view) {
            let dx = abs(point.x - start.x)
            let dy = abs(point.y - start.y)
            if max(dx, dy) > 6, dx > dy {
                state = .failed
            }
        }
        super.touchesMoved(touches, with: event)
    }

    override func reset() {
        super.reset()
        startPoint = nil
    }
}
