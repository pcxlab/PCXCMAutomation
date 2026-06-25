// Route paths used throughout the app
export const ROUTES = {
  DASHBOARD: '/',
  APPLICATIONS: '/applications',
  APPLICATIONS_CREATE: '/applications/create',
  PACKAGES: '/packages',
  PACKAGES_CREATE: '/packages/create',
  DISTRIBUTION: '/distribution',
  REPORTS: '/reports',
  ADMINISTRATION: '/admin',
} as const;

// Sidebar navigation config
export const NAV_ITEMS = [
  {
    id: 'dashboard',
    label: 'Dashboard',
    icon: 'Dashboard',
    path: ROUTES.DASHBOARD,
    exact: true,
  },
  {
    id: 'applications',
    label: 'Applications',
    icon: 'Apps',
    path: ROUTES.APPLICATIONS,
    children: [
      { id: 'apps-create', label: 'Create Application', path: ROUTES.APPLICATIONS_CREATE },
    ],
  },
  {
    id: 'packages',
    label: 'Packages',
    icon: 'Inventory2',
    path: ROUTES.PACKAGES,
    children: [
      { id: 'pkg-create', label: 'Create Package', path: ROUTES.PACKAGES_CREATE },
    ],
  },
  {
    id: 'distribution',
    label: 'Distribution',
    icon: 'CloudUpload',
    path: ROUTES.DISTRIBUTION,
    badge: 'Soon',
  },
  {
    id: 'reports',
    label: 'Reports',
    icon: 'BarChart',
    path: ROUTES.REPORTS,
    badge: 'Soon',
  },
  {
    id: 'admin',
    label: 'Administration',
    icon: 'Settings',
    path: ROUTES.ADMINISTRATION,
  },
] as const;

export const SIDEBAR_WIDTH = 240;
export const TOPBAR_HEIGHT = 60;
