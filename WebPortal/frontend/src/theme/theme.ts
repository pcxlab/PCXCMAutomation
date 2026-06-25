import { createTheme, alpha } from '@mui/material/styles';

// PCXLab brand color tokens
const COLORS = {
  // Backgrounds
  bg: {
    default: '#080d18',
    paper: '#0f1629',
    surface: '#141e35',
    elevated: '#1a2540',
    card: '#1e2d4a',
  },
  // PCXLab / Azure-inspired blues
  primary: {
    main: '#0f7be8',
    light: '#3d9cf0',
    dark: '#0a56a3',
    contrastText: '#ffffff',
  },
  // Accent — electric cyan for highlights
  accent: {
    main: '#00b4d8',
    light: '#48cae4',
    dark: '#0077b6',
  },
  // Status
  success: '#22c55e',
  warning: '#f59e0b',
  error: '#ef4444',
  info: '#38bdf8',
  // Borders
  border: {
    subtle: 'rgba(255,255,255,0.06)',
    default: 'rgba(255,255,255,0.10)',
    strong: 'rgba(255,255,255,0.18)',
  },
  // Text
  text: {
    primary: '#e8edf5',
    secondary: '#8b9ab5',
    disabled: '#4a5568',
    muted: '#64748b',
  },
};

export const pcxTheme = createTheme({
  palette: {
    mode: 'dark',
    background: {
      default: COLORS.bg.default,
      paper: COLORS.bg.paper,
    },
    primary: {
      main: COLORS.primary.main,
      light: COLORS.primary.light,
      dark: COLORS.primary.dark,
      contrastText: COLORS.primary.contrastText,
    },
    secondary: {
      main: COLORS.accent.main,
      light: COLORS.accent.light,
      dark: COLORS.accent.dark,
    },
    success: { main: COLORS.success },
    warning: { main: COLORS.warning },
    error: { main: COLORS.error },
    info: { main: COLORS.info },
    text: {
      primary: COLORS.text.primary,
      secondary: COLORS.text.secondary,
      disabled: COLORS.text.disabled,
    },
    divider: COLORS.border.default,
  },

  typography: {
    fontFamily: '"Inter", "Roboto", "Helvetica Neue", Arial, sans-serif',
    h1: { fontSize: '2rem', fontWeight: 700, letterSpacing: '-0.02em' },
    h2: { fontSize: '1.5rem', fontWeight: 700, letterSpacing: '-0.01em' },
    h3: { fontSize: '1.25rem', fontWeight: 600 },
    h4: { fontSize: '1.1rem', fontWeight: 600 },
    h5: { fontSize: '0.95rem', fontWeight: 600 },
    h6: { fontSize: '0.875rem', fontWeight: 600 },
    body1: { fontSize: '0.9rem', lineHeight: 1.6 },
    body2: { fontSize: '0.8rem', lineHeight: 1.5 },
    caption: { fontSize: '0.75rem', letterSpacing: '0.03em' },
    overline: { fontSize: '0.65rem', letterSpacing: '0.12em', fontWeight: 600 },
  },

  shape: {
    borderRadius: 10,
  },

  components: {
    // --- Global baseline ---
    MuiCssBaseline: {
      styleOverrides: {
        body: {
          backgroundImage: `
            radial-gradient(ellipse at 20% 10%, ${alpha(COLORS.primary.main, 0.07)} 0%, transparent 60%),
            radial-gradient(ellipse at 80% 80%, ${alpha(COLORS.accent.main, 0.05)} 0%, transparent 60%)
          `,
          backgroundAttachment: 'fixed',
          scrollbarWidth: 'thin',
          scrollbarColor: `${COLORS.border.strong} transparent`,
          '&::-webkit-scrollbar': { width: 6 },
          '&::-webkit-scrollbar-track': { background: 'transparent' },
          '&::-webkit-scrollbar-thumb': {
            background: COLORS.border.strong,
            borderRadius: 3,
          },
        },
      },
    },

    // --- AppBar ---
    MuiAppBar: {
      defaultProps: { elevation: 0 },
      styleOverrides: {
        root: {
          background: alpha(COLORS.bg.paper, 0.85),
          backdropFilter: 'blur(16px)',
          borderBottom: `1px solid ${COLORS.border.subtle}`,
        },
      },
    },

    // --- Drawer (Sidebar) ---
    MuiDrawer: {
      styleOverrides: {
        paper: {
          background: alpha(COLORS.bg.paper, 0.97),
          borderRight: `1px solid ${COLORS.border.subtle}`,
          backdropFilter: 'blur(20px)',
        },
      },
    },

    // --- Cards ---
    MuiCard: {
      defaultProps: { elevation: 0 },
      styleOverrides: {
        root: {
          background: COLORS.bg.surface,
          border: `1px solid ${COLORS.border.subtle}`,
          transition: 'border-color 0.2s ease, box-shadow 0.2s ease',
          '&:hover': {
            borderColor: COLORS.border.default,
            boxShadow: `0 4px 24px ${alpha(COLORS.primary.main, 0.08)}`,
          },
        },
      },
    },

    // --- Paper ---
    MuiPaper: {
      defaultProps: { elevation: 0 },
      styleOverrides: {
        root: {
          backgroundImage: 'none',
          border: `1px solid ${COLORS.border.subtle}`,
        },
      },
    },

    // --- Buttons ---
    MuiButton: {
      defaultProps: { disableElevation: true },
      styleOverrides: {
        root: {
          borderRadius: 8,
          textTransform: 'none',
          fontWeight: 600,
          letterSpacing: '0.01em',
          padding: '8px 20px',
          transition: 'all 0.2s ease',
        },
        contained: {
          background: `linear-gradient(135deg, ${COLORS.primary.main}, ${COLORS.primary.dark})`,
          '&:hover': {
            background: `linear-gradient(135deg, ${COLORS.primary.light}, ${COLORS.primary.main})`,
            transform: 'translateY(-1px)',
            boxShadow: `0 4px 20px ${alpha(COLORS.primary.main, 0.4)}`,
          },
        },
        outlined: {
          borderColor: COLORS.border.strong,
          '&:hover': {
            borderColor: COLORS.primary.main,
            background: alpha(COLORS.primary.main, 0.06),
          },
        },
      },
    },

    // --- Text Fields ---
    MuiTextField: {
      defaultProps: { variant: 'outlined', size: 'small' },
    },
    MuiOutlinedInput: {
      styleOverrides: {
        root: {
          background: COLORS.bg.elevated,
          borderRadius: 8,
          '& .MuiOutlinedInput-notchedOutline': {
            borderColor: COLORS.border.default,
          },
          '&:hover .MuiOutlinedInput-notchedOutline': {
            borderColor: COLORS.border.strong,
          },
          '&.Mui-focused .MuiOutlinedInput-notchedOutline': {
            borderColor: COLORS.primary.main,
            boxShadow: `0 0 0 3px ${alpha(COLORS.primary.main, 0.12)}`,
          },
        },
      },
    },

    // --- Chips ---
    MuiChip: {
      styleOverrides: {
        root: {
          borderRadius: 6,
          fontWeight: 500,
          fontSize: '0.75rem',
        },
      },
    },

    // --- List Items (sidebar nav) ---
    MuiListItemButton: {
      styleOverrides: {
        root: {
          borderRadius: 8,
          margin: '2px 8px',
          padding: '8px 12px',
          transition: 'all 0.15s ease',
          '&.Mui-selected': {
            background: alpha(COLORS.primary.main, 0.15),
            borderLeft: `3px solid ${COLORS.primary.main}`,
            '& .MuiListItemIcon-root': { color: COLORS.primary.main },
            '& .MuiListItemText-primary': { color: COLORS.primary.light, fontWeight: 600 },
          },
          '&:hover': {
            background: alpha(COLORS.primary.main, 0.07),
          },
        },
      },
    },

    // --- Tabs ---
    MuiTab: {
      styleOverrides: {
        root: {
          textTransform: 'none',
          fontWeight: 500,
          fontSize: '0.875rem',
        },
      },
    },

    // --- Stepper ---
    MuiStepLabel: {
      styleOverrides: {
        label: {
          fontSize: '0.8rem',
          '&.Mui-active': { fontWeight: 600, color: COLORS.primary.light },
          '&.Mui-completed': { color: COLORS.success },
        },
      },
    },

    // --- Alerts ---
    MuiAlert: {
      styleOverrides: {
        root: {
          borderRadius: 8,
          border: `1px solid`,
        },
        standardError: { borderColor: alpha(COLORS.error, 0.3) },
        standardWarning: { borderColor: alpha(COLORS.warning, 0.3) },
        standardSuccess: { borderColor: alpha(COLORS.success, 0.3) },
        standardInfo: { borderColor: alpha(COLORS.info, 0.3) },
      },
    },

    // --- Tooltips ---
    MuiTooltip: {
      styleOverrides: {
        tooltip: {
          background: COLORS.bg.card,
          border: `1px solid ${COLORS.border.default}`,
          fontSize: '0.75rem',
          borderRadius: 6,
        },
      },
    },

    // --- Table ---
    MuiTableCell: {
      styleOverrides: {
        root: {
          borderColor: COLORS.border.subtle,
          padding: '10px 16px',
          fontSize: '0.85rem',
        },
        head: {
          fontWeight: 600,
          fontSize: '0.75rem',
          letterSpacing: '0.05em',
          textTransform: 'uppercase',
          color: COLORS.text.secondary,
          background: COLORS.bg.elevated,
        },
      },
    },
  },
});

export { COLORS };
export default pcxTheme;
