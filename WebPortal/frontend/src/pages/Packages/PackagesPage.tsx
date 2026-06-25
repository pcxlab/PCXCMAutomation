import React from 'react';
import { Box, Typography, alpha } from '@mui/material';
import Inventory2Icon from '@mui/icons-material/Inventory2';
import { COLORS } from '../../theme/theme';

const PackagesPage: React.FC = () => (
  <Box>
    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 3 }}>
      <Inventory2Icon sx={{ color: 'secondary.main', fontSize: '1.75rem' }} />
      <Box>
        <Typography variant="h2">Packages</Typography>
        <Typography variant="body2" color="text.secondary">Manage SCCM Legacy Packages</Typography>
      </Box>
    </Box>
    <Box sx={{ p: 4, border: `1px dashed ${COLORS.border.default}`, borderRadius: 2, textAlign: 'center', background: alpha(COLORS.accent.main, 0.03) }}>
      <Typography variant="h5" sx={{ color: 'text.secondary', mb: 1 }}>Package List — Phase 4</Typography>
      <Typography variant="body2" color="text.disabled">Use the sidebar to navigate to Create Package</Typography>
    </Box>
  </Box>
);

export default PackagesPage;
