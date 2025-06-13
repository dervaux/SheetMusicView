import SwiftUI
import SheetMusicView

struct ContentView: View {
    @State private var musicXML: String = ""
    @State private var transposeSteps: Int = 0
    @State private var isLoading: Bool = false
    @State private var lastError: SheetMusicError?
    @State private var showingError: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack {
                Text("SheetMusicView Demo")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("OpenSheetMusicDisplay in SwiftUI")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            // Sheet Music View
            SheetMusicView(
                xml: $musicXML,
                transposeSteps: $transposeSteps,
                isLoading: $isLoading,
                onError: { error in
                    lastError = error
                    showingError = true
                },
                onReady: {
                    print("Sheet music display is ready!")
                }
            )
            .frame(minHeight: 400)
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
            
            // Controls
            VStack(spacing: 15) {
                // Load Sample Button
                Button("Load Sample Music") {
                    loadSampleMusic()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)
                
                // Transpose Controls
                HStack {
                    Text("Transpose:")
                        .fontWeight(.medium)
                    
                    Button("-") {
                        transposeSteps -= 1
                    }
                    .buttonStyle(.bordered)
                    .disabled(isLoading || musicXML.isEmpty)
                    
                    Text("\(transposeSteps) semitones")
                        .frame(minWidth: 100)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)
                    
                    Button("+") {
                        transposeSteps += 1
                    }
                    .buttonStyle(.bordered)
                    .disabled(isLoading || musicXML.isEmpty)
                }
                
                // Reset Button
                Button("Clear") {
                    musicXML = ""
                    transposeSteps = 0
                }
                .buttonStyle(.bordered)
                .disabled(isLoading)
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(10)
            
            Spacer()
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
    
    private func loadSampleMusic() {
        // Simple MusicXML example
        musicXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE score-partwise PUBLIC "-//Recordare//DTD MusicXML 3.1 Partwise//EN" "http://www.musicxml.org/dtds/partwise.dtd">
        <score-partwise version="3.1">
          <work>
            <work-title>Sample Music</work-title>
          </work>
          <identification>
            <creator type="composer">SwiftUI-OSMD Demo</creator>
          </identification>
          <part-list>
            <score-part id="P1">
              <part-name>Piano</part-name>
            </score-part>
          </part-list>
          <part id="P1">
            <measure number="1">
              <attributes>
                <divisions>1</divisions>
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
                <duration>1</duration>
                <type>quarter</type>
              </note>
              <note>
                <pitch>
                  <step>D</step>
                  <octave>4</octave>
                </pitch>
                <duration>1</duration>
                <type>quarter</type>
              </note>
              <note>
                <pitch>
                  <step>E</step>
                  <octave>4</octave>
                </pitch>
                <duration>1</duration>
                <type>quarter</type>
              </note>
              <note>
                <pitch>
                  <step>F</step>
                  <octave>4</octave>
                </pitch>
                <duration>1</duration>
                <type>quarter</type>
              </note>
            </measure>
            <measure number="2">
              <note>
                <pitch>
                  <step>G</step>
                  <octave>4</octave>
                </pitch>
                <duration>1</duration>
                <type>quarter</type>
              </note>
              <note>
                <pitch>
                  <step>A</step>
                  <octave>4</octave>
                </pitch>
                <duration>1</duration>
                <type>quarter</type>
              </note>
              <note>
                <pitch>
                  <step>B</step>
                  <octave>4</octave>
                </pitch>
                <duration>1</duration>
                <type>quarter</type>
              </note>
              <note>
                <pitch>
                  <step>C</step>
                  <octave>5</octave>
                </pitch>
                <duration>1</duration>
                <type>quarter</type>
              </note>
            </measure>
          </part>
        </score-partwise>
        """
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
