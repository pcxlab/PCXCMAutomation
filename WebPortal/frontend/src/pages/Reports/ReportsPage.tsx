import React from 'react';
import { Box, Typography, Chip, alpha } from '@mui/material';
import BarChartIcon from '@mui/icons-material/BarChart';
import { COLORS } from '../../theme/theme';

const ReportsPage: React.FC = () => (
  <Box>
    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 3 }}>
      <BarChartIcon sx={{ color: COLORS.info, fontSize: '1.75rem' }} />
      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
        <Box>
          <Typography variant="h2">Reports</Typography>
          <Typography variant="body2" color="text.secondary">Deployment Analytics & Reporting</Typography>
        </Box>
        <Chip label="Coming Soon" size="small" sx={{ height: 20, fontSize: '0.65rem', background: alpha(COLORS.info, 0.1), color: COLORS.info }} />
      </Box>
    </Box>
    <Box sx={{ p: 4, border: `1px dashed ${COLORS.border.default}`, borderRadius: 2, textAlign: 'center' }}>
      <Typography variant="h5" color="text.secondary">Reports — Future Phase</Typography>
    </Box>
  </Box>
);

export default ReportsPage;
