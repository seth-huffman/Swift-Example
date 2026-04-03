//
//  CocktailDashView.swift
//  Apple
//
//  Created by SETH HUFFMAN on 4/2/26.
//

import SwiftUI
import Combine

// MARK: - Game Models

struct GameCustomer: Identifiable {
    let id          = UUID()
    let name:       String
    let avatar:     String
    let order:      GameOrder
    var patience:   Double
    var state:      CustomerState = .waiting
    var seatIndex:  Int
}

struct GameOrder: Equatable {
    let spirit: String
    let flavor: String
    var displayName: String { "\(flavor) \(spirit)" }
}

enum CustomerState { case waiting, served, failed }
enum DashPhase { case idle, playing, levelComplete, gameOver }

// MARK: - Game Engine

@MainActor
class DashGame: ObservableObject {
    @Published var customers:    [GameCustomer] = []
    @Published var score:        Int    = 0
    @Published var combo:        Int    = 1
    @Published var lives:        Int    = 3
    @Published var level:        Int    = 1
    @Published var phase:        DashPhase = .idle
    @Published var builtSpirit:  String? = nil
    @Published var builtFlavor:  String? = nil
    @Published var toast:        String? = nil
    @Published var shouldShake:  Bool   = false
    @Published var ordersServed: Int    = 0

    private let ordersPerLevel  = 8
    private var totalSpawned    = 0
    private var patienceTimer:  Timer?
    private var spawnTimer:     Timer?
    private let maxSeats        = 4

    let spiritOptions = ["Whiskey", "Rum", "Tequila", "Gin", "Vodka", "Brandy"]
    let flavorOptions = ["Smokey", "Fruity", "Herbal", "Spicy", "Sweet", "Citrusy", "Floral", "Bitter"]

    private let names   = ["Alex", "Jamie", "Morgan", "Riley", "Sam", "Casey", "Drew", "Blake"]
    private let avatars = ["😊","😄","🥳","😎","🤗","😏","🧐","🫡"]

    // Maintained the slower drain rate
    var drainRate:     Double { 0.007 + Double(level - 1) * 0.002 }
    var spawnDelay:    Double { max(3.5 - Double(level - 1) * 0.4, 1.8) }
    var pointsEarned:  Int   { 100 * combo }

    func startGame() {
        customers = []; score = 0; combo = 1; lives = 3
        level = 1; ordersServed = 0; totalSpawned = 0
        builtSpirit = nil; builtFlavor = nil
        phase = .playing
        scheduleNextSpawn()
        startPatienceTick()
    }

    func stopGame() {
        patienceTimer?.invalidate(); spawnTimer?.invalidate()
        patienceTimer = nil; spawnTimer = nil
    }

    func nextLevel() {
        level += 1
        customers = []; ordersServed = 0; totalSpawned = 0
        builtSpirit = nil; builtFlavor = nil
        phase = .playing
        scheduleNextSpawn()
        startPatienceTick()
    }

    private func scheduleNextSpawn() {
        spawnTimer?.invalidate()
        guard totalSpawned < ordersPerLevel else { return }
        spawnTimer = Timer.scheduledTimer(withTimeInterval: spawnDelay, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in self?.spawnCustomer() }
        }
    }

    private func startPatienceTick() {
        patienceTimer?.invalidate()
        patienceTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.tickPatience() }
        }
    }

    private func tickPatience() {
        guard phase == .playing else { return }
        for i in customers.indices where customers[i].state == .waiting {
            customers[i].patience -= drainRate
            if customers[i].patience <= 0 {
                customers[i].patience = 0
                customers[i].state    = .failed
                combo = 1
                lives -= 1
                flash("\(customers[i].name) walked out")
                triggerShake()
                if lives <= 0 { endGame(); return }
                let cid = customers[i].id
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.customers.removeAll { $0.id == cid }
                    self.checkLevelComplete()
                }
            }
        }
    }

    private func spawnCustomer() {
        guard phase == .playing, totalSpawned < ordersPerLevel else { return }
        let occupied = Set(customers.map(\.seatIndex))
        guard let seat = (0..<maxSeats).first(where: { !occupied.contains($0) }) else {
            scheduleNextSpawn(); return
        }
        let i = Int.random(in: 0..<names.count)
        let order = GameOrder(
            spirit: spiritOptions.randomElement()!,
            flavor: flavorOptions.randomElement()!
        )
        customers.append(GameCustomer(
            name: names[i], avatar: avatars[i],
            order: order, patience: 1.0, seatIndex: seat
        ))
        totalSpawned += 1
        scheduleNextSpawn()
    }

    func submitPairing() {
        guard let spirit = builtSpirit, let flavor = builtFlavor else {
            flash("Pick a spirit & flavor"); return
        }
        
        if let matchIndex = customers.firstIndex(where: { $0.state == .waiting && $0.order.spirit == spirit && $0.order.flavor == flavor }) {
            serve(customer: customers[matchIndex])
        } else {
            combo = 1
            flash("No one ordered that!")
            triggerShake()
            builtSpirit = nil
            builtFlavor = nil
        }
    }

    func serve(customer: GameCustomer) {
        guard let spirit = builtSpirit, let flavor = builtFlavor else { return }
        let match = spirit == customer.order.spirit && flavor == customer.order.flavor
        
        if match {
            score        += pointsEarned
            combo        += 1
            ordersServed += 1
            flash(combo > 2 ? "x\(combo) Combo" : "Served")
            let cid = customer.id
            withAnimation(.spring(response: 0.3)) {
                if let i = customers.firstIndex(where: { $0.id == cid }) {
                    customers[i].state = .served
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.customers.removeAll { $0.id == cid }
                self.checkLevelComplete()
            }
        }
        builtSpirit = nil
        builtFlavor = nil
    }

    private func checkLevelComplete() {
        guard phase == .playing else { return }
        let active = customers.filter { $0.state == .waiting }
        guard active.isEmpty, totalSpawned >= ordersPerLevel else { return }
        stopGame()
        phase = .levelComplete
    }

    private func endGame() {
        stopGame(); phase = .gameOver
    }

    private func flash(_ msg: String) {
        toast = msg
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            if self.toast == msg { self.toast = nil }
        }
    }

    private func triggerShake() {
        shouldShake = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { self.shouldShake = false }
    }
}

