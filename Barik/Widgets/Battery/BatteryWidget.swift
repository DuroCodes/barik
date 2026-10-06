import SwiftUI

struct BatteryWidget: View {
    @EnvironmentObject var configProvider: ConfigProvider
    var config: ConfigData { configProvider.config }
    var showPercentage: Bool { config["show-percentage"]?.boolValue ?? true }

    @ObservedObject private var batteryManager = BatteryManager.shared
    private var level: Int { batteryManager.batteryLevel }
    private var isCharging: Bool { batteryManager.isCharging }
    private var isPluggedIn: Bool { batteryManager.isPluggedIn }

    @State private var rect: CGRect = CGRect()

    var body: some View {
        HStack(spacing: 4) {
            BatteryIcon(
                level: level,
                // macOS shows the bolt whenever AC is attached, not only while
                // IsCharging is true (optimized charging / low-watt adapters).
                showBolt: isPluggedIn || isCharging
            )

            if showPercentage {
                Text("\(level)%")
                    .fontWeight(.semibold)
            }
        }
        .font(.headline)
        .foregroundStyle(.foregroundOutside)
        .shadow(color: .foregroundShadowOutside, radius: 3)
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        rect = geometry.frame(in: .global)
                    }
                    .onChange(of: geometry.frame(in: .global)) {
                        oldState, newState in
                        rect = newState
                    }
            }
        )
        .experimentalConfiguration(cornerRadius: 15)
        .frame(maxHeight: .infinity)
        .background(.black.opacity(0.001))
        .monospacedDigit()
        .onTapGesture {
            MenuBarPopup.show(rect: rect, id: "battery") { BatteryPopup() }
        }
    }
}

/// Outline from `battery.0percent`, fill from a masked `battery.100percent` so the
/// charge level uses the real SF Symbol geometry (no inset gaps) at a size that
/// optically matches the other menu bar icons.
private struct BatteryIcon: View {
    let level: Int
    let showBolt: Bool

    /// Slightly larger than the 14pt speaker/clock — battery glyphs read shorter optically.
    private let pointSize: CGFloat = 17

    var body: some View {
        ZStack {
            Image(systemName: "battery.0percent")
                .font(.system(size: pointSize))

            Image(systemName: "battery.100percent")
                .font(.system(size: pointSize))
                .mask(alignment: .leading) {
                    GeometryReader { geo in
                        // Reveal from the leading edge through the filled portion of
                        // the body. Values are fractions of the symbol view width:
                        // the fill cavity starts ~after optical pad + left wall and
                        // spans most of the body before the terminal.
                        let fillStart = geo.size.width * 0.16
                        let fillableWidth = geo.size.width * 0.58
                        let revealedWidth =
                            level <= 0
                            ? 0
                            : fillStart + fillableWidth * CGFloat(level) / 100

                        Rectangle()
                            .frame(width: revealedWidth)
                            .frame(maxHeight: .infinity, alignment: .leading)
                    }
                }

            if showBolt {
                ChargingBolt()
                    .offset(x: -1.5)
            }
        }
        .animation(.smooth, value: showBolt)
        .animation(.smooth, value: level)
    }
}

/// macOS-style charging bolt: outline glyph behind fill for a crisp even stroke.
private struct ChargingBolt: View {
    private let fillSize: CGFloat = 8

    var body: some View {
        ZStack {
            Image(systemName: "bolt")
                .font(.system(size: fillSize + 1.6, weight: .heavy))
                .foregroundStyle(Color.black.opacity(0.55))

            Image(systemName: "bolt.fill")
                .font(.system(size: fillSize, weight: .bold))
                .foregroundStyle(Color.foregroundOutside)
        }
    }
}

struct BatteryWidget_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            BatteryWidget()
        }.frame(width: 200, height: 100)
            .background(.yellow)
            .environmentObject(ConfigProvider(config: [:]))
    }
}
