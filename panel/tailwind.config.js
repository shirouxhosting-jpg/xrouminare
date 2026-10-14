/*
 | XROUMINARE theme for Pterodactyl Panel.
 |
 | The base gray/neutral ramp and the "black" color are mapped to CSS custom
 | properties defined in resources/scripts/assets/css/xrou-theme.css so that the
 | whole panel can switch between Light and Dark mode without a page reload.
 | The Saweria-inspired accent ramps (cyan, yellow, pink/red, green, purple)
 | keep the same identity in both modes.
 */

const gray = {
    50: 'var(--xrou-n50)',
    100: 'var(--xrou-n100)',
    200: 'var(--xrou-n200)',
    300: 'var(--xrou-n300)',
    400: 'var(--xrou-n400)',
    500: 'var(--xrou-n500)',
    600: 'var(--xrou-n600)',
    700: 'var(--xrou-n700)',
    800: 'var(--xrou-n800)',
    900: 'var(--xrou-n900)',
};

const cyan = {
    50: '#F0FAFC',
    100: '#DCF2F6',
    200: '#BCE7EE',
    300: '#9BDDE7',
    400: '#8DD8E2',
    500: '#62C4D4',
    600: '#3FA9BC',
    700: '#33899A',
    800: '#2A6F7D',
    900: '#225863',
};

const green = {
    50: '#F0FAF4',
    100: '#DCF2E4',
    200: '#BEE7CE',
    300: '#A0DEB8',
    400: '#8DD8A8',
    500: '#66C288',
    600: '#4AA96E',
    700: '#3D8C5B',
    800: '#33724B',
    900: '#2A5C3E',
};

const yellow = {
    50: '#FFF8EA',
    100: '#FFEFCB',
    200: '#FFE3A6',
    300: '#FFD67E',
    400: '#FFB629',
    500: '#FFA714',
    600: '#E08F0A',
    700: '#B87408',
    800: '#945C06',
    900: '#7A4B05',
};

// "red" carries the pink danger identity of the XROUMINARE palette.
const red = {
    50: '#FFF1F3',
    100: '#FFDDE2',
    200: '#FFC2CB',
    300: '#FFA6B3',
    400: '#FF8999',
    500: '#FB6D82',
    600: '#E14F66',
    700: '#BC3D52',
    800: '#993244',
    900: '#7D2A39',
};

const purple = {
    50: '#F3F1FE',
    100: '#E6E2FD',
    200: '#CEC8FB',
    300: '#B5ABF9',
    400: '#9A8DF7',
    500: '#8175F5',
    600: '#6C5EE0',
    700: '#5A4CC4',
    800: '#4B3FA3',
    900: '#3D3484',
};

module.exports = {
    content: [
        './resources/scripts/**/*.{js,ts,tsx}',
    ],
    theme: {
        extend: {
            fontFamily: {
                header: ['Nunito', '"IBM Plex Sans"', '"Roboto"', 'system-ui', 'sans-serif'],
                sans: ['Nunito', '"IBM Plex Sans"', '"Roboto"', 'system-ui', 'sans-serif'],
                mono: ['"IBM Plex Mono"', 'ui-monospace', 'monospace'],
            },
            colors: {
                black: 'var(--xrou-black)',
                // "primary" and "neutral" are deprecated, prefer the use of "blue" and "gray"
                // in new code.
                primary: cyan,
                gray: gray,
                neutral: gray,
                cyan: cyan,
                green: green,
                yellow: yellow,
                red: red,
                purple: purple,
                blue: cyan,
            },
            fontSize: {
                '2xs': '0.625rem',
            },
            transitionDuration: {
                250: '250ms',
            },
            borderColor: theme => ({
                default: 'var(--xrou-border)',
            }),
            boxShadow: {
                xrou: 'var(--xrou-shadow-offset) var(--xrou-shadow-offset) 0 var(--xrou-shadow)',
                'xrou-sm': 'calc(var(--xrou-shadow-offset) / 2) calc(var(--xrou-shadow-offset) / 2) 0 var(--xrou-shadow)',
            },
            borderRadius: {
                xrou: '6px',
            },
        },
    },
    plugins: [
        require('@tailwindcss/line-clamp'),
        require('@tailwindcss/forms')({
            strategy: 'class',
        }),
    ]
};
