# Design: Fuligin

*Fuligin* is the colour "darker than black" in Gene Wolfe's *The Book of the
New Sun*. The rule of the theme: almost everything is quiet; one thing glows.

## Palette

| role       | hex       | use                                       |
|------------|-----------|-------------------------------------------|
| background | `#121214` | every surface                             |
| surface    | `#1c1b1f` | inactive borders, hover                   |
| line       | `#2a292e` | separators, selection background          |
| muted      | `#6f6a62` | secondary text, labels                    |
| text       | `#d8d2c6` | primary text                              |
| bright     | `#e6e1d8` | focused text, clock                       |
| **ember**  | `#b5523b` | the one accent: focus, prompt, logo       |
| brass      | `#c9a66b` | warnings, urgent, a failed command        |

Terminal colours (ANSI 0–15):
`1c1b1f b5523b 7f9a65 c9a66b 6b8299 9a7aa0 6f9a96 d8d2c6`
`46444a d06a50 99b47d ddbd85 849bb2 b393b9 88b3ae ece7dd`

The console (TTY) uses the same palette through `vt.default_red/grn/blu`
kernel parameters.

## Type

- **JetBrains Mono** — bar, terminal, launcher, notifications
- **Noto Sans** — GTK applications

## Logo

An old sun resting on the horizon, with one ember rising inside it.
Ring and horizon in *text*, the ember in *ember*. Source:
`packages/severian-branding/files/usr/share/icons/hicolor/scalable/apps/severianos.svg`.

## Rules

1. One accent colour. If two things glow, neither does.
2. Labels are lowercase words (`cpu 3%`, `vol 40%`), not icons.
3. No rounded corners, no shadows, no transparency except the launcher.
4. Every tool speaks the same language: `●` marks SeverianOS output.
5. If a value cannot be trusted (a broken sensor), show nothing.
