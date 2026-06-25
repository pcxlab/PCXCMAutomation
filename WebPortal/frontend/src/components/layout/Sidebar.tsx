import React, { useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import {
  Drawer,
  Box,
  Typography,
  List,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Collapse,
  Divider,
  Chip,
  Tooltip,
  alpha,
} from '@mui/material';
import DashboardIcon from '@mui/icons-material/Dashboard';
import AppsIcon from '@mui/icons-material/Apps';
import Inventory2Icon from '@mui/icons-material/Inventory2';
import CloudUploadIcon from '@mui/icons-material/CloudUpload';
import BarChartIcon from '@mui/icons-material/BarChart';
import SettingsIcon from '@mui/icons-material/Settings';
import AddCircleOutlineIcon from '@mui/icons-material/AddCircleOutlineOutlined';
import ExpandLessIcon from '@mui/icons-material/ExpandLess';
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
import CircleIcon from '@mui/icons-material/Circle';
import { SIDEBAR_WIDTH, TOPBAR_HEIGHT, ROUTES } from '../../config/routes';
import { COLORS } from '../../theme/theme';

const ICON_MAP: Record<string, React.ReactNode> = {
  Dashboard: <DashboardIcon fontSize="small" />,
  Apps: <AppsIcon fontSize="small" />,
  Inventory2: <Inventory2Icon fontSize="small" />,
  CloudUpload: <CloudUploadIcon fontSize="small" />,
  BarChart: <BarChartIcon fontSize="small" />,
  Settings: <SettingsIcon fontSize="small" />,
  AddCircleOutline: <AddCircleOutlineIcon sx={{ fontSize: '0.85rem' }} />,
};

interface NavChild {
  id: string;
  label: string;
  path: string;
}

interface NavItem {
  id: string;
  label: string;
  icon: string;
  path: string;
  badge?: string;
  children?: NavChild[];
}

const NAV: NavItem[] = [
  { id: 'dashboard', label: 'Dashboard', icon: 'Dashboard', path: ROUTES.DASHBOARD },
  {
    id: 'applications', label: 'Applications', icon: 'Apps', path: ROUTES.APPLICATIONS,
    children: [
      { id: 'apps-create', label: 'Create Application', path: ROUTES.APPLICATIONS_CREATE },
    ],
  },
  {
    id: 'packages', label: 'Packages', icon: 'Inventory2', path: ROUTES.PACKAGES,
    children: [
      { id: 'pkg-create', label: 'Create Package', path: ROUTES.PACKAGES_CREATE },
    ],
  },
  { id: 'distribution', label: 'Distribution', icon: 'CloudUpload', path: ROUTES.DISTRIBUTION, badge: 'Soon' },
  { id: 'reports', label: 'Reports', icon: 'BarChart', path: ROUTES.REPORTS, badge: 'Soon' },
  { id: 'admin', label: 'Administration', icon: 'Settings', path: ROUTES.ADMINISTRATION },
];

const MODULE_SECTIONS = [
  { label: 'SCCM', active: true },
  { label: 'Intune', active: false },
  { label: 'Entra ID', active: false },
  { label: 'Autopilot', active: false },
];

interface SidebarProps {
  open: boolean;
  onClose: () => void;
  variant?: 'permanent' | 'temporary';
}

const Sidebar: React.FC<SidebarProps> = ({ open, onClose, variant = 'permanent' }) => {
  const location = useLocation();
  const navigate = useNavigate();
  const [expanded, setExpanded] = useState<string[]>(['applications', 'packages']);

  const isActive = (path: string) => location.pathname === path;
  const isParentActive = (item: NavItem) => {
    if (isActive(item.path)) return true;
    return item.children?.some(c => location.pathname.startsWith(c.path)) ?? false;
  };

  const toggleExpand = (id: string) => {
    setExpanded(prev => prev.includes(id) ? prev.filter(x => x !== id) : [...prev, id]);
  };

  const handleNavigate = (path: string) => {
    navigate(path);
    if (variant === 'temporary') onClose();
  };

  const content = (
    <Box sx={{ display: 'flex', flexDirection: 'column', height: '100%' }}>

      {/* Logo area */}
      <Box
        sx={{
          height: TOPBAR_HEIGHT,
          display: 'flex',
          alignItems: 'center',
          px: 2.5,
          gap: 1.5,
          borderBottom: `1px solid ${COLORS.border.subtle}`,
          flexShrink: 0,
        }}
      >
        <Box
          sx={{
            width: 32,
            height: 32,
            borderRadius: '8px',
            background: `linear-gradient(135deg, ${COLORS.primary.main}, ${COLORS.accent.main})`,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            flexShrink: 0,
            boxShadow: `0 2px 12px ${alpha(COLORS.primary.main, 0.4)}`,
          }}
        >
          <Typography sx={{ fontSize: '0.65rem', fontWeight: 900, color: '#fff', letterSpacing: '-0.02em' }}>
            PCX
          </Typography>
        </Box>
        <Box>
          <Typography sx={{ fontSize: '0.9rem', fontWeight: 700, lineHeight: 1.2, letterSpacing: '-0.01em' }}>
            PCXLab
          </Typography>
          <Typography sx={{ fontSize: '0.65rem', color: 'text.secondary', fontWeight: 500, letterSpacing: '0.05em' }}>
            PORTAL v1.0
          </Typography>
        </Box>
      </Box>

      {/* Module switcher */}
      <Box sx={{ px: 1.5, py: 1.5, borderBottom: `1px solid ${COLORS.border.subtle}` }}>
        <Typography variant="overline" sx={{ px: 1, color: 'text.disabled', fontSize: '0.6rem' }}>
          Module
        </Typography>
        <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5, mt: 0.5 }}>
          {MODULE_SECTIONS.map(mod => (
            <Chip
              key={mod.label}
              label={mod.label}
              size="small"
              sx={{
                height: 22,
                fontSize: '0.65rem',
                fontWeight: 600,
                cursor: mod.active ? 'default' : 'not-allowed',
                background: mod.active ? alpha(COLORS.primary.main, 0.15) : 'transparent',
                color: mod.active ? COLORS.primary.light : COLORS.text.disabled,
                border: `1px solid ${mod.active ? alpha(COLORS.primary.main, 0.3) : COLORS.border.subtle}`,
                '& .MuiChip-label': { px: 1 },
              }}
            />
          ))}
        </Box>
      </Box>

      {/* Navigation */}
      <Box sx={{ flex: 1, overflowY: 'auto', py: 1 }}>
        <Typography variant="overline" sx={{ px: 2.5, color: 'text.disabled', fontSize: '0.6rem', display: 'block', mb: 0.5 }}>
          Navigation
        </Typography>
        <List disablePadding>
          {NAV.map(item => {
            const parentActive = isParentActive(item);
            const isExpanded = expanded.includes(item.id);

            return (
              <React.Fragment key={item.id}>
                <ListItemButton
                  selected={parentActive}
                  onClick={() => {
                    if (item.children) {
                      toggleExpand(item.id);
                    } else {
                      handleNavigate(item.path);
                    }
                  }}
                  sx={{
                    borderLeft: parentActive ? `3px solid ${COLORS.primary.main}` : '3px solid transparent',
                    pl: parentActive ? '9px' : '12px',
                    '&.Mui-selected': {
                      background: alpha(COLORS.primary.main, 0.1),
                    },
                  }}
                >
                  <ListItemIcon sx={{ minWidth: 34, color: parentActive ? 'primary.main' : 'text.secondary' }}>
                    {ICON_MAP[item.icon]}
                  </ListItemIcon>
                  <ListItemText
                    primary={item.label}
                    primaryTypographyProps={{ fontSize: '0.85rem', fontWeight: parentActive ? 600 : 400 }}
                  />
                  {item.badge && (
                    <Chip
                      label={item.badge}
                      size="small"
                      sx={{
                        height: 18,
                        fontSize: '0.6rem',
                        fontWeight: 700,
                        background: alpha(COLORS.warning, 0.12),
                        color: COLORS.warning,
                        border: `1px solid ${alpha(COLORS.warning, 0.25)}`,
                        '& .MuiChip-label': { px: 0.75 },
                      }}
                    />
                  )}
                  {item.children && (
                    isExpanded
                      ? <ExpandLessIcon sx={{ fontSize: '1rem', color: 'text.secondary' }} />
                      : <ExpandMoreIcon sx={{ fontSize: '1rem', color: 'text.secondary' }} />
                  )}
                </ListItemButton>

                {/* Children */}
                {item.children && (
                  <Collapse in={isExpanded} timeout="auto">
                    <List disablePadding>
                      {item.children.map(child => (
                        <ListItemButton
                          key={child.id}
                          selected={isActive(child.path)}
                          onClick={() => handleNavigate(child.path)}
                          sx={{
                            pl: 4.5,
                            py: 0.6,
                            '&.Mui-selected': {
                              background: alpha(COLORS.primary.main, 0.12),
                              '& .MuiListItemText-primary': { color: COLORS.primary.light },
                            },
                          }}
                        >
                          <ListItemIcon sx={{ minWidth: 24 }}>
                            <CircleIcon sx={{ fontSize: '0.35rem', color: isActive(child.path) ? 'primary.main' : 'text.disabled' }} />
                          </ListItemIcon>
                          <ListItemText
                            primary={child.label}
                            primaryTypographyProps={{ fontSize: '0.8rem', fontWeight: isActive(child.path) ? 600 : 400 }}
                          />
                        </ListItemButton>
                      ))}
                    </List>
                  </Collapse>
                )}
              </React.Fragment>
            );
          })}
        </List>
      </Box>

      {/* Footer */}
      <Box
        sx={{
          px: 2,
          py: 1.5,
          borderTop: `1px solid ${COLORS.border.subtle}`,
          display: 'flex',
          alignItems: 'center',
          gap: 1,
        }}
      >
        <Box
          sx={{
            width: 6,
            height: 6,
            borderRadius: '50%',
            background: COLORS.success,
            boxShadow: `0 0 6px ${COLORS.success}`,
            animation: 'pulse 2s infinite',
            '@keyframes pulse': {
              '0%, 100%': { opacity: 1 },
              '50%': { opacity: 0.4 },
            },
          }}
        />
        <Typography variant="caption" sx={{ color: 'text.disabled', fontSize: '0.65rem' }}>
          pcxlab.com · PCXLab.SCCM v1.0.0
        </Typography>
      </Box>
    </Box>
  );

  return (
    <Drawer
      variant={variant}
      open={open}
      onClose={onClose}
      sx={{
        width: open ? SIDEBAR_WIDTH : 0,
        flexShrink: 0,
        '& .MuiDrawer-paper': {
          width: SIDEBAR_WIDTH,
          boxSizing: 'border-box',
          overflowX: 'hidden',
        },
      }}
    >
      {content}
    </Drawer>
  );
};

export default Sidebar;