// MARK: - Root View

struct CocktailDashView: View {
    @StateObject private var game = DashGame()

    var body: some View {
        ZStack {
            DS.bg.ignoresSafeArea()
            switch game.phase {
            case .idle:          DashIdleScreen(game: game)
            case .playing:       DashPlayScreen(game: game)
            case .levelComplete: DashLevelScreen(game: game)
            case .gameOver:      DashGameOverScreen(game: game)
            }
        }
    }
}

// MARK: - Sub Screens

private struct DashIdleScreen: View {
    let game: DashGame
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer().frame(height: 40)
                VStack(spacing: 12) {
                    Text("Cocktail Dash").font(.custom("Nunito-Black", size: 32)).foregroundColor(DS.text)
                    Text("Serve every guest before\ntheir patience runs out!").font(.custom("Nunito-SemiBold", size: 15)).foregroundColor(DS.textMid).multilineTextAlignment(.center).lineSpacing(4)
                }
                VStack(alignment: .leading, spacing: 16) {
                    Text("HOW TO PLAY").font(.custom("Nunito-Black", size: 11)).foregroundColor(DS.cyan).tracking(1.4)
                    HowToRow(text: "Select a spirit and a flavor")
                    HowToRow(text: "Tap 'SUBMIT' to serve the guest")
                    HowToRow(text: "Watch patience bars to keep the bar open")
                }
                .padding(20).background(DS.white).clipShape(RoundedRectangle(cornerRadius: DS.radiusCard)).cardShadow().padding(.horizontal, 24)
                
                Button(action: { game.startGame() }) {
                    Text("Start Game").font(.custom("Nunito-Black", size: 18)).foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 18).background(DS.cyan).clipShape(RoundedRectangle(cornerRadius: DS.radiusPill)).cardShadow(prominent: true)
                }
                .padding(.horizontal, 32).buttonStyle(ScaleButtonStyle())
                Spacer().frame(height: 20)
            }
        }
    }
}

private struct DashPlayScreen: View {
    @ObservedObject var game: DashGame
    
    private let gridColumns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // HUD
            HStack(alignment: .center) {
                DashHUDPill(label: "SCORE", value: "\(game.score)")
                Spacer()
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(i < game.lives ? DS.cyan : DS.textLight.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                Spacer()
                DashHUDPill(label: "LEVEL", value: "\(game.level)")
            }
            .padding(.horizontal, 20).padding(.top, 56).padding(.bottom, 14)

            // Guest area
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    let sorted = game.customers.sorted { $0.seatIndex < $1.seatIndex }
                    ForEach(sorted) { customer in
                        GuestCard(customer: customer) { game.serve(customer: customer) }
                    }
                    ForEach(0..<max(0, 4 - game.customers.count), id: \.self) { _ in EmptySeatView() }
                }
                .padding(.horizontal, 20).padding(.vertical, 4)
            }
            .frame(height: 140)

            // Build HUD
            VStack(spacing: 10) {
                Text("BUILD YOUR DRINK").font(.custom("Nunito-Black", size: 10)).foregroundColor(DS.cyan).tracking(1.4)
                HStack(spacing: 10) {
                    DrinkBadge(label: game.builtSpirit ?? "Spirit", filled: game.builtSpirit != nil, accent: DS.cyan)
                    Text("+").foregroundColor(DS.textLight)
                    DrinkBadge(label: game.builtFlavor ?? "Flavor", filled: game.builtFlavor != nil, accent: DS.textMid)
                }
            }
            .padding(.top, 10)

            // Grid Area
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    DashSectionLabel("Spirits")
                    LazyVGrid(columns: gridColumns, spacing: 8) {
                        ForEach(game.spiritOptions, id: \.self) { s in
                            IngredientChipNoIcon(label: s, selected: game.builtSpirit == s, accent: DS.cyan) {
                                game.builtSpirit = game.builtSpirit == s ? nil : s
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    DashSectionLabel("Flavors")
                    LazyVGrid(columns: gridColumns, spacing: 8) {
                        ForEach(game.flavorOptions, id: \.self) { f in
                            IngredientChipNoIcon(label: f, selected: game.builtFlavor == f, accent: DS.textMid) {
                                game.builtFlavor = game.builtFlavor == f ? nil : f
                            }
                        }
                        
                        // Submit button placed at the end of the flavor grid
                        Button(action: { game.submitPairing() }) {
                            Text("SUBMIT")
                                .font(.custom("Nunito-Black", size: 11))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(game.builtSpirit != nil && game.builtFlavor != nil ? DS.cyan : DS.textLight.opacity(0.4))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .cardShadow(prominent: game.builtSpirit != nil && game.builtFlavor != nil)
                        }
                        .disabled(game.builtSpirit == nil || game.builtFlavor == nil)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120)
                }
            }
        }
        .modifier(ShakeEffect(active: game.shouldShake))
    }
}

