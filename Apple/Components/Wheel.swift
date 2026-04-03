//
//  WheelView.swift
//  Apple
//
//  Created by SETH HUFFMAN on 3/31/26.
//

import SwiftUI

// MARK: - Wheel Data Models

struct Spirit {
    let name: String
    let color: UIColor
    let altColor: UIColor
}

struct FlavorProfile {
    let name: String
    let color: UIColor
    let altColor: UIColor
}

// MARK: - Data

let spirits: [Spirit] = [
    Spirit(name: "Whiskey", color: UIColor(hex: "2ABFCE"), altColor: UIColor(hex: "3DD9EB")),
    Spirit(name: "Rum",     color: UIColor(hex: "259BAA"), altColor: UIColor(hex: "31C4D6")),
    Spirit(name: "Tequila", color: UIColor(hex: "1E8090"), altColor: UIColor(hex: "28A8BB")),
    Spirit(name: "Gin",     color: UIColor(hex: "2ABFCE"), altColor: UIColor(hex: "3DD9EB")),
    Spirit(name: "Vodka",   color: UIColor(hex: "259BAA"), altColor: UIColor(hex: "31C4D6")),
    Spirit(name: "Brandy",  color: UIColor(hex: "1E8090"), altColor: UIColor(hex: "28A8BB")),
]

let flavors: [FlavorProfile] = [
    FlavorProfile(name: "Smokey",   color: UIColor(hex: "4A7A85"), altColor: UIColor(hex: "5C909C")),
    FlavorProfile(name: "Fruity",   color: UIColor(hex: "3D6B75"), altColor: UIColor(hex: "4E8090")),
    FlavorProfile(name: "Herbal",   color: UIColor(hex: "336070"), altColor: UIColor(hex: "427585")),
    FlavorProfile(name: "Spicy",    color: UIColor(hex: "4A7A85"), altColor: UIColor(hex: "5C909C")),
    FlavorProfile(name: "Sweet",    color: UIColor(hex: "3D6B75"), altColor: UIColor(hex: "4E8090")),
    FlavorProfile(name: "Citrusy",  color: UIColor(hex: "336070"), altColor: UIColor(hex: "427585")),
    FlavorProfile(name: "Floral",   color: UIColor(hex: "4A7A85"), altColor: UIColor(hex: "5C909C")),
    FlavorProfile(name: "Bitter",   color: UIColor(hex: "3D6B75"), altColor: UIColor(hex: "4E8090")),
]

// MARK: - Wheel Selector View

struct WheelSelectorView: View {
    @Binding var selectedSpirit: String
    @Binding var selectedFlavor: String
    let onCraft: () -> Void

    @State private var outerAngle: Double = 0
    @State private var innerAngle: Double = 0

