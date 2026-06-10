import app from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"
import { createBinding, createState, createComputed, For } from "ags"
import Network from "gi://AstalNetwork"

const { TOP, RIGHT, BOTTOM } = Astal.WindowAnchor

// ── helpers ───────────────────────────────────────────────────────────────────

function strengthIcon(strength: number): string {
  if (strength >= 80) return "network-wireless-signal-excellent-symbolic"
  if (strength >= 60) return "network-wireless-signal-good-symbolic"
  if (strength >= 40) return "network-wireless-signal-ok-symbolic"
  if (strength >= 20) return "network-wireless-signal-weak-symbolic"
  return "network-wireless-signal-none-symbolic"
}

function freqLabel(freq: number): string {
  if (freq >= 5000) return "5 GHz"
  if (freq >= 2400) return "2.4 GHz"
  return `${freq} MHz`
}

// ── Password dialog ───────────────────────────────────────────────────────────

function PasswordDialog({
  ssid,
  onConfirm,
  onCancel,
}: {
  ssid: string
  onConfirm: (password: string) => void
  onCancel: () => void
}) {
  const [pw, setPw] = createState("")
  const [show, setShow] = createState(false)

  return (
    <box orientation={Gtk.Orientation.VERTICAL} cssClasses={["password-dialog"]} spacing={12}>
      <label label={`Connect to "${ssid}"`} cssClasses={["dialog-title"]} xalign={0} />
      <box orientation={Gtk.Orientation.HORIZONTAL} spacing={8}>
        <entry
          hexpand
          placeholderText="Password"
          text={pw()}
          visibility={show((s) => !s)}
          onNotifyText={({ text }) => setPw(text)}
          cssClasses={["pw-entry"]}
        />
        <togglebutton
          active={show()}
          cssClasses={["show-pw-btn"]}
          onToggled={({ active }) => setShow(active)}
        >
          <image iconName={show((s) => (s ? "view-conceal-symbolic" : "view-reveal-symbolic"))} />
        </togglebutton>
      </box>
      <box orientation={Gtk.Orientation.HORIZONTAL} spacing={8} halign={Gtk.Align.END}>
        <button cssClasses={["cancel-btn"]} onClicked={onCancel}>
          <label label="Cancel" />
        </button>
        <button cssClasses={["connect-btn"]} onClicked={() => onConfirm(pw())}>
          <label label="Connect" />
        </button>
      </box>
    </box>
  )
}

// ── Detail panel ──────────────────────────────────────────────────────────────

function DetailPanel({
  ap,
  isActive,
  onClose,
  onForget,
  onConnect,
  onDisconnect,
}: {
  ap: Network.AccessPoint
  isActive: boolean
  onClose: () => void
  onForget: () => void
  onConnect: () => void
  onDisconnect: () => void
}) {
  const strength = createBinding(ap, "strength")
  const hasSaved = ap.get_connections().length > 0

  return (
    <box orientation={Gtk.Orientation.VERTICAL} cssClasses={["detail-panel"]} spacing={16}>
      <box orientation={Gtk.Orientation.HORIZONTAL} spacing={8}>
        <button cssClasses={["back-btn"]} onClicked={onClose}>
          <image iconName="go-previous-symbolic" />
        </button>
        <label label={ap.ssid ?? "(hidden)"} cssClasses={["detail-ssid"]} hexpand xalign={0} />
        {isActive && <label label="Connected" cssClasses={["connected-badge"]} />}
      </box>

      <box orientation={Gtk.Orientation.VERTICAL} cssClasses={["info-box"]} spacing={8}>
        <box orientation={Gtk.Orientation.HORIZONTAL}>
          <label label="Signal" cssClasses={["info-key"]} hexpand xalign={0} />
          <label label={strength((s) => `${s}%`)} cssClasses={["info-val"]} />
        </box>
        <box orientation={Gtk.Orientation.HORIZONTAL}>
          <label label="Frequency" cssClasses={["info-key"]} hexpand xalign={0} />
          <label label={freqLabel(ap.frequency)} cssClasses={["info-val"]} />
        </box>
        <box orientation={Gtk.Orientation.HORIZONTAL}>
          <label label="BSSID" cssClasses={["info-key"]} hexpand xalign={0} />
          <label label={ap.bssid ?? "—"} cssClasses={["info-val"]} />
        </box>
        <box orientation={Gtk.Orientation.HORIZONTAL}>
          <label label="Max bitrate" cssClasses={["info-key"]} hexpand xalign={0} />
          <label
            label={ap.maxBitrate ? `${Math.round(ap.maxBitrate / 1000)} Mbps` : "—"}
            cssClasses={["info-val"]}
          />
        </box>
        <box orientation={Gtk.Orientation.HORIZONTAL}>
          <label label="Security" cssClasses={["info-key"]} hexpand xalign={0} />
          <label label={ap.requiresPassword ? "WPA/WPA2" : "Open"} cssClasses={["info-val"]} />
        </box>
        <box orientation={Gtk.Orientation.HORIZONTAL}>
          <label label="Saved" cssClasses={["info-key"]} hexpand xalign={0} />
          <label label={hasSaved ? "Yes" : "No"} cssClasses={["info-val"]} />
        </box>
      </box>

      <box orientation={Gtk.Orientation.VERTICAL} spacing={8}>
        {isActive ? (
          <button cssClasses={["action-btn", "disconnect-btn"]} onClicked={onDisconnect}>
            <label label="Disconnect" />
          </button>
        ) : (
          <button cssClasses={["action-btn", "connect-btn"]} onClicked={onConnect}>
            <label label="Connect" />
          </button>
        )}
        {hasSaved && (
          <button cssClasses={["action-btn", "forget-btn"]} onClicked={onForget}>
            <label label="Forget Network" />
          </button>
        )}
      </box>
    </box>
  )
}

