import React from 'react';
import { Box, Typography, alpha } from '@mui/material';
import SettingsIcon from '@mui/icons-material/Settings';
import { COLORS } from '../../theme/theme';

const AdministrationPage: React.FC = () => (
  <Box>
    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 3 }}>
      <SettingsIcon sx={{ color: 'text.secondary', fontSize: '1.75rem' }} />
      <Box>
        <Typography variant="h2">Administration</Typography>
        <Typography variant="body2" color="text.secondary">System Configuration & User Management</Typography>
      </Box>
    </Box>
    <Box sx={{ p: 4, border: `1px dashed ${COLORS.border.default}`, borderRadius: 2, textAlign: 'center' }}>
      <Typography variant="h5" color="text.secondary">Administration — Phase 6</Typography>
    </Box>
  </Box>
);

export default AdministrationPage;
