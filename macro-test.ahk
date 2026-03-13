#Requires AutoHotkey v2.0

; ============================
; CONFIGURATION
; ============================
ReplayDelay  := 10          ; ms between replayed keypresses
RecordHotkey := "F9"        ; start/stop recording
PlayHotkey   := "F10"       ; replay macro

; ============================
; INTERNAL STATE
; ============================
Recording := false
Macro := []
m_keys := ""

; ============================
; HOTKEYS FOR MACRO CONTROL
; ============================
Hotkey(RecordHotkey, ToggleRecording)
Hotkey(PlayHotkey,   PlayMacro)

ToggleRecording(*) {
    global Recording, Macro, m_keys

    Recording := !Recording
    if Recording {
        Macro := []
        OutputDebug("Started recording macro")
        ToolTip("Recording...")
    } else {
        m_keys := ""
        for key in Macro
            m_keys .= key " "
        OutputDebug("Recorded macro keys: " . m_keys)
        ToolTip("Recorded: " . m_keys)
        SetTimer(() => ToolTip(""), -800)
    }
}

PlayMacro(*) {
    global Recording, Macro, ReplayDelay
    ToolTip("Play macro")

    if Recording || Macro.Length = 0
        return

    ; Set SendLevel so that replayed keys can trigger hotkeys
    lvl := SendLevel(99)
    for key in Macro {
        Send(key)
        Sleep(ReplayDelay)
    }
    SendLevel(lvl)
}

; ============================
; GLOBAL KEY CAPTURE
; Register hotkeys for (almost) all non-modifier keys
; ============================

keys := [
    ; Letters
    "a","b","c","d","e","f","g","h","i","j","k","l","m",
    "n","o","p","q","r","s","t","u","v","w","x","y","z",

    ; Numbers
    "0","1","2","3","4","5","6","7","8","9",

    ; Function keys
    "F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12",
    "F13","F14","F15","F16","F17","F18","F19","F20","F21","F22","F23","F24",

    ; Navigation / control
    "Esc","Tab","Enter","Space","Backspace","Delete","Insert",
    "Home","End","PgUp","PgDn","Up","Down","Left","Right",

    ; Lock keys
    "CapsLock","NumLock","ScrollLock",

    ; Numpad
    "Numpad0","Numpad1","Numpad2","Numpad3","Numpad4",
    "Numpad5","Numpad6","Numpad7","Numpad8","Numpad9",
    "NumpadAdd","NumpadSub","NumpadMult","NumpadDiv",
    "NumpadEnter","NumpadDot",

    ; Punctuation / symbols (main keyboard)
    "-","=","[","]",";","'","`,",",",".","/","\"
]

RecordKey(key) {
    global Recording, Macro, RecordHotkey, PlayHotkey

    key := "{" . SubStr(key, 3) "}" ; Remove "~*" prefix added by hotkey registration

    if !Recording
        return

    ; Extra safety: ignore macro hotkeys if they slip through
    if (key = RecordHotkey || key = PlayHotkey)
        return

    mods := ""
    if GetKeyState("Ctrl")
        mods .= "^"
    if GetKeyState("Alt")
        mods .= "!"
    if GetKeyState("Shift")
        mods .= "+"
    if GetKeyState("LWin") || GetKeyState("RWin")
        mods .= "#"

    ; Store combination or plain key
    Macro.Push(mods . key)
}

SendR(key) {
    Send(key)
    if Recording
        Macro.Push(key)
}

for key in keys {
    ; Don't create hotkeys for the macro control keys
    if (key = RecordHotkey || key = PlayHotkey)
        continue

    ; ~* = pass-through + wildcard (captures with modifiers)
    Hotkey("~*" . key,  RecordKey)
}

+q::
{
    SendR("+{home}")
    SendR("{Shift UP}")
    SendR("{backspace}")
    SendR("Hello, World!")
}

