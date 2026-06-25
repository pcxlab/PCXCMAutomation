import React, { Suspense, lazy } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { Box, CircularProgress } from '@mui/material';
import AppShell from '../components/layout/AppShell';
import { ROUTES } from '../config/routes';

// Lazy-loaded pages for code splitting
const Dashboard = lazy(() => import('../pages/Dashboard/Dashboard'));
const ApplicationsPage = lazy(() => import('../pages/Applications/ApplicationsPage'));
const CreateApplicationPage = lazy(() => import('../pages/Applications/CreateApplicationPage'));
const PackagesPage = lazy(() => import('../pages/Packages/PackagesPage'));
const CreatePackagePage = lazy(() => import('../pages/Packages/CreatePackagePage'));
const DistributionPage = lazy(() => import('../pages/Distribution/DistributionPage'));
const ReportsPage = lazy(() => import('../pages/Reports/ReportsPage'));
const AdministrationPage = lazy(() => import('../pages/Administration/AdministrationPage'));

const PageLoader = () => (
  <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '60vh' }}>
    <CircularProgress size={32} thickness={3} />
  </Box>
);

const AppRouter: React.FC = () => (
  <BrowserRouter>
    <Suspense fallback={<PageLoader />}>
      <Routes>
        <Route element={<AppShell />}>
          <Route path={ROUTES.DASHBOARD} element={<Dashboard />} />
          <Route path={ROUTES.APPLICATIONS} element={<ApplicationsPage />} />
          <Route path={ROUTES.APPLICATIONS_CREATE} element={<CreateApplicationPage />} />
          <Route path={ROUTES.PACKAGES} element={<PackagesPage />} />
          <Route path={ROUTES.PACKAGES_CREATE} element={<CreatePackagePage />} />
          <Route path={ROUTES.DISTRIBUTION} element={<DistributionPage />} />
          <Route path={ROUTES.REPORTS} element={<ReportsPage />} />
          <Route path={ROUTES.ADMINISTRATION} element={<AdministrationPage />} />
          {/* Catch-all */}
          <Route path="*" element={<Navigate to={ROUTES.DASHBOARD} replace />} />
        </Route>
      </Routes>
    </Suspense>
  </BrowserRouter>
);

export default AppRouter;
