import React from 'react';
import { Box, Typography, Chip, alpha } from '@mui/material';
import AppsIcon from '@mui/icons-material/Apps';
import { COLORS } from '../../theme/theme';

const ApplicationsPage: React.FC = () => (
  <Box>
    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 3 }}>
      <AppsIcon sx={{ color: 'primary.main', fontSize: '1.75rem' }} />
      <Box>
        <Typography variant="h2">Applications</Typography>
        <Typography variant="body2" color="text.secondary">Manage SCCM Applications</Typography>
      </Box>
    </Box>
    <Box sx={{ p: 4, border: `1px dashed ${COLORS.border.default}`, borderRadius: 2, textAlign: 'center', background: alpha(COLORS.primary.main, 0.03) }}>
      <Typography variant="h5" sx={{ color: 'text.secondary', mb: 1 }}>Application List — Phase 3</Typography>
      <Typography variant="body2" color="text.disabled">Use the sidebar to navigate to Create Application</Typography>
    </Box>
  </Box>
);

export default ApplicationsPage;
