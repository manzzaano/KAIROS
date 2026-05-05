// kairos-icons.jsx — Minimal line icon set for KAIROS
// All icons use stroke-based SVG; size and color via props.

const Icon = ({ d, size = 20, stroke = 'currentColor', sw = 1.6, fill = 'none', children, style }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill={fill} stroke={stroke}
    strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" style={style}>
    {d ? <path d={d} /> : children}
  </svg>
);

const IconHome = (p) => <Icon {...p}><path d="M3 11l9-7 9 7v9a2 2 0 01-2 2h-4v-7h-6v7H5a2 2 0 01-2-2v-9z" /></Icon>;
const IconList = (p) => <Icon {...p}><path d="M8 6h13M8 12h13M8 18h13M3.5 6h.01M3.5 12h.01M3.5 18h.01" /></Icon>;
const IconFocus = (p) => <Icon {...p}>
  <circle cx="12" cy="12" r="9" />
  <circle cx="12" cy="12" r="4" />
  <circle cx="12" cy="12" r="1" fill="currentColor" />
</Icon>;
const IconChart = (p) => <Icon {...p}><path d="M3 21V10M9 21V4M15 21v-7M21 21V8" /></Icon>;
const IconUser = (p) => <Icon {...p}><circle cx="12" cy="8" r="4" /><path d="M4 21c0-4 4-7 8-7s8 3 8 7" /></Icon>;
const IconPlus = (p) => <Icon {...p}><path d="M12 5v14M5 12h14" /></Icon>;
const IconSparkle = (p) => <Icon {...p}><path d="M12 3l1.8 5.4L19 10l-5.2 1.6L12 17l-1.8-5.4L5 10l5.2-1.6L12 3zM19 16l.8 2.2 2.2.8-2.2.8L19 22l-.8-2.2L16 19l2.2-.8L19 16z" /></Icon>;
const IconCheck = (p) => <Icon {...p}><path d="M4 12l5 5L20 6" /></Icon>;
const IconArrowR = (p) => <Icon {...p}><path d="M5 12h14M13 6l6 6-6 6" /></Icon>;
const IconArrowL = (p) => <Icon {...p}><path d="M19 12H5M11 6l-6 6 6 6" /></Icon>;
const IconClose = (p) => <Icon {...p}><path d="M6 6l12 12M18 6L6 18" /></Icon>;
const IconCalendar = (p) => <Icon {...p}><rect x="3" y="5" width="18" height="16" rx="2" /><path d="M3 9h18M8 3v4M16 3v4" /></Icon>;
const IconClock = (p) => <Icon {...p}><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3 2" /></Icon>;
const IconBolt = (p) => <Icon {...p}><path d="M13 2L4 14h7l-1 8 9-12h-7l1-8z" /></Icon>;
const IconFlag = (p) => <Icon {...p}><path d="M5 21V4M5 4h11l-2 4 2 4H5" /></Icon>;
const IconWifi = (p) => <Icon {...p}><path d="M2 9c5-5 15-5 20 0M5 12.5c3.5-3.5 11-3.5 14 0M8.5 16c1.5-1.5 5.5-1.5 7 0" /><circle cx="12" cy="19.5" r="1" fill="currentColor" /></Icon>;
const IconWifiOff = (p) => <Icon {...p}><path d="M2 2l20 20M8.5 16c1.5-1.5 5.5-1.5 7 0M5 12.5a8 8 0 016-2.5M19 12.5a8 8 0 00-3-2.2M2 9c2-2 4.5-3.4 7-4" /><circle cx="12" cy="19.5" r="1" fill="currentColor" /></Icon>;
const IconSync = (p) => <Icon {...p}><path d="M3 12a9 9 0 0115-6.7L21 8M21 12a9 9 0 01-15 6.7L3 16M21 3v5h-5M3 21v-5h5" /></Icon>;
const IconSearch = (p) => <Icon {...p}><circle cx="11" cy="11" r="7" /><path d="M21 21l-4.3-4.3" /></Icon>;
const IconFilter = (p) => <Icon {...p}><path d="M3 5h18l-7 9v6l-4-2v-4L3 5z" /></Icon>;
const IconPlay = (p) => <Icon {...p} fill="currentColor"><path d="M6 4l14 8-14 8V4z" /></Icon>;
const IconPause = (p) => <Icon {...p} fill="currentColor"><rect x="6" y="4" width="4" height="16" /><rect x="14" y="4" width="4" height="16" /></Icon>;
const IconTrash = (p) => <Icon {...p}><path d="M4 7h16M10 11v6M14 11v6M5 7l1 13a2 2 0 002 2h8a2 2 0 002-2l1-13M9 7V4h6v3" /></Icon>;
const IconEdit = (p) => <Icon {...p}><path d="M4 20h4l11-11-4-4-11 11v4zM14 6l4 4" /></Icon>;
const IconSettings = (p) => <Icon {...p}><circle cx="12" cy="12" r="3" /><path d="M19.4 15a1.7 1.7 0 00.3 1.8l.1.1a2 2 0 11-2.8 2.8l-.1-.1a1.7 1.7 0 00-1.8-.3 1.7 1.7 0 00-1 1.5V21a2 2 0 11-4 0v-.1a1.7 1.7 0 00-1.1-1.5 1.7 1.7 0 00-1.8.3l-.1.1a2 2 0 11-2.8-2.8l.1-.1a1.7 1.7 0 00.3-1.8 1.7 1.7 0 00-1.5-1H3a2 2 0 110-4h.1A1.7 1.7 0 004.6 9a1.7 1.7 0 00-.3-1.8l-.1-.1a2 2 0 112.8-2.8l.1.1a1.7 1.7 0 001.8.3H9a1.7 1.7 0 001-1.5V3a2 2 0 114 0v.1a1.7 1.7 0 001 1.5 1.7 1.7 0 001.8-.3l.1-.1a2 2 0 112.8 2.8l-.1.1a1.7 1.7 0 00-.3 1.8V9a1.7 1.7 0 001.5 1H21a2 2 0 110 4h-.1a1.7 1.7 0 00-1.5 1z" /></Icon>;
const IconLogout = (p) => <Icon {...p}><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4M16 17l5-5-5-5M21 12H9" /></Icon>;
const IconMoon = (p) => <Icon {...p}><path d="M21 12.8A9 9 0 1111.2 3a7 7 0 009.8 9.8z" /></Icon>;
const IconBell = (p) => <Icon {...p}><path d="M6 8a6 6 0 0112 0c0 7 3 9 3 9H3s3-2 3-9M10 21a2 2 0 004 0" /></Icon>;
const IconShield = (p) => <Icon {...p}><path d="M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6l8-3z" /></Icon>;
const IconAlert = (p) => <Icon {...p}><path d="M12 9v4M12 17h.01M10.3 3.9L1.8 18a2 2 0 001.7 3h17a2 2 0 001.7-3L13.7 3.9a2 2 0 00-3.4 0z" /></Icon>;
const IconCloud = (p) => <Icon {...p}><path d="M18 19a4 4 0 000-8 6 6 0 00-11.7-1.7A4.5 4.5 0 007 19h11z" /></Icon>;
const IconCloudOff = (p) => <Icon {...p}><path d="M2 2l20 20M8 8a6 6 0 0110.3 3M22 19a4 4 0 00-3.5-4M5 11a4.5 4.5 0 002 8h11" /></Icon>;
const IconChevronR = (p) => <Icon {...p}><path d="M9 6l6 6-6 6" /></Icon>;
const IconChevronD = (p) => <Icon {...p}><path d="M6 9l6 6 6-6" /></Icon>;
const IconLogo = ({ size = 24, color = 'currentColor' }) => (
  <svg width={size} height={size} viewBox="0 0 32 32" fill="none">
    <circle cx="16" cy="16" r="13" stroke={color} strokeWidth="1.6" />
    <path d="M16 5v11l7 4" stroke={color} strokeWidth="1.6" strokeLinecap="round" />
    <circle cx="16" cy="16" r="2" fill={color} />
  </svg>
);

Object.assign(window, {
  IconHome, IconList, IconFocus, IconChart, IconUser, IconPlus, IconSparkle,
  IconCheck, IconArrowR, IconArrowL, IconClose, IconCalendar, IconClock,
  IconBolt, IconFlag, IconWifi, IconWifiOff, IconSync, IconSearch, IconFilter,
  IconPlay, IconPause, IconTrash, IconEdit, IconSettings, IconLogout, IconMoon,
  IconBell, IconShield, IconAlert, IconCloud, IconCloudOff, IconChevronR,
  IconChevronD, IconLogo,
});
