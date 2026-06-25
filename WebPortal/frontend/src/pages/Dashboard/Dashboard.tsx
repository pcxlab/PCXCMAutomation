import React from 'react';
import {
  Box, Grid, Typography, Card, CardContent, Chip, LinearProgress, alpha,
} from '@mui/material';
import AppsIcon from '@mui/icons-material/Apps';
import Inventory2Icon from '@mui/icons-material/Inventory2';
import CheckCircleOutlineIcon from '@mui/icons-material/CheckCircleOutlineOutlined';
import ErrorOutlineIcon from '@mui/icons-material/ErrorOutlineOutlined';
import PendingOutlinedIcon from '@mui/icons-material/PendingOutlined';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import { COLORS } from '../../theme/theme';

interface StatCardProps {
  label: string;
  value: string | number;
  icon: React.ReactNode;
  color: string;
  trend?: string;
  sub?: string;
}

const StatCard: React.FC<StatCardProps> = ({ label, value, icon, color, trend, sub }) => (
  <Card sx={{ height: '100%' }}>
    <CardContent sx={{ p: 2.5 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
        <Box>
          <Typography variant="overline" sx={{ color: 'text.secondary', fontSize: '0.65rem' }}>
            {label}
          </Typography>
          <Typography variant="h3" sx={{ mt: 0.5, fontWeight: 700, fontSize: '2rem', letterSpacing: '-0.02em' }}>
            {value}
          </Typography>
          {sub && (
            <Typography variant="caption" sx={{ color: 'text.secondary' }}>{sub}</Typography>
          )}
          {trend && (
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5, mt: 1 }}>
              <TrendingUpIcon sx={{ fontSize: '0.85rem', color: COLORS.success }} />
              <Typography variant="caption" sx={{ color: COLORS.success, fontWeight: 600 }}>{trend}</Typography>
            </Box>
          )}
        </Box>
        <Box
          sx={{
            width: 44,
            height: 44,
            borderRadius: '10px',
            background: alpha(color, 0.12),
            border: `1px solid ${alpha(color, 0.2)}`,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color,
          }}
        >
          {icon}
        </Box>
      </Box>
    </CardContent>
  </Card>
);

const RECENT_JOBS = [
  { name: 'APP Google Chrome 145.0.7632.46', type: 'Application', status: 'success', time: '2 min ago' },
  { name: 'PKG 7zip 26.0.2', type: 'Package', status: 'success', time: '18 min ago' },
  { name: 'APP Microsoft Edge 136.0', type: 'Application', status: 'running', time: '32 min ago' },
  { name: 'APP Adobe Acrobat DC', type: 'Application', status: 'failed', time: '1 hr ago' },
  { name: 'PKG VLC 3.0.21', type: 'Package', status: 'success', time: '3 hr ago' },
];

const STATUS_CONFIG = {
  success: { color: COLORS.success, icon: <CheckCircleOutlineIcon sx={{ fontSize: '1rem' }} />, label: 'Success' },
  failed: { color: COLORS.error, icon: <ErrorOutlineIcon sx={{ fontSize: '1rem' }} />, label: 'Failed' },
  running: { color: COLORS.info, icon: <PendingOutlinedIcon sx={{ fontSize: '1rem' }} />, label: 'Running' },
};

