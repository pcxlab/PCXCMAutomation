import React from 'react';
import { ThemeProvider, CssBaseline } from '@mui/material';
import pcxTheme from './theme/theme';
import AppRouter from './router/AppRouter';
import '@fontsource/inter/400.css';
import '@fontsource/inter/500.css';
import '@fontsource/inter/600.css';
import '@fontsource/inter/700.css';

const App: React.FC = () => (
  <ThemeProvider theme={pcxTheme}>
    <CssBaseline />
    <AppRouter />
  </ThemeProvider>
);

export default App;
