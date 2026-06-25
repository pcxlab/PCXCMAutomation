import React from 'react';
import { Box, Typography, Chip, alpha } from '@mui/material';
import CloudUploadIcon from '@mui/icons-material/CloudUpload';
import { COLORS } from '../../theme/theme';

const DistributionPage: React.FC = () => (
  <Box>
    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 3 }}>
      <CloudUploadIcon sx={{ color: COLORS.warning, fontSize: '1.75rem' }} />
      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
        <Box>
          <Typography variant="h2">Distribution</Typography>
          <Typography variant="body2" color="text.secondary">Content Distribution Management</Typography>
        </Box>
        <Chip label="Coming Soon" size="small" sx={{ height: 20, fontSize: '0.65rem', background: alpha(COLORS.warning, 0.1), color: COLORS.warning }} />
      </Box>
    </Box>
    <Box sx={{ p: 4, border: `1px dashed ${COLORS.border.default}`, borderRadius: 2, textAlign: 'center' }}>
      <Typography variant="h5" color="text.secondary">Distribution Management — Future Phase</Typography>
    </Box>
  </Box>
);

export default DistributionPage;
