import SwiftUI
import SheetMusicView

@main
struct PageMarginsDemoApp: App {
    var body: some Scene {
        WindowGroup {
            PageMarginsDemoView()
        }
    }
}

struct PageMarginsDemoView: View {
    @State private var musicXML: String = """
    <?xml version="1.0" encoding="UTF-8"?>
    <score-partwise version="3.1">
        <work>
            <work-title>Page Margins Demo</work-title>
        </work>
        <identification>
            <creator type="composer">SheetMusicView Demo</creator>
        </identification>
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
        </part>
    </score-partwise>
    """
    
    @State private var leftMargin: Double = 1.0
    @State private var rightMargin: Double = 1.0
    @State private var isLoading: Bool = false
    @State private var showTitle: Bool = true
    @State private var showComposer: Bool = true
    @State private var showDebugPanel: Bool = false
    @State private var lastError: SheetMusicError?
    @State private var showingError: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            // Main content
            HStack(spacing: 0) {
                // Sheet Music Display
                sheetMusicSection
                
                // Control Panel
                controlPanelSection
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(lastError?.localizedDescription ?? "Unknown error occurred")
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("SheetMusicView Page Margins Demo")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Adjust the page margins using the controls on the right to see how they affect the music layout")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack {
                Text("Left Margin: \(leftMargin, specifier: "%.1f")")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
                
                Text("Right Margin: \(rightMargin, specifier: "%.1f")")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
    }
    
    private var sheetMusicSection: some View {
        VStack {
            SheetMusicView(
                xml: $musicXML,
                transposeSteps: .constant(0),
                isLoading: $isLoading,
                onError: { error in
                    lastError = error
                    showingError = true
                },
                onReady: {
                    print("Sheet music loaded successfully!")
                }
            )
            .showTitle(showTitle)
            .showComposer(showComposer)
            .showDebugPanel(showDebugPanel)
            .pageMargins(left: leftMargin, right: rightMargin)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 2)
            .padding()
            
            if isLoading {
                ProgressView("Loading music...")
                    .padding()
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var controlPanelSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Page Margins Controls")
                .font(.title2)
                .fontWeight(.semibold)
            
            // Left Margin Control
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Left Margin")
                        .font(.headline)
                    Spacer()
                    Text("\(leftMargin, specifier: "%.1f")")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(3)
                }
                
                Slider(value: $leftMargin, in: 0...50) {
                    Text("Left Margin")
                } minimumValueLabel: {
                    Text("0")
                        .font(.caption)
                } maximumValueLabel: {
                    Text("50")
                        .font(.caption)
                }
                
                HStack {
                    Button("Reset") {
                        leftMargin = 1.0
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Spacer()
                    
                    Button("Min") {
                        leftMargin = 0.0
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Button("Max") {
                        leftMargin = 50.0
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            
            Divider()
            
            // Right Margin Control
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Right Margin")
                        .font(.headline)
                    Spacer()
                    Text("\(rightMargin, specifier: "%.1f")")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(3)
                }
                
                Slider(value: $rightMargin, in: 0...50) {
                    Text("Right Margin")
                } minimumValueLabel: {
                    Text("0")
                        .font(.caption)
                } maximumValueLabel: {
                    Text("50")
                        .font(.caption)
                }
                
                HStack {
                    Button("Reset") {
                        rightMargin = 1.0
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Spacer()
                    
                    Button("Min") {
                        rightMargin = 0.0
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Button("Max") {
                        rightMargin = 50.0
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            
            Divider()
            
            // Preset Configurations
            VStack(alignment: .leading, spacing: 8) {
                Text("Presets")
                    .font(.headline)
                
                VStack(spacing: 6) {
                    Button("Default (1, 1)") {
                        leftMargin = 1.0
                        rightMargin = 1.0
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    
                    Button("Narrow (5, 5)") {
                        leftMargin = 5.0
                        rightMargin = 5.0
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    
                    Button("Wide (25, 25)") {
                        leftMargin = 25.0
                        rightMargin = 25.0
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    
                    Button("Asymmetric (5, 30)") {
                        leftMargin = 5.0
                        rightMargin = 30.0
                    }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                }
            }
            
            Divider()
            
            // Display Options
            VStack(alignment: .leading, spacing: 8) {
                Text("Display Options")
                    .font(.headline)
                
                Toggle("Show Title", isOn: $showTitle)
                Toggle("Show Composer", isOn: $showComposer)
                Toggle("Show Debug Panel", isOn: $showDebugPanel)
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 280)
        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
    }
}

#Preview {
    PageMarginsDemoView()
        .frame(width: 1000, height: 700)
}