// ── Access point row ──────────────────────────────────────────────────────────

function AccessPointRow({
  ap,
  isActive,
  onSelect,
}: {
  ap: Network.AccessPoint
  isActive: boolean
  onSelect: () => void
}) {
  const strength = createBinding(ap, "strength")

  return (
    <button cssClasses={["ap-row", isActive ? "ap-active" : ""]} onClicked={onSelect}>
      <box orientation={Gtk.Orientation.HORIZONTAL} spacing={12}>
        <image
          iconName={strength((s) => strengthIcon(s))}
          pixelSize={20}
          cssClasses={["signal-icon"]}
        />
        <box orientation={Gtk.Orientation.VERTICAL} hexpand spacing={2}>
          <label
            label={ap.ssid ?? "(hidden)"}
            cssClasses={["ap-ssid"]}
            xalign={0}
            ellipsize={3}
            maxWidthChars={28}
          />
          <label
            label={isActive ? "Connected" : ap.requiresPassword ? "Secured" : "Open"}
            cssClasses={["ap-status", isActive ? "status-connected" : ""]}
            xalign={0}
          />
        </box>
        {ap.requiresPassword && !isActive && (
          <image iconName="changes-prevent-symbolic" pixelSize={14} cssClasses={["lock-icon"]} />
        )}
        <image iconName="go-next-symbolic" pixelSize={14} cssClasses={["chevron"]} />
      </box>
    </button>
  )
}

// ── AP list (separate component to keep WifiManager flat) ─────────────────────

function ApList({
  sortedList,
  activeAp,
  onSelect,
}: {
  sortedList: () => Network.AccessPoint[]
  activeAp: () => Network.AccessPoint | null
  onSelect: (ap: Network.AccessPoint) => void
}) {
  return (
    <scrolledwindow cssClasses={["ap-scroll"]} maxContentHeight={420} vexpand>
      <box orientation={Gtk.Orientation.VERTICAL} cssClasses={["ap-list"]}>
        <For each={sortedList}>
          {(ap) => (
            <AccessPointRow
              ap={ap}
              isActive={ap === activeAp()}
              onSelect={() => onSelect(ap)}
            />
          )}
        </For>
      </box>
    </scrolledwindow>
  )
}

// ── Main WiFi manager ─────────────────────────────────────────────────────────

type View =
  | { type: "list" }
  | { type: "detail"; ap: Network.AccessPoint }
  | { type: "password"; ap: Network.AccessPoint }

