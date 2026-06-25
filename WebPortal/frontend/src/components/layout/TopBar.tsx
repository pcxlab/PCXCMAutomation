import React, { useState } from 'react';
import {
  AppBar,
  Toolbar,
  IconButton,
  Typography,
  Box,
  Avatar,
  Tooltip,
  Badge,
  Chip,
  useMediaQuery,
  useTheme,
  alpha,
} from '@mui/material';
import MenuIcon from '@mui/icons-material/Menu';
import NotificationsOutlinedIcon from '@mui/icons-material/NotificationsOutlined';
import HelpOutlineIcon from '@mui/icons-material/HelpOutlineOutlined';
import AccountCircleOutlinedIcon from '@mui/icons-material/AccountCircleOutlined';
import WifiIcon from '@mui/icons-material/Wifi';
import WifiOffIcon from '@mui/icons-material/WifiOff';
import { TOPBAR_HEIGHT, SIDEBAR_WIDTH } from '../../config/routes';
import { COLORS } from '../../theme/theme';

interface TopBarProps {
  onMenuToggle: () => void;
  sidebarOpen: boolean;
}

const TopBar: React.FC<TopBarProps> = ({ onMenuToggle, sidebarOpen }) => {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));
  const [connected] = useState(true); // future: real CM connection status

  return (
    <AppBar
      position="fixed"
      sx={{
        zIndex: theme.zIndex.drawer + 1,
        height: TOPBAR_HEIGHT,
        ml: { md: sidebarOpen ? `${SIDEBAR_WIDTH}px` : 0 },
        width: { md: sidebarOpen ? `calc(100% - ${SIDEBAR_WIDTH}px)` : '100%' },
        transition: theme.transitions.create(['width', 'margin'], {
          easing: theme.transitions.easing.sharp,
          duration: theme.transitions.duration.leavingScreen,
        }),
      }}
    >
      <Toolbar sx={{ height: TOPBAR_HEIGHT, minHeight: `${TOPBAR_HEIGHT}px !important`, px: 2 }}>
        {/* Menu toggle */}
        <IconButton
          onClick={onMenuToggle}
          size="small"
          sx={{
            mr: 1.5,
            color: 'text.secondary',
            '&:hover': { color: 'primary.main', background: alpha(COLORS.primary.main, 0.08) },
          }}
        >
          <MenuIcon fontSize="small" />
        </IconButton>

        {/* Brand wordmark (shown when sidebar collapsed or mobile) */}
        {(!sidebarOpen || isMobile) && (
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mr: 2 }}>
            <Box
              sx={{
                width: 28,
                height: 28,
                borderRadius: '6px',
                background: `linear-gradient(135deg, ${COLORS.primary.main}, ${COLORS.accent.main})`,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <Typography sx={{ fontSize: '0.7rem', fontWeight: 800, color: '#fff', letterSpacing: '-0.02em' }}>
                PCX
              </Typography>
            </Box>
            <Typography variant="h6" sx={{ fontWeight: 700, fontSize: '0.95rem', letterSpacing: '-0.01em' }}>
              PCXLab<Typography component="span" sx={{ color: 'primary.main', fontWeight: 700 }}> Portal</Typography>
            </Typography>
          </Box>
        )}

        {/* Breadcrumb / page context — injected by child pages via context in future */}
        <Box sx={{ flex: 1 }} />

        {/* CM Connection Status */}
        <Tooltip title={connected ? 'ConfigMgr Connected' : 'ConfigMgr Disconnected'}>
          <Chip
            icon={connected ? <WifiIcon sx={{ fontSize: '0.85rem !important' }} /> : <WifiOffIcon sx={{ fontSize: '0.85rem !important' }} />}
            label={connected ? 'CM Online' : 'CM Offline'}
            size="small"
            sx={{
              mr: 1.5,
              fontSize: '0.7rem',
              fontWeight: 600,
              height: 26,
              borderColor: connected ? alpha(COLORS.success, 0.4) : alpha(COLORS.error, 0.4),
              color: connected ? COLORS.success : COLORS.error,
              background: connected ? alpha(COLORS.success, 0.08) : alpha(COLORS.error, 0.08),
              border: '1px solid',
              '& .MuiChip-icon': { color: 'inherit' },
            }}
          />
        </Tooltip>

        {/* Notifications */}
        <Tooltip title="Notifications">
          <IconButton size="small" sx={{ color: 'text.secondary', mr: 0.5 }}>
            <Badge badgeContent={2} color="primary" sx={{ '& .MuiBadge-badge': { fontSize: '0.6rem', height: 16, minWidth: 16 } }}>
              <NotificationsOutlinedIcon fontSize="small" />
            </Badge>
          </IconButton>
        </Tooltip>

        {/* Help */}
        <Tooltip title="Help & Documentation">
          <IconButton size="small" sx={{ color: 'text.secondary', mr: 0.5 }}>
            <HelpOutlineIcon fontSize="small" />
          </IconButton>
        </Tooltip>

        {/* User Avatar */}
        <Tooltip title="Administrator">
          <IconButton size="small" sx={{ ml: 0.5 }}>
            <Avatar
              sx={{
                width: 30,
                height: 30,
                fontSize: '0.75rem',
                fontWeight: 700,
                background: `linear-gradient(135deg, ${COLORS.primary.main}, ${COLORS.accent.dark})`,
              }}
            >
              AD
            </Avatar>
          </IconButton>
        </Tooltip>
      </Toolbar>
    </AppBar>
  );
};

export default TopBar;