const Dashboard: React.FC = () => {
  return (
    <Box>
      {/* Page header */}
      <Box sx={{ mb: 3 }}>
        <Typography variant="h2" sx={{ fontWeight: 700 }}>Dashboard</Typography>
        <Typography variant="body2" sx={{ color: 'text.secondary', mt: 0.5 }}>
          PCXLab SCCM Automation Platform — Overview
        </Typography>
      </Box>

      {/* Stat cards */}
      <Grid container spacing={2} sx={{ mb: 3 }}>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            label="Applications Deployed"
            value={142}
            icon={<AppsIcon />}
            color={COLORS.primary.main}
            trend="+8 this week"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            label="Packages Deployed"
            value={89}
            icon={<Inventory2Icon />}
            color={COLORS.accent.main}
            trend="+3 this week"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            label="Success Rate"
            value="97.2%"
            icon={<CheckCircleOutlineIcon />}
            color={COLORS.success}
            sub="Last 30 days"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            label="Failed Jobs"
            value={6}
            icon={<ErrorOutlineIcon />}
            color={COLORS.error}
            sub="Requires attention"
          />
        </Grid>
      </Grid>

      {/* Recent Activity + Quick Actions */}
      <Grid container spacing={2}>
        {/* Recent jobs */}
        <Grid item xs={12} md={8}>
          <Card>
            <CardContent sx={{ p: 0 }}>
              <Box sx={{ px: 2.5, py: 2, borderBottom: `1px solid ${COLORS.border.subtle}`, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <Typography variant="h5">Recent Jobs</Typography>
                <Chip label="Live" size="small" sx={{ height: 20, fontSize: '0.65rem', background: alpha(COLORS.success, 0.1), color: COLORS.success, border: `1px solid ${alpha(COLORS.success, 0.25)}` }} />
              </Box>
              <Box>
                {RECENT_JOBS.map((job, i) => {
                  const cfg = STATUS_CONFIG[job.status as keyof typeof STATUS_CONFIG];
                  return (
                    <Box
                      key={i}
                      sx={{
                        px: 2.5,
                        py: 1.5,
                        display: 'flex',
                        alignItems: 'center',
                        gap: 2,
                        borderBottom: i < RECENT_JOBS.length - 1 ? `1px solid ${COLORS.border.subtle}` : 'none',
                        transition: 'background 0.15s',
                        '&:hover': { background: alpha(COLORS.primary.main, 0.03) },
                      }}
                    >
                      <Box sx={{ color: cfg.color, display: 'flex' }}>{cfg.icon}</Box>
                      <Box sx={{ flex: 1, minWidth: 0 }}>
                        <Typography variant="body2" noWrap sx={{ fontWeight: 500 }}>{job.name}</Typography>
                        <Typography variant="caption" sx={{ color: 'text.secondary' }}>{job.type}</Typography>
                      </Box>
                      <Chip
                        label={cfg.label}
                        size="small"
                        sx={{
                          height: 20,
                          fontSize: '0.65rem',
                          fontWeight: 600,
                          background: alpha(cfg.color, 0.1),
                          color: cfg.color,
                          border: `1px solid ${alpha(cfg.color, 0.25)}`,
                        }}
                      />
                      <Typography variant="caption" sx={{ color: 'text.disabled', whiteSpace: 'nowrap' }}>
                        {job.time}
                      </Typography>
                    </Box>
                  );
                })}
              </Box>
            </CardContent>
          </Card>
        </Grid>

        {/* Quick actions */}
        <Grid item xs={12} md={4}>
          <Card sx={{ height: '100%' }}>
            <CardContent sx={{ p: 0 }}>
              <Box sx={{ px: 2.5, py: 2, borderBottom: `1px solid ${COLORS.border.subtle}` }}>
                <Typography variant="h5">Quick Actions</Typography>
              </Box>
              <Box sx={{ p: 2, display: 'flex', flexDirection: 'column', gap: 1.5 }}>
                {[
                  { label: 'Create Application', desc: 'Deploy a new CM application', color: COLORS.primary.main, path: '/applications/create' },
                  { label: 'Create Package', desc: 'Deploy a legacy CM package', color: COLORS.accent.main, path: '/packages/create' },
                ].map(action => (
                  <Box
                    key={action.label}
                    sx={{
                      p: 2,
                      borderRadius: 2,
                      border: `1px solid ${COLORS.border.subtle}`,
                      background: COLORS.bg.elevated,
                      cursor: 'pointer',
                      transition: 'all 0.2s',
                      '&:hover': {
                        borderColor: alpha(action.color, 0.4),
                        background: alpha(action.color, 0.05),
                        transform: 'translateY(-1px)',
                      },
                    }}
                    onClick={() => window.location.href = action.path}
                  >
                    <Typography variant="body2" sx={{ fontWeight: 600, color: action.color }}>{action.label}</Typography>
                    <Typography variant="caption" sx={{ color: 'text.secondary' }}>{action.desc}</Typography>
                  </Box>
                ))}

                {/* CM Site health */}
                <Box sx={{ mt: 1 }}>
                  <Typography variant="caption" sx={{ color: 'text.secondary', display: 'block', mb: 1 }}>CM Site Health</Typography>
                  {[
                    { label: 'Site Server', value: 98 },
                    { label: 'SMS Provider', value: 100 },
                    { label: 'DP Content Sync', value: 74 },
                  ].map(h => (
                    <Box key={h.label} sx={{ mb: 1 }}>
                      <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                        <Typography variant="caption" sx={{ color: 'text.secondary' }}>{h.label}</Typography>
                        <Typography variant="caption" sx={{ color: h.value > 85 ? COLORS.success : COLORS.warning, fontWeight: 600 }}>{h.value}%</Typography>
                      </Box>
                      <LinearProgress
                        variant="determinate"
                        value={h.value}
                        sx={{
                          height: 4,
                          borderRadius: 2,
                          background: alpha(COLORS.border.default, 0.5),
                          '& .MuiLinearProgress-bar': {
                            background: h.value > 85 ? COLORS.success : COLORS.warning,
                            borderRadius: 2,
                          },
                        }}
                      />
                    </Box>
                  ))}
                </Box>
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
};

export default Dashboard;
