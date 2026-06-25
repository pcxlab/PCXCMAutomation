import React from 'react';
import { Box, Typography, alpha } from '@mui/material';
import AddCircleOutlineIcon from '@mui/icons-material/AddCircleOutlineOutlined';
import { COLORS } from '../../theme/theme';

// Full implementation delivered in Phase 4
const CreatePackagePage: React.FC = () => (
  <Box>
    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 3 }}>
      <AddCircleOutlineIcon sx={{ color: 'secondary.main', fontSize: '1.75rem' }} />
      <Box>
        <Typography variant="h2">Create Package</Typography>
        <Typography variant="body2" color="text.secondary">
          Deploy a new SCCM Legacy Package — powered by <code>Create-PCXCMPackage</code>
        </Typography>
      </Box>
    </Box>
    <Box sx={{ p: 4, border: `1px dashed ${COLORS.border.default}`, borderRadius: 2, textAlign: 'center', background: alpha(COLORS.accent.main, 0.03) }}>
      <Typography variant="h5" sx={{ color: 'text.secondary', mb: 1 }}>Full Form — Phase 4</Typography>
      <Typography variant="body2" color="text.disabled">
        Will include: Source Path · Package Metadata · Request Info · Distribution Config · Programs Preview · Progress log
      </Typography>
    </Box>
  </Box>
);

export default CreatePackagePage;