// MARK: - Reusable Components

private struct IngredientChipNoIcon: View {
    let label: String; let selected: Bool; let accent: Color; let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.custom("Nunito-Bold", size: 12))
                .foregroundColor(selected ? .white : DS.text)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(selected ? accent : DS.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .cardShadow()
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

private struct HowToRow: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle().fill(DS.cyan).frame(width: 6, height: 6).padding(.top, 6)
            Text(text).font(.custom("Nunito-SemiBold", size: 13)).foregroundColor(DS.textMid).lineSpacing(3)
        }
    }
}

private struct GuestCard: View {
    let customer: GameCustomer
    let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(customer.name)
                    .font(.custom("Nunito-Black", size: 12))
                    .foregroundColor(DS.text)
                
                VStack(spacing: 2) {
                    Text(customer.order.spirit).font(.custom("Nunito-ExtraBold", size: 11)).foregroundColor(DS.cyan)
                    Text(customer.order.flavor).font(.custom("Nunito-SemiBold", size: 10)).foregroundColor(DS.textMid)
                }
                
                ProgressView(value: max(0, customer.patience))
                    .tint(customer.patience > 0.4 ? .green : .red)
                    .scaleEffect(x: 1, y: 0.5, anchor: .center)
            }
            .padding(14).frame(width: 95).background(DS.white).clipShape(RoundedRectangle(cornerRadius: DS.radiusCard)).cardShadow()
        }
        .disabled(customer.state != .waiting)
    }
}

private struct DashHUDPill: View {
    let label: String; let value: String
    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(.custom("Nunito-Black", size: 20)).foregroundColor(DS.text)
            Text(label).font(.custom("Nunito-Bold", size: 9)).foregroundColor(DS.textLight).tracking(0.5)
        }
        .padding(.horizontal, 14).padding(.vertical, 8).background(DS.white).clipShape(RoundedRectangle(cornerRadius: 14)).cardShadow()
    }
}

private struct DrinkBadge: View {
    let label: String; let filled: Bool; let accent: Color
    var body: some View {
        Text(label).font(.custom("Nunito-ExtraBold", size: 14)).foregroundColor(filled ? .white : DS.textLight).padding(.horizontal, 20).padding(.vertical, 9).background(filled ? accent : DS.white).clipShape(Capsule()).cardShadow()
    }
}

private struct DashSectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text.uppercased()).font(.custom("Nunito-Black", size: 10)).foregroundColor(DS.cyan).tracking(1.4).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20).padding(.top, 24).padding(.bottom, 8)
    }
}

private struct EmptySeatView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: DS.radiusCard)
            .strokeBorder(DS.textLight.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [4]))
            .frame(width: 95, height: 110)
    }
}

private struct DashLevelScreen: View {
    let game: DashGame
    var body: some View {
        VStack(spacing: 28) {
            Text("Level \(game.level) Complete").font(.custom("Nunito-Black", size: 28)).foregroundColor(DS.text)
            Button("Next Level") { game.nextLevel() }.font(.custom("Nunito-Black", size: 18)).foregroundColor(.white).padding(.horizontal, 40).padding(.vertical, 18).background(DS.cyan).clipShape(Capsule())
        }
    }
}

private struct DashGameOverScreen: View {
    let game: DashGame
    var body: some View {
        VStack(spacing: 28) {
            Text("Bar Closed").font(.custom("Nunito-Black", size: 32)).foregroundColor(DS.text)
            VStack(spacing: 8) {
                Text("Final Score").font(.custom("Nunito-Bold", size: 14)).foregroundColor(DS.textLight)
                Text("\(game.score)").font(.custom("Nunito-Black", size: 48)).foregroundColor(DS.cyan)
            }
            Button("Try Again") { game.startGame() }.font(.custom("Nunito-Black", size: 18)).foregroundColor(.white).padding(.horizontal, 40).padding(.vertical, 18).background(DS.cyan).clipShape(Capsule())
        }
    }
}

struct ShakeEffect: ViewModifier {
    let active: Bool
    func body(content: Content) -> some View {
        content.offset(x: active ? -7 : 0).animation(active ? .default.repeatCount(3, autoreverses: true) : .default, value: active)
    }
}