    // Adjusted radii for the visual hierarchy
    private let outerRadius: CGFloat      = 350
    private let outerInnerRadius: CGFloat = 250
    private let innerRadius: CGFloat      = 250
    private let coreRadius: CGFloat       = 150
    private let wheelSize: CGFloat        = 720

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                Text("Explore Your")
                    .font(.custom("Nunito-Black", size: 20))
                    .foregroundColor(DS.cyan)
                Text("Perfect Cocktail")
                    .font(.custom("Nunito-ExtraBold", size: 28))
                    .foregroundColor(DS.text)
                Text("Spin both rings, then tap Create")
                    .font(.custom("Nunito-Medium", size: 12))
                    .foregroundColor(DS.textMid)
                    .padding(.bottom, 20)
            }
            .padding(.top, 140)

            HStack(spacing: 10) {
                Text(selectedSpirit)
                    .font(.custom("Nunito-ExtraBold", size: 15))
                    .padding(.horizontal, 22).padding(.vertical, 9)
                    .background(DS.cyan).foregroundColor(.white).clipShape(Capsule())
                Text("×").foregroundColor(DS.textLight)
                Text(selectedFlavor)
                    .font(.custom("Nunito-ExtraBold", size: 15))
                    .padding(.horizontal, 22).padding(.vertical, 9)
                    .background(DS.white).foregroundColor(DS.text).clipShape(Capsule()).cardShadow()
            }

            Spacer()

            ZStack(alignment: .top) {
                Triangle().fill(DS.cyan).frame(width: 25, height: 18).zIndex(2)

                ZStack {
                    WheelCanvas(
                        outerAngle: $outerAngle,
                        innerAngle: $innerAngle,
                        outerRadius: outerRadius,
                        outerInnerRadius: outerInnerRadius,
                        innerRadius: innerRadius,
                        coreRadius: coreRadius,
                        size: wheelSize,
                        onSelectionChange: updateSelection
                    )
                    .frame(width: wheelSize, height: wheelSize)

                    // Button sized to match the inner circle (coreRadius * 2)
                    Button(action: onCraft) {
                        ZStack {
                            Circle()
                                .fill(DS.cyanMid)
                                .shadow(color: DS.text.opacity(0.4), radius: 15)
                            
                            Text("Create")
                                .font(.custom("Nunito-Black", size: 38))
                                .foregroundColor(DS.text)
                                .tracking(1.2)
                        }
                    }
                    .frame(width: coreRadius * 2, height: coreRadius * 2)
                    .buttonStyle(ScaleButtonStyle())
                }
                .frame(width: wheelSize, height: wheelSize / 2, alignment: .top)
                .padding(.top, 18)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func updateSelection() {
        selectedSpirit = getSelected(angle: outerAngle, items: spirits.map(\.name))
        selectedFlavor = getSelected(angle: innerAngle, items: flavors.map(\.name))
    }

    private func getSelected(angle: Double, items: [String]) -> String {
        let slice = (2 * Double.pi) / Double(items.count)
        let n = ((-Double.pi / 2 - angle).truncatingRemainder(dividingBy: 2 * .pi) + 2 * .pi).truncatingRemainder(dividingBy: 2 * .pi)
        return items[Int(n / slice) % items.count]
    }
}

// MARK: - Canvas & Interaction Logic

struct WheelCanvas: UIViewRepresentable {
    @Binding var outerAngle: Double
    @Binding var innerAngle: Double
    let outerRadius: CGFloat
    let outerInnerRadius: CGFloat
    let innerRadius: CGFloat
    let coreRadius: CGFloat
    let size: CGFloat
    let onSelectionChange: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WheelUIView {
        let v = WheelUIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        v.coordinator = context.coordinator
        v.configure(outerRadius: outerRadius, outerInnerRadius: outerInnerRadius, innerRadius: innerRadius, coreRadius: coreRadius)
        v.addGestureRecognizer(UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:))))
        return v
    }

    func updateUIView(_ v: WheelUIView, context: Context) {
        v.outerAngle = outerAngle
        v.innerAngle = innerAngle
        v.setNeedsDisplay()
    }

    class Coordinator: NSObject {
        var parent: WheelCanvas
        var draggingRing: String?
        var lastAngle: CGFloat = 0
        var velocity: CGFloat = 0
        var lastTime: TimeInterval = 0
        var displayLink: CADisplayLink?
        var coastAngle: CGFloat = 0
        var coastRing = ""
        let feedback = UISelectionFeedbackGenerator()

        init(_ parent: WheelCanvas) { self.parent = parent }

        @objc func handlePan(_ g: UIPanGestureRecognizer) {
            let loc = g.location(in: g.view)
            let dx = loc.x - (g.view?.bounds.midX ?? 0), dy = loc.y - (g.view?.bounds.midY ?? 0)
            let dist = sqrt(dx*dx + dy*dy), angle = atan2(dy, dx)

            switch g.state {
            case .began:
                displayLink?.invalidate()
                lastAngle = angle; velocity = 0; lastTime = CACurrentMediaTime()
                if dist > parent.coreRadius && dist < parent.innerRadius { draggingRing = "inner" }
                else if dist > parent.outerInnerRadius && dist < parent.outerRadius { draggingRing = "outer" }
                feedback.prepare()
            case .changed:
                guard let ring = draggingRing else { return }
                var delta = angle - lastAngle
                if delta > .pi { delta -= 2 * .pi } else if delta < -.pi { delta += 2 * .pi }
                let dt = CACurrentMediaTime() - lastTime
                if dt > 0 { velocity = delta / CGFloat(dt) }
                if ring == "outer" { parent.outerAngle += Double(delta) } else { parent.innerAngle += Double(delta) }
                lastAngle = angle; lastTime = CACurrentMediaTime()
                parent.onSelectionChange()
            case .ended:
                coastRing = draggingRing ?? ""; coastAngle = velocity * 0.5
                draggingRing = nil; startCoast()
            default: break
            }
        }

        func startCoast() {
            displayLink = CADisplayLink(target: self, selector: #selector(coastStep))
            displayLink?.add(to: .main, forMode: .common)
        }

        @objc func coastStep() {
            coastAngle *= 0.93
            if abs(coastAngle) < 0.005 {
                displayLink?.invalidate()
                snapToCenter(ring: coastRing)
                return
            }
            if coastRing == "outer" { parent.outerAngle += Double(coastAngle) }
            else { parent.innerAngle += Double(coastAngle) }
            parent.onSelectionChange()
        }

        func snapToCenter(ring: String) {
            let count = ring == "outer" ? spirits.count : flavors.count
            let slice = (2 * Double.pi) / Double(count)
            let current = ring == "outer" ? parent.outerAngle : parent.innerAngle
            
            let topPointer = -Double.pi / 2
            let halfSlice = slice / 2
            let target = round((current - topPointer + halfSlice) / slice) * slice + topPointer - halfSlice
            
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                if ring == "outer" { parent.outerAngle = target }
                else { parent.innerAngle = target }
            }
            parent.onSelectionChange()
            feedback.selectionChanged()
        }
    }
}

