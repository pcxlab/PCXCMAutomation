import React, { useState } from 'react';
import { Box, useMediaQuery, useTheme } from '@mui/material';
import { Outlet } from 'react-router-dom';
import TopBar from './TopBar';
import Sidebar from './Sidebar';
import { SIDEBAR_WIDTH, TOPBAR_HEIGHT } from '../../config/routes';

const AppShell: React.FC = () => {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));
  const [sidebarOpen, setSidebarOpen] = useState(!isMobile);

  const toggleSidebar = () => setSidebarOpen(prev => !prev);

  return (
    <Box sx={{ display: 'flex', height: '100vh', overflow: 'hidden' }}>
      {/* Top navigation bar */}
      <TopBar onMenuToggle={toggleSidebar} sidebarOpen={sidebarOpen} />

      {/* Sidebar — permanent on desktop, temporary drawer on mobile */}
      <Sidebar
        open={sidebarOpen}
        onClose={() => setSidebarOpen(false)}
        variant={isMobile ? 'temporary' : 'permanent'}
      />

      {/* Main content area */}
      <Box
        component="main"
        sx={{
          flexGrow: 1,
          display: 'flex',
          flexDirection: 'column',
          overflow: 'hidden',
          mt: `${TOPBAR_HEIGHT}px`,
          ml: { md: sidebarOpen ? `${SIDEBAR_WIDTH}px` : 0 },
          transition: theme.transitions.create(['margin'], {
            easing: theme.transitions.easing.sharp,
            duration: theme.transitions.duration.leavingScreen,
          }),
          width: { md: sidebarOpen ? `calc(100% - ${SIDEBAR_WIDTH}px)` : '100%' },
        }}
      >
        <Box
          sx={{
            flex: 1,
            overflowY: 'auto',
            p: { xs: 2, md: 3 },
          }}
        >
          <Outlet />
        </Box>
      </Box>
    </Box>
  );
};

export default AppShell;