function WifiManager() {
  const network = Network.get_default()
  const wifi = network.wifi

  const accessPoints = createBinding(wifi, "accessPoints")
  const activeAp = createBinding(wifi, "activeAccessPoint")
  const scanning = createBinding(wifi, "scanning")
  const enabled = createBinding(wifi, "enabled")

  const [view, setView] = createState<View>({ type: "list" })
  const [statusMsg, setStatusMsg] = createState("")
  const [showStatus, setShowStatus] = createState(false)

  // Single computed — combines both bindings, no nesting needed
  const sortedList = createComputed(() => {
    const aps = accessPoints()
    const active = activeAp()
    return [...aps].sort((a, b) => {
      if (a === active) return -1
      if (b === active) return 1
      return b.strength - a.strength
    })
  })

  // Derived booleans for each view — used for `visible` props instead of <With>
  const isListView = createComputed(() => view().type === "list")
  const isDetailView = createComputed(() => view().type === "detail")
  const isPasswordView = createComputed(() => view().type === "password")
  const isDisabled = createComputed(() => !enabled())

  function flashStatus(msg: string) {
    setStatusMsg(msg)
    setShowStatus(true)
    setTimeout(() => setShowStatus(false), 3000)
  }

  function handleConnect(ap: Network.AccessPoint) {
    const hasSaved = ap.get_connections().length > 0
    if (hasSaved || !ap.requiresPassword) {
      ap.activate(null, () => {})
      flashStatus(`Connecting to ${ap.ssid}…`)
      setView({ type: "list" })
    } else {
      setView({ type: "password", ap })
    }
  }

  function handlePasswordConfirm(ap: Network.AccessPoint, password: string) {
    ap.activate(password, () => {})
    flashStatus(`Connecting to ${ap.ssid}…`)
    setView({ type: "list" })
  }

  function handleForget(ap: Network.AccessPoint) {
    for (const conn of ap.get_connections()) {
      try { conn.delete(null, () => {}) } catch (_) {}
    }
    flashStatus(`Forgot ${ap.ssid}`)
    setView({ type: "list" })
  }

  function handleDisconnect() {
    wifi.deactivate_connection(null, () => {})
    flashStatus("Disconnected")
    setView({ type: "list" })
  }

  // Safe accessors for the current detail/password ap — only read when in that view
  function detailAp() {
    const v = view()
    return v.type === "detail" ? v.ap : null
  }
  function passwordAp() {
    const v = view()
    return v.type === "password" ? v.ap : null
  }

  return (
    <box orientation={Gtk.Orientation.VERTICAL} cssClasses={["wifi-manager"]} spacing={0}>
      {/* header */}
      <box orientation={Gtk.Orientation.HORIZONTAL} cssClasses={["header"]} spacing={12}>
        <image iconName="network-wireless-symbolic" pixelSize={20} />
        <label label="Wi-Fi" cssClasses={["header-title"]} hexpand xalign={0} />
        <switch
          active={enabled()}
          onNotifyActive={({ active }) => { wifi.enabled = active }}
          valign={Gtk.Align.CENTER}
        />
        <button
          cssClasses={["scan-btn"]}
          onClicked={() => wifi.scan()}
          sensitive={enabled((e) => e)}
          tooltipText="Scan for networks"
        >
          <image
            iconName={scanning((s) => s ? "content-loading-symbolic" : "view-refresh-symbolic")}
            pixelSize={16}
          />
        </button>
      </box>

      {/* status bar — always in tree, toggled with visible */}
      <label
        label={statusMsg()}
        cssClasses={["status-bar"]}
        xalign={0}
        visible={showStatus()}
      />

      {/* content — each view always in tree, toggled with visible */}
      <box orientation={Gtk.Orientation.VERTICAL} cssClasses={["content"]}>
        {/* list view */}
        <box orientation={Gtk.Orientation.VERTICAL} visible={isListView()}>
          {/* disabled placeholder */}
          <box
            cssClasses={["disabled-msg"]}
            halign={Gtk.Align.CENTER}
            valign={Gtk.Align.CENTER}
            visible={isDisabled()}
          >
            <label label="Wi-Fi is disabled" cssClasses={["muted"]} />
          </box>
          {/* ap list */}
          <box visible={enabled((e) => e)}>
            <ApList
              sortedList={sortedList}
              activeAp={activeAp}
              onSelect={(ap) => setView({ type: "detail", ap })}
            />
          </box>
        </box>

        {/* detail view — render placeholder when not active to avoid null ap */}
        <box visible={isDetailView()}>
          {isDetailView((active) => {
            if (!active) return <box />
            const ap = detailAp()!
            return (
              <DetailPanel
                ap={ap}
                isActive={ap === activeAp()}
                onClose={() => setView({ type: "list" })}
                onForget={() => handleForget(ap)}
                onConnect={() => handleConnect(ap)}
                onDisconnect={handleDisconnect}
              />
            )
          })}
        </box>

        {/* password view */}
        <box visible={isPasswordView()}>
          {isPasswordView((active) => {
            if (!active) return <box />
            const ap = passwordAp()!
            return (
              <PasswordDialog
                ssid={ap.ssid ?? "(hidden)"}
                onConfirm={(pw) => handlePasswordConfirm(ap, pw)}
                onCancel={() => setView({ type: "list" })}
              />
            )
          })}
        </box>
      </box>
    </box>
  )
}

// ── Window ────────────────────────────────────────────────────────────────────

function WifiWindow() {
  return (
    <window
      visible
      name="wifi-manager"
      application={app}
      namespace="wifi-manager"
      cssClasses={["wifi-window"]}
      anchor={TOP}
      exclusivity={Astal.Exclusivity.NORMAL}
      keymode={Astal.Keymode.ON_DEMAND}
      layer={Astal.Layer.OVERLAY}
      marginTop={8}
      marginRight={8}
      marginBottom={8}
    >
      <WifiManager />
    </window>
  )
}

// ── Entry point ───────────────────────────────────────────────────────────────

app.start({
  instanceName: "wifi-manager",
  requestHandler(argv, response) {
    if (argv[0] === "toggle") {
      const win = app.get_window("wifi-manager")
      if (win) win.visible = !win.visible
      response("ok")
    } else {
      response("unknown command")
    }
  },
  main() {
    WifiWindow()
  },
})