// MARK: - Wheel Rendering

class WheelUIView: UIView {
    var coordinator: WheelCanvas.Coordinator?
    var outerAngle: Double = 0
    var innerAngle: Double = 0
    var outerRadius: CGFloat = 0, outerInnerRadius: CGFloat = 0, innerRadius: CGFloat = 0, coreRadius: CGFloat = 0

    func configure(outerRadius: CGFloat, outerInnerRadius: CGFloat, innerRadius: CGFloat, coreRadius: CGFloat) {
        self.outerRadius = outerRadius; self.outerInnerRadius = outerInnerRadius
        self.innerRadius = innerRadius; self.coreRadius = coreRadius
        backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let cx = rect.midX, cy = rect.midY

        drawRing(ctx: ctx, cx: cx, cy: cy, angle: outerAngle, items: spirits.map { ($0.name, $0.color, $0.altColor) }, r1: outerRadius, r2: outerInnerRadius)
        drawRing(ctx: ctx, cx: cx, cy: cy, angle: innerAngle, items: flavors.map { ($0.name, $0.color, $0.altColor) }, r1: innerRadius, r2: coreRadius)
    }

    private func drawRing(ctx: CGContext, cx: CGFloat, cy: CGFloat, angle: Double, items: [(String, UIColor, UIColor)], r1: CGFloat, r2: CGFloat) {
        let slice = (2 * CGFloat.pi) / CGFloat(items.count)
        for (i, item) in items.enumerated() {
            let start = CGFloat(angle) + CGFloat(i) * slice
            let end = start + slice
            ctx.beginPath()
            ctx.move(to: CGPoint(x: cx, y: cy))
            ctx.addArc(center: CGPoint(x: cx, y: cy), radius: r1, startAngle: start, endAngle: end, clockwise: false)
            ctx.setFillColor((i % 2 == 0 ? item.1 : item.2).cgColor)
            ctx.fillPath()

            ctx.saveGState()
            ctx.translateBy(x: cx, y: cy)
            ctx.rotate(by: start + slice/2 + .pi/2)
            
            let weight: UIFont.Weight = r1 > 300 ? .heavy : .bold
            let sizeVal: CGFloat = r1 > 300 ? 13 : 11
            let font = UIFont(name: "Nunito-Black", size: sizeVal) ?? UIFont.systemFont(ofSize: sizeVal, weight: weight)
            
            let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.white]
            let size = (item.0 as NSString).size(withAttributes: attrs)
            (item.0 as NSString).draw(at: CGPoint(x: -size.width/2, y: -(r1+r2)/2 - size.height/2), withAttributes: attrs)
            ctx.restoreGState()
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.closeSubpath()
        return p
    }
}
