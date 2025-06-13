import SwiftUI
import SheetMusicView

@main
struct ResponsiveDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ResponsiveDemoView()
        }
    }
}

struct ResponsiveDemoView: View {
    @State private var musicXML: String = ""
    @State private var transposeSteps: Int = 0
    @State private var isLoading: Bool = false
    @State private var lastError: SheetMusicError?
    @State private var showingError: Bool = false
    @State private var containerInfo: String = "Container: Not measured"

    // Sample MusicXML with multiple measures for testing line wrapping
    private let sampleXML = """
    <?xml version="1.0" encoding="UTF-8"?>
    <score-partwise version="3.1">
        <part-list>
            <score-part id="P1">
                <part-name>Piano</part-name>
            </score-part>
        </part-list>
        <part id="P1">
            <measure number="1">
                <attributes>
                    <divisions>4</divisions>
                    <key>
                        <fifths>0</fifths>
                    </key>
                    <time>
                        <beats>4</beats>
                        <beat-type>4</beat-type>
                    </time>
                    <clef>
                        <sign>G</sign>
                        <line>2</line>
                    </clef>
                </attributes>
                <note>
                    <pitch>
                        <step>C</step>
                        <octave>4</octave>
                    </pitch>
                    <duration>4</duration>
                    <type>quarter</type>
                </note>
                <note>
                    <pitch>
                        <step>D</step>
                        <octave>4</octave>
                    </pitch>
                    <duration>4</duration>
                    <type>quarter</type>
                </note>
                <note>
                    <pitch>
                        <step>E</step>
                        <octave>4</octave>
                    </pitch>
                    <duration>4</duration>
                    <type>quarter</type>
                </note>
                <note>
                    <pitch>
                        <step>F</step>
                        <octave>4</octave>
                    </pitch>
                    <duration>4</duration>
                    <type>quarter</type>
                </note>
            </measure>
            <measure number="2">
                <note>
                    <pitch>
                        <step>G</step>
                        <octave>4</octave>
                    </pitch>
                    <duration>4</duration>
                    <type>quarter</type>
                </note>
                <note>
                    <pitch>
                        <step>A</step>
                        <octave>4</octave>
                    </pitch>
                    <duration>4</duration>
                    <type>quarter</type>
                </note>
                <note>
                    <pitch>
                        <step>B</step>
                        <octave>4</octave>
                    </pitch>
                    <duration>4</duration>
                    <type>quarter</type>
                </note>
                <note>
                    <pitch>
                        <step>C</step>
                        <octave>5</octave>
                    </pitch>
                    <duration>4</duration>
                    <type>quarter</type>
                </note>
            </measure>
            <measure number="3">
                <note>
                    <pitch>
                        <step>C</step>
                        <octave>5</octave>
                    </pitch>
                    <duration>8</duration>
                    <type>half</type>
                </note>
                <note>
                    <pitch>
                        <step>G</step>
                        <octave>4</octave>
                    </pitch>
                    <duration>8</duration>
                    <type>half</type>
                </note>
            </measure>
            <measure number="4">
                <note>
                    <pitch>
                        <step>C</step>
                        <octave>4</octave>
                    </pitch>
                    <duration>16</duration>
                    <type>whole</type>
                </note>
            </measure>
        </part>
    </score-partwise>
    """

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack {
                Text("Responsive Line Wrapping Demo")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Resize the window to see automatic line wrapping")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(containerInfo)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            .padding()

            // Controls
            HStack {
                Button("Load Sample Music") {
                    musicXML = sampleXML
                }
                .buttonStyle(.borderedProminent)

                Button("Clear") {
                    musicXML = ""
                }
                .buttonStyle(.bordered)

                Spacer()

                VStack {
                    Text("Transpose: \(transposeSteps)")
                        .font(.caption)

                    HStack {
                        Button("-") {
                            transposeSteps = max(-12, transposeSteps - 1)
                        }
                        .buttonStyle(.bordered)

                        Button("+") {
                            transposeSteps = min(12, transposeSteps + 1)
                        }
                        .buttonStyle(.bordered)

                        Button("Reset") {
                            transposeSteps = 0
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding(.horizontal)

            // Sheet Music View with responsive container
            GeometryReader { geometry in
                SheetMusicView(
                    xml: $musicXML,
                    transposeSteps: $transposeSteps,
                    isLoading: $isLoading,
                    onError: { error in
                        lastError = error
                        showingError = true
                    },
                    onReady: {
                        print("Sheet music display is ready for responsive demo!")
                    }
                )
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .overlay(
                    Group {
                        if isLoading {
                            ProgressView("Loading music...")
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(8)
                        }
                    }
                )
                .onAppear {
                    updateContainerInfo(geometry.size)
                }
                .onChange(of: geometry.size) { newSize in
                    updateContainerInfo(newSize)
                }
            }
            .frame(minHeight: 300)

            if let error = lastError {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .alert("Error", isPresented: $showingError) {
            Button("OK") {
                showingError = false
                lastError = nil
            }
        } message: {
            Text(lastError?.localizedDescription ?? "Unknown error")
        }
    }

    private func updateContainerInfo(_ size: CGSize) {
        let aspectRatio = size.width / size.height
        let orientation = aspectRatio > 1 ? "Landscape" : "Portrait"
        containerInfo = "Container: \(Int(size.width))×\(Int(size.height)) (\(orientation), ratio: \(String(format: "%.2f", aspectRatio)))"
    }
}
