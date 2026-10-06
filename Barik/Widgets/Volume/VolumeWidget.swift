import SwiftUI

struct VolumeWidget: View {
    @EnvironmentObject var configProvider: ConfigProvider
    var config: ConfigData { configProvider.config }

    @StateObject private var volumeManager = VolumeManager()
    private var volumeLevel: Int { volumeManager.volumeLevel }
    private var isMuted: Bool { volumeManager.isMuted }

    @State private var rect = CGRect()

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: volumeIconName)
                .font(.system(size: 14))
            Text("\(volumeLevel)%")
                .fontWeight(.semibold)
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
    }

    /// Returns the appropriate SF Symbol name based on volume level and mute state.
    private var volumeIconName: String {
        if isMuted || volumeLevel == 0 {
            return "speaker.slash.fill"
        } else if volumeLevel <= 33 {
            return "speaker.fill"
        } else if volumeLevel <= 66 {
            return "speaker.2.fill"
        } else {
            return "speaker.3.fill"
        }
    }
}

struct VolumeWidget_Previews: PreviewProvider {
    static var previews: some View {
        let provider = ConfigProvider(config: ConfigData())

        ZStack {
            VolumeWidget()
                .environmentObject(provider)
        }.frame(width: 500, height: 100)
    }
}

