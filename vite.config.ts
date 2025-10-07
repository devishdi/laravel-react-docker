import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import tailwindcss from '@tailwindcss/vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
    plugins: [
        tailwindcss(),
        react(),
        laravel({
            input: ['resources/css/app.css', 'resources/js/app.tsx'],
            refresh: true,
        }),
    ],
    server: {
        allowedHosts: ['muslimarry.localdev', 'muslimarry.frontend.localdev'],
    },
    resolve: {
        alias: {
            '@': '/resources/js',
        },
    },
    test: {
        include: ['resources/js/tests/*.test.{ts,tsx}'],
    },
});
