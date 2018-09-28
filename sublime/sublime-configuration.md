# sublime 配置

## settings user

```js
{
  "always_show_minimap_viewport": true,
  "auto_find_in_selection": true,
  "bold_folder_labels": true,
  "color_scheme": "Packages/Boxy Theme/schemes/Boxy Monokai.tmTheme",
  "disable_tab_abbreviations": true,
  "dpi_scale": 1.1,
  "draw_minimap_border": true,
  "ensure_newline_at_eof_on_save": true,
  "fade_fold_buttons": false,
  "font_options":
  [
    "gray_antialias"
  ],
  "font_size": 15,
  "highlight_line": true,
  "ignored_packages":
  [
    "Markdown",
    "Vintage"
  ],
  "indent_guide_options":
  [
    "draw_normal",
    "draw_active"
  ],
  "line_padding_bottom": 3,
  "line_padding_top": 3,
  "material_theme_accent_scrollbars": true,
  "material_theme_arrow_folders": false,
  "material_theme_big_fileicons": true,
  "material_theme_bold_tab": true,
  "material_theme_bright_scrollbars": true,
  "material_theme_bullet_tree_indicator": true,
  "material_theme_compact_panel": true,
  "material_theme_compact_sidebar": true,
  "material_theme_contrast_mode": true,
  "material_theme_disable_folder_animation": false,
  "material_theme_disable_tree_indicator": true,
  "material_theme_panel_separator": true,
  "material_theme_small_statusbar": true,
  "material_theme_small_tab": true,
  "material_theme_tabs_autowidth": false,
  "material_theme_tabs_separator": false,
  "material_theme_tree_headings": true,
  "overlay_scroll_bars": "enabled",
  "save_on_focus_lost": true,
  "show_encoding": true,
  "show_line_endings": true,
  "tab_size": 4,
  "theme": "Boxy Monokai.sublime-theme",
  "translate_tabs_to_spaces": true,
  "trim_trailing_white_space_on_save": true,
  "word_separators": "./\\()\"':,.;<>~!@#$%^&*|+=[]{}`~?、，。！？：（）“”＋",
  "word_wrap": true
}
```

## key bingdings user

```js
[{
  "command": "add_current_time",
  "keys": [
    "ctrl+shift+."
  ]
}, {
  "keys": ["alt+m"],
  "command": "markdown_preview",
  "args": {
    "target": "browser"
  }
}, {
  "keys": ["ctrl+shift+t"],
  "command": "open_terminal_project_folder",
  "args": {
    "parameters": ["-T", "Working in directory %CWD%"]
  }
}, {
  "keys": ["ctrl+alt+t"],
  "command": "open_terminal",
  "args": {
    "parameters": ["-T", "Working in directory %CWD%"]
  }
}]
```

## 调整sidebar字体
两种办法：

1，Navigate to Sublime Text -> Preferences -> Browse Packages
Open the `User` directory
Create a file named Default.sublime-theme (if you're using the default theme, otherwise use the theme name, e.g. Material-Theme-Darker.sublime-theme) with the following content (modify `font.size` as required):

```js
[
    {
        "class": "sidebar_label",
        "color": [0, 0, 0],
        "font.bold": false,
        "font.size": 16
    },
]
```

2，What worked was changing the dpi scale in Preferences > Settings- User by adding this line:

```
"dpi_scale": 1.10
```

## 开启vim模式

在菜单栏中： Preferences -> Setting - User 即可打开配置文件进行编辑，将 `ignored_packages` 项的`"Vintage"`移除。

再按 Esc 退出编辑模式，即进入了 Vim 模式。

参考：[【前端学习】sublime开启vim模式](http://www.cnblogs.com/flipped/p/5204139.html)
